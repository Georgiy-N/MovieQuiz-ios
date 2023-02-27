import UIKit

protocol MovieQuizViewControllerProtocol : AnyObject {
    func showStep(quiz step: QuizStepViewModel)
    func enableButtons()
    func disableButtons()
    func removeImageBorder()
    func highlightImageBorder(isCorrect: Bool)
    func showNetworkError(message: String)
    func activityIndicatorStartAnimation()
    func activityIndicatorStopAnimation()
    func alertPresenterShowResult(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.color = .ypRed
    }
    
    func activityIndicatorStartAnimation() {
         activityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimation() {
         activityIndicator.stopAnimating()
    }
    
    func showStep(quiz step: QuizStepViewModel) {
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = step.image},
                          completion: nil)
        textLable.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func removeImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        guard let currentQuestion = presenter.currentQuestion else {
            return
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if currentQuestion.correctAnswer == isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.increaceCorrectCount()
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.disableButtons()
        }
        alertPresenter?.showResult(result: model)
    }
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true)
        disableButtons()
    }
    
    func alertPresenterShowResult(message: String) {
        let alertModel = AlertModel (title: "Этот раунд окончен!", message: message, buttonText: "Сыграть еще раз", completion:  { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
        })
        alertPresenter?.showResult(result: alertModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        presenter.noButtonClicked()
    }
}

