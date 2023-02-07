import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var countCorrectAnswer = 0
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
        countCorrectAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        showAnswerResult(isCorrect: true)
    }
    
    func noButtonClicked() {
        showAnswerResult(isCorrect: false)
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
    
    private func showNextQuestionOrResults() {
        
        if isLastQuestion() {
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
                self.resetQuestionIndex()
            })
            viewController?.alertPresenter?.showResult(result: alertModel)
        } else {
            switchToNextQuestion()
            viewController?.activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
            viewController?.buttonsIsEnabled()
        }
        viewController?.imageViewBoarderZero()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    func didLoadDataFromServer() {
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func showNetworkError(message: String) {
        viewController?.activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.resetQuestionIndex()
            self.viewController?.buttonsIsDisable()
        }
        viewController?.alertPresenter?.showResult(result: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
}


