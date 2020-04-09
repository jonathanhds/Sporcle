import Foundation

protocol GameDelegate: AnyObject {
    func game(_ game: GameManager,
              didMatchWord word: String)

    func game(_ game: GameManager,
              didUpdateScore score: Int)

    func game(_ game: GameManager,
              didUpdateTime timeInSeconds: TimeInterval)

    func gameDidLose(_ game: GameManager)

    func gameDidWin(_ game: GameManager)
}
