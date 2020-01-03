import Combine
import Foundation

class GameViewModel {
    @Published private(set) var title: String = ""

    @Published private(set) var score: String = ""

    @Published private(set) var time: String = ""

    @Published private(set) var isLoading: Bool = false

    @Published private(set) var game: Game? {
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

    var matchedWordsCount: Int? { game?.matchedWordsCount }

    func loadQuiz() {
        isLoading = true

        QuizService().loadQuiz { quiz, error in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false

                if let quiz = quiz {
                    self?.title = quiz.title
                    self?.game = Game(words: quiz.words)
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
    func game(_: Game, didMatchWord word: String) {
        matchedWord.send(word)
    }

    func game(_ game: Game, didUpdateScore score: Int) {
        self.score = "\(score)/\(game.wordsCount)"
    }

    func game(_: Game, didUpdateTime timeInSeconds: TimeInterval) {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60

        time = String(format: "%02i:%02i", minutes, seconds)
    }

    func gameDidLose(_: Game) {
        gameResult.send(false)
    }

    func gameDidWin(_: Game) {
        gameResult.send(true)
    }
}
