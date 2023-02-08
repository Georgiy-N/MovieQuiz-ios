import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.color = .ypRed
        
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
    
    func buttonsIsEnabled() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func buttonsIsDisable() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func imageViewBoarderZero() {
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
            presenter.countCorrectAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true)
        buttonsIsDisable()
    }
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.buttonsIsDisable()
        }
        alertPresenter?.showResult(result: model)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        buttonsIsDisable()
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        buttonsIsDisable()
        presenter.noButtonClicked()
    }
}

