import UIKit

private enum Constants {
	static let CELL_IDENTIFIER = "WordCell"
	static let DEFAULT_KEYBOARD_ANIMATION_DURATION: NSNumber = 0.3
}

final class GameViewController: UIViewController {

	@IBOutlet private weak var tableView: UITableView! {
		didSet {
			tableView.dataSource = self
			tableView.tableFooterView = UITableViewHeaderFooterView()
		}
	}

	@IBOutlet private weak var controlsViewBottomConstraint: NSLayoutConstraint!

	private var game: Game? {
		didSet {
			game?.delegate = self
		}
	}

	// MARK: Life cycle

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		setupKeyboardNotifications()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		cleanUpKeyboardNotifications()
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

// MARK: Keyboard

private extension GameViewController {

	func setupKeyboardNotifications() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillShow),
											   name: UIResponder.keyboardWillShowNotification,
											   object: nil)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillHide),
											   name: UIResponder.keyboardWillHideNotification,
											   object: nil)
	}

	func cleanUpKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self,
												  name: UIResponder.keyboardWillShowNotification,
												  object: nil)

		NotificationCenter.default.removeObserver(self,
												  name: UIResponder.keyboardWillHideNotification,
												  object: nil)
	}

	@objc func keyboardWillShow(_ notification: Notification) {
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

		moveControlsView(constant: keyboardFrame.cgRectValue.height,
						 notification: notification)
	}

	@objc func keyboardWillHide(_ notification: Notification) {
		moveControlsView(constant: 0,
						 notification: notification)
	}

	func moveControlsView(constant: CGFloat,
						  notification: Notification) {
		let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? Constants.DEFAULT_KEYBOARD_ANIMATION_DURATION

		controlsViewBottomConstraint.constant = constant

		UIView.animate(withDuration: animationDuration.doubleValue) {
			self.view.layoutIfNeeded()
		}
	}

}
