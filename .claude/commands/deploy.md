# /deploy

You are archiving Nickelog and uploading a build to TestFlight via App Store Connect.

There is no auto-deploying host for a native iOS app — this command does a local `xcodebuild archive` + `-exportArchive` with `destination: upload`, which hands the build directly to App Store Connect without a separate `altool`/Transporter step.

---

## Input

Optional scope: $ARGUMENTS — currently unused (there is only one target to deploy). Reserved for future use (e.g. `beta` vs `production` App Store Connect groups).

---

## Step 0 — Check Apple signing credentials are configured

Check whether `Config/appstore.env` exists:

```bash
test -f Config/appstore.env && echo exists || echo missing
```

If missing, print this and stop — do not proceed:
```
❌ Config/appstore.env not found.

/deploy needs an App Store Connect API key to upload builds. One-time setup:

1. Create an API key at https://appstoreconnect.apple.com/access/api (role: App Manager or Admin)
   — this downloads a AuthKey_XXXXXXXXXX.p8 file ONCE, save it somewhere safe outside this repo.
2. Note your Key ID, Issuer ID (shown on that page), and your Apple Developer Team ID
   (found at https://developer.apple.com/account, under Membership).
3. Copy the template and fill in real values:
     cp Config/appstore.env.example Config/appstore.env
4. Edit Config/appstore.env with your Team ID, Key ID, Issuer ID, and the absolute path to the .p8 file.

Config/appstore.env is gitignored — it will never be committed.
```

If it exists, load it and check that no value still looks like a placeholder (contains `your_` or `/absolute/path/to/`). If any placeholder remains, print which key(s) still need real values and stop.

---

## Step 1 — Check for uncommitted changes

Run:
```bash
git status
```

If there are uncommitted changes, print:
```
⚠️  You have uncommitted changes. Run `/commit` first.
```
And stop.

---

## Step 2 — Regenerate the Xcode project

```bash
xcodegen generate
```

This ensures the archive is built from the current `project.yml`, not a stale `.xcodeproj`.

---

## Step 3 — Bump the build number

Read `CURRENT_PROJECT_VERSION` from `project.yml`. App Store Connect rejects re-uploading the same build number for a given version, so increment it by 1 in `project.yml` before archiving, unless the user explicitly says not to.

Print the old and new build number and confirm with the user before editing `project.yml`.

---

## Step 4 — Generate ExportOptions.plist

`Config/ExportOptions.plist` is generated (gitignored) from the committed `Config/ExportOptions.plist.template`, substituting the real Team ID from `Config/appstore.env`:

```bash
sed "s/__TEAM_ID__/$APPLE_TEAM_ID/" Config/ExportOptions.plist.template > Config/ExportOptions.plist
```

---

## Step 5 — Archive

```bash
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -configuration Release \
  -archivePath build/Nickelog.xcarchive \
  archive
```

This takes a few minutes. If it fails, print the xcodebuild error and stop — do not retry automatically or fall back to skipping signing.

---

## Step 6 — Export and upload

```bash
xcodebuild -exportArchive \
  -archivePath build/Nickelog.xcarchive \
  -exportOptionsPlist Config/ExportOptions.plist \
  -exportPath build/export \
  -authenticationKeyPath "$APP_STORE_CONNECT_API_KEY_PATH" \
  -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID" \
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID"
```

`Config/ExportOptions.plist.template` sets `method: app-store-connect` and `destination: upload`, so this step both exports the `.ipa` and uploads it to App Store Connect in one call — no separate Transporter/`altool` step needed.

On success, print:
```
✅ Build <version> (<build number>) uploaded to App Store Connect.
   It will appear under TestFlight after Apple finishes processing (usually a few minutes).
```

On failure, print the xcodebuild error and stop — do not retry automatically.

---

## Step 7 — Summary

Print:
```
## Deploy Summary

Version: <MARKETING_VERSION> (<CURRENT_PROJECT_VERSION>)
Archive: build/Nickelog.xcarchive
Upload:  ✅ Sent to App Store Connect | ❌ Failed (see error above)
```

---

## Rules

- NEVER commit `Config/appstore.env` or the generated `Config/ExportOptions.plist` — both are gitignored
- NEVER proceed without real (non-placeholder) values in `Config/appstore.env`
- NEVER skip the uncommitted-changes check
- If `xcodegen`, `xcodebuild`, or the export/upload step fails, stop and report — do not retry with different flags without asking
- Do not bump the build number without confirming with the user first
