import XCTest
@testable import Sporcle

class GameTest: XCTestCase {
    func testShoudThrowErrorIfWordsListCountIsZero() {}

    func testShouldCountScoreWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")

        // Then
        XCTAssertEqual(game.score, 1)
    }

    func testShouldNotCountNumberOfInvalidWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Pineapple")

        // Then
        XCTAssertEqual(game.score, 0)
    }

    func testShouldCountScoreWordsOnlyOnce() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        game.match(word: "Banana")

        // Then
        XCTAssertEqual(game.score, 1)
    }

    func testShouldNotCountScoreLowercasedWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "banana")

        // Then
        XCTAssertEqual(game.score, 0)
    }

    func testShouldReturnMatchedWord() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        let matchedWord = game.matchedWord(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssertEqual(matchedWord, "Banana")
    }

    func testShouldResetGameState() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        game.reset()

        // Then
        XCTAssertEqual(game.matchedWordsCount, 0)
    }
}
