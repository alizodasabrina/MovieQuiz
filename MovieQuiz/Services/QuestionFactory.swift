import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoaderProtocol
    private weak var delegate: QuestionFactoryDelegate?

    private var movies: [MostPopularMovie] = []

    private enum QuestionFactoryError: Error, LocalizedError {
        case apiError(String)
        case imageLoadingError

        var errorDescription: String? {
            switch self {
            case .apiError(let message):
                return message
            case .imageLoadingError:
                return "Не удалось загрузить изображение"
            }
        }
    }

    init(moviesLoader: MoviesLoaderProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if !mostPopularMovies.errorMessage.isEmpty {
                        self.delegate?.didFailToLoadData(with: QuestionFactoryError.apiError(mostPopularMovies.errorMessage))
                        return
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: QuestionFactoryError.imageLoadingError)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0

            let randomRating = Float(Int.random(in: 5...9))
            let moreOrLess = Bool.random()

            let text = moreOrLess
                ? "Рейтинг этого фильма больше чем \(Int(randomRating))?"
                : "Рейтинг этого фильма меньше чем \(Int(randomRating))?"
            let correctAnswer = moreOrLess
                ? rating > randomRating
                : rating < randomRating

            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
