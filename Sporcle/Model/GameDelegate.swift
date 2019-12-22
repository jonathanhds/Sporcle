import Foundation

protocol GameDelegate: class {

	func game(_ game: Game,
			  didMatchWord word: String)

	func game(_ game: Game,
			  didUpdateScore score: Int)

	func game(_ game: Game,
			  didUpdateTime timeInSeconds: TimeInterval)

	func gameDidLose(_ game: Game)

	func gameDidWin(_ game: Game)

}
