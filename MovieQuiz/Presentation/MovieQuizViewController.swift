import UIKit


private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}
private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}
private let questions : [QuizQuestion] = [
    QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
]


final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0
    private var countCorrectAnswer = 0
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showStep(quiz: convert(model: questions[currentQuestionIndex]))
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
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { _ in
            self.currentQuestionIndex = 0
            self.countCorrectAnswer = 0
            self.showStep(quiz: self.convert(model: questions[self.currentQuestionIndex]))
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        switchButton()
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if questions[currentQuestionIndex].correctAnswer == isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            countCorrectAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1  {
            let resultViewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(countCorrectAnswer)/10", buttonText: "Сыграть еще раз")
            showResult(quiz: resultViewModel)
        } else {
            (currentQuestionIndex += 1)
            switchButton()
            showStep(quiz: convert(model: questions[currentQuestionIndex]))
        }
        self.imageView.layer.borderWidth = 0
    }
    private func switchButton() {
        yesButton.isEnabled = !yesButton.isEnabled
        noButton.isEnabled = !noButton.isEnabled
    }
}
