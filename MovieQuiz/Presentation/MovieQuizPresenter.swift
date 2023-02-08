import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var countCorrectAnswer = 0
    var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private let statisticService: StatisticService!
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
        viewController?.activityIndicator.stopAnimating()
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showStep(quiz: viewModel)
        }
        viewController?.buttonsIsEnabled()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    func didLoadDataFromServer() {
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
        viewController?.self.activityIndicator.stopAnimating()
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
}


