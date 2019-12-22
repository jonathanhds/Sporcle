import Foundation

protocol GameDelegate: class {

	func game(_ game: Game, didMatchWord word: String)

	func game(_ game: Game, didUpdateTime: TimeInterval)

	func gameDidLose(_ game: Game)

	func gameDidWin(_ game: Game)

}
