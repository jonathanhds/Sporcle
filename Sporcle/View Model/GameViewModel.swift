import Combine
import Foundation

enum GameAlertType {
    case none
    case win
    case lose
    case error
}

final class GameViewModel: ObservableObject {
    @Published private(set) var title: String = ""

    @Published private(set) var score: String = ""

    @Published private(set) var time: String = ""

    @Published private(set) var isLoading: Bool = false

    @Published var text: String = ""

    @Published var shouldShowAlert = false

    var alertType: GameAlertType = .none

    @Published var isRunning = false

    let matchedWord = PassthroughSubject<String, Never>()

    var matchedWords: [String] { game?.matchedWords ?? [] }

    private var game: GameManager? {
        didSet {
            game?.delegate = self
            reset()
        }
    }

    init(title: String = "") {
        self.title = title
    }

    func loadQuiz() {
        isLoading = true

        QuizService().loadQuiz { quiz, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false

                if let quiz = quiz {
                    self.title = quiz.title
                    self.game = GameManager(words: quiz.words)
                } else if let _ = error {
                    self.alertType = .error
                    self.shouldShowAlert = true
                }
            }
        }
    }

    func reset() {
        game?.reset()
        isRunning = false
    }

    private func start() {
        game?.start()
        isRunning = true
    }

    func startOrResetGame() {
        guard let game = game else { return }

        if game.isRunning {
            reset()
        } else {
            start()
        }
    }

    func match(word: String) {
        game?.match(word: word)
    }
}

// MARK: - GameDelegate

extension GameViewModel: GameDelegate {
    func game(_: GameManager, didMatchWord word: String) {
        matchedWord.send(word)
        text = ""
    }

    func game(_ game: GameManager, didUpdateScore score: Int) {
        self.score = "\(score)/\(game.wordsCount)"
    }

    func game(_: GameManager, didUpdateTime timeInSeconds: TimeInterval) {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60

        time = String(format: "%02i:%02i", minutes, seconds)
    }

    func gameDidLose(_: GameManager) {
        alertType = .lose
        shouldShowAlert = true
    }

    func gameDidWin(_: GameManager) {
        alertType = .win
        shouldShowAlert = true
    }
}
