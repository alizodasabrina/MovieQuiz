import Foundation
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {

    }

    func show(quiz result: QuizResultsViewModel) {

    }

    func highlightImageBorder(isCorrectAnswer: Bool) {

    }

    func showLoadingIndicator() {

    }

    func hideLoadingIndicator() {

    }

    func showNetworkError(message: String) {

    }

    func setButtonsEnabled(_ isEnabled: Bool) {

    }
}
