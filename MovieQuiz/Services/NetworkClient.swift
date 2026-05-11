import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {

    private enum NetworkError: Error {
        case invalidResponse
        case invalidData
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error {
                handler(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  200..<300 ~= response.statusCode else {
                handler(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data else {
                handler(.failure(NetworkError.invalidData))
                return
            }

            handler(.success(data))

        }.resume()
    }
}
