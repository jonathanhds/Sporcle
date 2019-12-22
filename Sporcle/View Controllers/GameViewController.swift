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

	@IBOutlet private weak var titleLabel: UILabel!

	@IBOutlet private weak var keywordTextField: UITextField!

	@IBOutlet private weak var scoreLabel: UILabel!

	@IBOutlet private weak var timeLabel: UILabel!

	@IBOutlet private weak var startResetButton: UIButton!

	@IBOutlet private weak var controlsViewBottomConstraint: NSLayoutConstraint!

	@IBOutlet private weak var loadingView: UIView!

	@IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

	private var game: Game? {
		didSet {
			game?.delegate = self
		}
	}

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		changeLabelsDisplay(isHidden: true)
		loadQuiz()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		setupKeyboardNotifications()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		cleanUpKeyboardNotifications()
	}

	// MARK: Loading

	private func showLoadingView() {
		activityIndicatorView.startAnimating()
		loadingView.isHidden = false
	}

	private func hideLoadingView() {
		activityIndicatorView.stopAnimating()
		loadingView.isHidden = true
	}

	// MARK: Quiz logic

	private func loadQuiz() {
		showLoadingView()

		QuizService().loadQuiz() { (quiz, error) in
			DispatchQueue.main.async { [weak self] in
				self?.hideLoadingView()

				if let quiz = quiz {
					self?.prepareGame(with: quiz)
				} else if let error = error {
					self?.showMessage(forError: error) {
						self?.loadQuiz()
					}
				}
			}
		}
	}

	private func prepareGame(with quiz: Quiz) {
		titleLabel.text = quiz.title

		game = Game(words: quiz.words)
		game?.reset()

		changeLabelsDisplay(isHidden: false)
	}

	private func resetGame() {
		keywordTextField.isEnabled = false
		startResetButton.setTitle("Start", for: .normal)

		game?.reset()

		tableView.reloadData()
		keywordTextField.resignFirstResponder()
	}

	private func startGame() {
		keywordTextField.isEnabled = true
		startResetButton.setTitle("Stop", for: .normal)

		game?.start()

		keywordTextField.becomeFirstResponder()
	}

	private func changeLabelsDisplay(isHidden: Bool) {
		let alpha: CGFloat = isHidden ? 0 : 1

		titleLabel.alpha = alpha
		scoreLabel.alpha = alpha
		timeLabel.alpha = alpha
	}

	// MARK: User actions

	@IBAction private func startResetButtonClicked(_ sender: UIButton) {
		if game?.isRunning == true {
			resetGame()
		} else {
			startGame()
		}
	}

	@IBAction private func keywordTextFieldDidChange(_ sender: UITextField) {
		guard let text = sender.text else { return }
		game?.match(word: text)
	}

	// MARK: Error handling

	private func showMessage(forError error: Error,
							 completion: @escaping () -> Void) {
		let message = "Could not fetch quizzes. Please, check you Internet connection and try again."
		showAlert(title: "Error", message: message) {
			completion()
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
		DispatchQueue.main.async { [weak self] in
			self?.keywordTextField.text = ""
			self?.tableView.reloadData()
		}
	}

	func game(_ game: Game,
			  didUpdateScore score: Int) {
		DispatchQueue.main.async { [weak self] in
			self?.scoreLabel.text = "\(score)/\(game.wordsCount)"
		}
	}

	func game(_ game: Game,
			  didUpdateTime timeInSeconds: TimeInterval) {
		let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60

		DispatchQueue.main.async { [weak self] in
			self?.timeLabel.text = String(format: "%02i:%02i", minutes, seconds)
		}
	}

	func gameDidLose(_ game: Game) {
		DispatchQueue.main.async { [weak self] in
			self?.keywordTextField.resignFirstResponder()

			self?.showAlert(title: "Too bad!", message: "Oh no, It's game over! Tap OK to restart the game.") {
				self?.resetGame()
			}
		}
	}

	func gameDidWin(_ game: Game) {
		DispatchQueue.main.async { [weak self] in
			self?.keywordTextField.resignFirstResponder()

			self?.showAlert(title: "Congrats!", message: "Yay, you won! Tap OK to restart the game.") {
				self?.resetGame()
			}
		}
	}

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
