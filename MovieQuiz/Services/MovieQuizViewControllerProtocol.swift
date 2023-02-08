import UIKit
protocol MovieQuizViewControllerProtocol : AnyObject {
    var activityIndicator: UIActivityIndicatorView! { get set }
    var alertPresenter: AlertPresenter? { get set }
    func showStep(quiz step: QuizStepViewModel)
    func buttonsIsEnabled()
    func buttonsIsDisable()
    func imageViewBoarderZero()
    func highlightImageBorder(isCorrect: Bool)
    func presentAlert(alert: UIAlertController)
    func showNetworkError(message: String)
}
