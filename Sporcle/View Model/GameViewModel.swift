import Combine
import Foundation

class GameViewModel {
    @Published private(set) var title: String = ""

    @Published private(set) var score: String = ""

    @Published private(set) var time: String = ""

    @Published private(set) var isLoading: Bool = false

    @Published private(set) var game: GameManager? {
        didSet {
            game?.delegate = self
            reset()
        }
    }

    let gameStarted = PassthroughSubject<Void, Never>()

    let gameReseted = PassthroughSubject<Void, Never>()

    let matchedWord = PassthroughSubject<String, Never>()

    let gameResult = PassthroughSubject<Bool, Never>()

    let loadingError = PassthroughSubject<Error, Never>()

    let service: QuizServiceProtocol

    var matchedWordsCount: Int? { game?.matchedWordsCount }

    init(service: QuizServiceProtocol = QuizService()) {
        self.service = service
    }

    func loadQuiz() {
        isLoading = true

        service.loadQuiz { quiz, error in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false

                if let quiz = quiz {
                    self?.title = quiz.title
                    self?.game = GameManager(words: quiz.words)
                } else if let error = error {
                    self?.loadingError.send(error)
                }
            }
        }
    }

    func start() {
        game?.start()
    }

    func reset() {
        game?.reset()
    }

    func startOrResetGame() {
        if game?.isRunning == true {
            gameReseted.send()
        } else {
            gameStarted.send()
        }
    }

    func match(word: String) {
        game?.match(word: word)
    }

    func matchedWord(at indexPath: IndexPath) -> String? {
        game?.matchedWord(at: indexPath)
    }
}

// MARK: - GameDelegate

extension GameViewModel: GameDelegate {
    func game(_: GameManager, didMatchWord word: String) {
        matchedWord.send(word)
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
        gameResult.send(false)
    }

    func gameDidWin(_: GameManager) {
        gameResult.send(true)
    }
}
