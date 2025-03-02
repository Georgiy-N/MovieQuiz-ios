import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showStep(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func enableButtons() {
        
    }
    
    func disableButtons() {
        
    }
    
    func removeImageBorder() {
        
    }
    
    func activityIndicatorStartAnimation() {
        
    }
    
    func activityIndicatorStopAnimation() {
        
    }
    
    func alertPresenterShowResult(message: String) {
        
    }
    
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
