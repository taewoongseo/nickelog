import Foundation

enum TMDBError: Error {
    case missingAPIKey
    case invalidResponse
}

/// Thin client for the TMDB search endpoint. See VISION.md §7.3.
///
/// Reads the API key from the `TMDB_API_KEY` entry in Info.plist, which in turn
/// is populated from the `TMDB_API_KEY` build setting (see Config/Secrets.xcconfig.example).
struct TMDBService {
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!

    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String
    }

    func searchMovies(query: String) async throws -> [Movie] {
        guard let apiKey, !apiKey.isEmpty else {
            throw TMDBError.missingAPIKey
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("search/movie"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
        ]

        guard let url = components?.url else {
            throw TMDBError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(TMDBSearchResponse.self, from: data)
        return decoded.results
    }
}

private struct TMDBSearchResponse: Codable {
    let results: [Movie]
}
