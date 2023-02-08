import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    var activityIndicator: UIActivityIndicatorView!
    
    var alertPresenter: MovieQuiz.AlertPresenter?
    
    func showStep(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func buttonsIsEnabled() {
        
    }
    
    func buttonsIsDisable() {
        
    }
    
    func imageViewBoarderZero() {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func presentAlert(alert: UIAlertController) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
