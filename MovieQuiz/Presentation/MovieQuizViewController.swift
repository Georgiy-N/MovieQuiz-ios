import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate  {
    
    
    private var currentQuestionIndex = 0
    private var countCorrectAnswer = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showStep(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        switchButton()
        showAnswerResult(isCorrect: true)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        switchButton()
        showAnswerResult(isCorrect: false)
    }
    
    private func showStep(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
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
        
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: countCorrectAnswer, total: questionsAmount)
            
            let totalAcc = String(format: "%.2f", statisticService.totalAccuracy * 100)
            let dataFormatted = statisticService.bestGame.date.dateTimeString
            let record = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let text = """
                        Ваш результат: \(countCorrectAnswer)/\(questionsAmount)
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(record) (\(dataFormatted))
                        Средняя точность: \(totalAcc)%
                        """
            
            let alertModel = AlertModel (title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз", completion:  { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.countCorrectAnswer = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.showResult(result: alertModel)
        } else {
            (currentQuestionIndex += 1)
            switchButton()
            questionFactory?.requestNextQuestion()
        }
        self.imageView.layer.borderWidth = 0
    }
    private func switchButton() {
        yesButton.isEnabled = !yesButton.isEnabled
        noButton.isEnabled = !noButton.isEnabled
    }
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true)
        switchButton()
    }
}

