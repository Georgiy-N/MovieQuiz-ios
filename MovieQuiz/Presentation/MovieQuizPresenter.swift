import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var currentQuestion: QuizQuestion?
    private var countCorrectAnswer = 0
    private let questionsAmount: Int = 10
    private let statisticService: StatisticService?
    private var currentQuestionIndex: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNetworkError(message: String) {
        viewController?.showNetworkError(message: message)
    }
    
    func increaceCorrectCount() {
         countCorrectAnswer += 1
    }
    
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        countCorrectAnswer = 0
        questionFactory?.requestNextQuestion()
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
        viewController?.activityIndicatorStopAnimation()
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showStep(quiz: viewModel)
        }
        viewController?.enableButtons()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    func didLoadDataFromServer() {
        viewController?.activityIndicatorStopAnimation()
        questionFactory?.requestNextQuestion()
        viewController?.activityIndicatorStopAnimation()
    }
    
    func makeResultMessage() -> String {
        if let statisticService = statisticService {
            statisticService.store(correct: countCorrectAnswer, total: questionsAmount)
            let totalAcc = String(format: "%.2f", statisticService.totalAccuracy * 100)
            let dataFormatted = statisticService.bestGame.date.dateTimeString
            let record = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let resultMessage = """
                    Ваш результат: \(countCorrectAnswer)/\(questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(record) (\(dataFormatted))
                    Средняя точность: \(totalAcc)%
                    """
            return resultMessage
        }    else { return "Сервис статистики не доступен" }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func showNextQuestionOrResults() {
        
        if isLastQuestion() {
            let text = makeResultMessage()
            viewController?.alertPresenterShowResult(message: text)
        } else {
            switchToNextQuestion()
            viewController?.activityIndicatorStartAnimation()
            questionFactory?.requestNextQuestion()
            viewController?.enableButtons()
        }
        viewController?.removeImageBorder()
    }
}
    
    


