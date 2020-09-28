import XCTest
@testable import Sporcle

class GameTest: XCTestCase {
    func testShoudThrowErrorIfWordsListCountIsZero() throws {
        // Given
        let words: [String] = []

        // When

        // Then
        XCTAssertThrowsError(try Game(words: words))
    }

    func testShouldCountScoreWords() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")

        // Then
        XCTAssertEqual(game.score, 1)
    }

    func testShouldNotCountNumberOfInvalidWords() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Pineapple")

        // Then
        XCTAssertEqual(game.score, 0)
    }

    func testShouldCountScoreWordsOnlyOnce() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        game.match(word: "Banana")

        // Then
        XCTAssertEqual(game.score, 1)
    }

    func testShouldNotCountScoreLowercasedWords() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "banana")

        // Then
        XCTAssertEqual(game.score, 0)
    }

    func testShouldWinGameIfMatchedAllWords() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")
        game.match(word: "Apple")

        // Then
        XCTAssertTrue(game.checkWinGame())
    }

    func testShouldNotWinGameIfNotMatchedAllWords() throws {
        // Given
        let game = try Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")

        // Then
        XCTAssertFalse(game.checkWinGame())
    }
}
