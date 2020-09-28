import XCTest
@testable import Sporcle

class GameTest: XCTestCase {
    // TODO: Implement this!!!!
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

    func testShouldWinGameIfMatchedAllWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        game.match(word: "Apple")

        // Then
        XCTAssertTrue(game.checkWinGame())
    }

    func testShouldNotWinGameIfNotMatchedAllWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")

        // Then
        XCTAssertFalse(game.checkWinGame())
    }
}
