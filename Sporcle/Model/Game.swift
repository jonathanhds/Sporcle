import Foundation

private struct Constants {
    static let ONE_SECOND: TimeInterval = 1.0
    static let GAME_START_TIME = ONE_SECOND * 60 * 5
}

class Game {
    private let words: [String]

    private var matchedWords: [String]

    private var timer: Timer?

    private(set) var score: Int {
        didSet {
            delegate?.game(self, didUpdateScore: score)
        }
    }

    private(set) var timeInSeconds: TimeInterval {
        didSet {
            delegate?.game(self, didUpdateTime: timeInSeconds)
        }
    }

    private(set) var isRunning = false

    weak var delegate: GameDelegate?

    var wordsCount: Int { words.count }

    var matchedWordsCount: Int { matchedWords.count }

    init(words: [String]) {
        self.words = words
        matchedWords = []
        score = 0
        timeInSeconds = Constants.GAME_START_TIME
    }

    deinit {
        stopTimer()
    }

    func start() {
        reset()
        startTimer()
        isRunning = true
    }

    func reset() {
        stopTimer()
        matchedWords = []
        score = 0
        timeInSeconds = Constants.GAME_START_TIME
        isRunning = false
    }

    func matchedWord(at indexPath: IndexPath) -> String? {
        matchedWords[indexPath.row]
    }

    func match(word: String) {
        guard !isAlreadyMatched(word: word) else { return }

        if words.contains(word) {
            matchedWords.append(word)

            score += 1

            delegate?.game(self, didMatchWord: word)

            if score == words.count {
                isRunning = false
                stopTimer()
                delegate?.gameDidWin(self)
            }
        }
    }

    private func isAlreadyMatched(word: String) -> Bool {
        matchedWords.contains(word)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.ONE_SECOND, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeInSeconds -= Constants.ONE_SECOND

            if self.timeInSeconds <= 0 {
                self.isRunning = false
                self.delegate?.gameDidLose(self)
                self.stopTimer()
            }
        }
    }
}
