import Foundation

protocol GameRules {
    var matchedWords: [String] { get }
    var score: Int { get }
    var wordsCount: Int { get }

    func reset()
    func match(word: String) -> Bool
    func checkWinGame() -> Bool
}

class Game: GameRules {
    var score: Int { matchedWords.count }

    var wordsCount: Int { words.count }

    private let words: [String]

    private(set) var matchedWords: [String]

    init(words: [String]) {
        self.words = words
        matchedWords = []
    }

    func reset() {
        matchedWords = []
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
