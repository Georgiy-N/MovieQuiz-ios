import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate  {
    
    
    private var countCorrectAnswer = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.color = .ypRed
        questionFactory?.loadData()
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        activityIndicator.stopAnimating()
        currentQuestion = question
        buttonsIsEnabled()
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showStep(quiz: viewModel)
        }
        buttonsIsEnabled()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        buttonsIsDisable()
        showAnswerResult(isCorrect: true)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        buttonsIsDisable()
        showAnswerResult(isCorrect: false)
    }
    
    private func showStep(quiz step: QuizStepViewModel) {
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = step.image},
                          completion: nil)
        textLable.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if currentQuestion.correctAnswer == isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            countCorrectAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: countCorrectAnswer, total: presenter.questionsAmount)
            
            let totalAcc = String(format: "%.2f", statisticService.totalAccuracy * 100)
            let dataFormatted = statisticService.bestGame.date.dateTimeString
            let record = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let text = """
                        Ваш результат: \(countCorrectAnswer)/\(presenter.questionsAmount)
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(record) (\(dataFormatted))
                        Средняя точность: \(totalAcc)%
                        """
            
            let alertModel = AlertModel (title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз", completion:  { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.countCorrectAnswer = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.showResult(result: alertModel)
        } else {
            presenter.switchToNextQuestion()
            activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
            buttonsIsEnabled()
        }
        self.imageView.layer.borderWidth = 0
    }
    
    private func buttonsIsEnabled() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func buttonsIsDisable() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
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
            self.countCorrectAnswer = 0
            self.questionFactory?.requestNextQuestion()
            self.buttonsIsDisable()
        }
        alertPresenter?.showResult(result: model)
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating() 
        questionFactory?.requestNextQuestion()
    }
}

