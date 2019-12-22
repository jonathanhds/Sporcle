import UIKit

fileprivate enum Constants {
	static let CELL_IDENTIFIER = "WordCell"
}

class GameViewController: UIViewController {

	@IBOutlet private weak var tableView: UITableView! {
		didSet {
			tableView.dataSource = self
			tableView.tableFooterView = UITableViewHeaderFooterView()
		}
	}

	fileprivate var game: Game? {
		didSet {
			game?.delegate = self
		}
	}

}

// MARK: UITableViewDataSource

extension GameViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView,
				   numberOfRowsInSection section: Int) -> Int {
		game?.matchedWordsCount ?? 0
	}

	func tableView(_ tableView: UITableView,
				   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let matchedWord = game?.matchedWord(at: indexPath) else { fatalError("Could not find matched word for IndexPath: \(indexPath)") }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_IDENTIFIER) else { fatalError("Could not dequeue cell for identifier: \(Constants.CELL_IDENTIFIER)") }

		cell.textLabel?.text = matchedWord

		return cell
	}

}

// MARK: GameDelegate

extension GameViewController: GameDelegate {

	func game(_ game: Game,
			  didMatchWord word: String) {
	}

	func game(_ game: Game,
			  didUpdateTime: TimeInterval) {
	}

	func gameDidLose(_ game: Game) { }

	func gameDidWin(_ game: Game) { }

}
