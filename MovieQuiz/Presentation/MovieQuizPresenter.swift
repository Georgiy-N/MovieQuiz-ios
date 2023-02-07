import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var alertPresenter: AlertPresenter?
    var countCorrectAnswer = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        countCorrectAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        viewController?.showAnswerResult(isCorrect: true)
    }
    
    func noButtonClicked() {
        viewController?.showAnswerResult(isCorrect: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        viewController?.activityIndicator.stopAnimating()
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showStep(quiz: viewModel)
        }
        viewController?.buttonsIsEnabled()
    }
    
    func showNextQuestionOrResults() {
        
        if isLastQuestion() {
            guard let statisticService = viewController?.statisticService else { return }
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
                self.resetQuestionIndex()
                self.countCorrectAnswer = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.showResult(result: alertModel)
        } else {
            switchToNextQuestion()
            viewController?.activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
            viewController?.buttonsIsEnabled()
        }
        viewController?.imageView.layer.borderWidth = 0
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    func didLoadDataFromServer() {
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func presentAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true)
        viewController?.buttonsIsDisable()
    }
    
    func showNetworkError(message: String) {
        viewController?.activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.resetQuestionIndex()
            self.viewController?.buttonsIsDisable()
        }
        alertPresenter?.showResult(result: model)
    }
}


