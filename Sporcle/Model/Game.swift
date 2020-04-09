import Foundation

protocol GameRules {
    var score: Int { get }
    var matchedWordsCount: Int { get }
    var wordsCount: Int { get }

    func reset()
    func matchedWord(at indexPath: IndexPath) -> String?
    func match(word: String) -> Bool
    func checkWinGame() -> Bool
}

class Game: GameRules {
    var score: Int { matchedWords.count }

    var matchedWordsCount: Int { matchedWords.count }

    var wordsCount: Int { words.count }

    private let words: [String]

    private var matchedWords: [String]

    init(words: [String]) {
        self.words = words
        matchedWords = []
    }

    func reset() {
        matchedWords = []
    }

    func matchedWord(at indexPath: IndexPath) -> String? {
        matchedWords[indexPath.row]
    }

    @discardableResult
    func match(word: String) -> Bool {
        guard !isAlreadyMatched(word: word) else { return false }
        guard words.contains(word) else { return false }

        matchedWords.append(word)
        return true
    }

    func checkWinGame() -> Bool {
        matchedWords.count == words.count
    }

    private func isAlreadyMatched(word: String) -> Bool {
        matchedWords.contains(word)
    }
}
