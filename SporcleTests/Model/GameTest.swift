import XCTest
@testable import Sporcle

class GameTest: XCTestCase {
    func testShoudThrowErrorIfWordsListCountIsZero() {}

    func testShouldCountNumberOfMatchedWords() {
        // Given
        let game = Game(words: ["Banana", "Apple"])

        // When
        game.match(word: "Banana")

        // Then
        XCTAssertEqual(game.matchedWordsCount, 1)
    }
}
