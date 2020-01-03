import UIKit
import Combine

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

	private let viewModel: GameViewModel = GameViewModel()

	private var disposables = Set<AnyCancellable>()

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		bind(to: viewModel)

		changeLabelsDisplay(isHidden: true)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		setupKeyboardNotifications()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		viewModel.loadQuiz()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		cleanUpKeyboardNotifications()
	}

	// MARK: Binding

	private func bind(to viewModel: GameViewModel) {
		viewModel.$title
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.titleLabel.text = title
		}
		.store(in: &disposables)

		viewModel.$score
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.scoreLabel.text = title
		}
		.store(in: &disposables)

		viewModel.$time
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.timeLabel.text = title
		}
		.store(in: &disposables)

		viewModel.$isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				if isLoading {
					self?.showLoadingView()
				} else {
					self?.hideLoadingView()
				}
		}.store(in: &disposables)

		viewModel.$game
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.prepareGame()
		}.store(in: &disposables)

		viewModel.gameStarted
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.startGame()
		}
		.store(in: &disposables)

		viewModel.gameReseted
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.resetGame()
		}
		.store(in: &disposables)

		viewModel.matchedWord
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.keywordTextField.text = ""
				self?.tableView.reloadData()
		}.store(in: &disposables)

		viewModel.gameResult
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isWin in
				if isWin {
					self?.playerDidWin()
				} else {
					self?.playerDidLose()
				}
		}
		.store(in: &disposables)

		viewModel.loadingError
			.receive(on: DispatchQueue.main)
			.sink { [weak self] error in
				self?.showMessage(forError: error) {
					self?.viewModel.loadQuiz()
				}
		}.store(in: &disposables)
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

	private func prepareGame() {
		changeLabelsDisplay(isHidden: false)
	}

	private func resetGame() {
		keywordTextField.isEnabled = false
		startResetButton.setTitle("Start", for: .normal)

		viewModel.reset()

		tableView.reloadData()
		keywordTextField.resignFirstResponder()
	}

	private func startGame() {
		keywordTextField.isEnabled = true
		startResetButton.setTitle("Stop", for: .normal)

		viewModel.start()

		keywordTextField.becomeFirstResponder()
	}

	private func changeLabelsDisplay(isHidden: Bool) {
		let alpha: CGFloat = isHidden ? 0 : 1

		titleLabel.alpha = alpha
		scoreLabel.alpha = alpha
		timeLabel.alpha = alpha
	}

	// MARK: User actions

	private func playerDidLose() {
		keywordTextField.resignFirstResponder()

		showAlert(title: "Too bad!", message: "Oh no, It's game over! Tap OK to restart the game.") { [weak self] in
			self?.resetGame()
		}
	}

	private func playerDidWin() {
		keywordTextField.resignFirstResponder()

		showAlert(title: "Congrats!", message: "Yay, you won! Tap OK to restart the game.") { [weak self] in
			self?.resetGame()
		}
	}

	// MARK: User actions

	@IBAction private func startResetButtonClicked(_ sender: UIButton) {
		viewModel.startOrResetGame()
	}

	@IBAction private func keywordTextFieldDidChange(_ sender: UITextField) {
		guard let text = sender.text else { return }
		viewModel.match(word: text)
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

// MARK: - UITableViewDataSource

extension GameViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView,
				   numberOfRowsInSection section: Int) -> Int {
		viewModel.matchedWordsCount ?? 0
	}

	func tableView(_ tableView: UITableView,
				   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let matchedWord = viewModel.matchedWord(at: indexPath) else { fatalError("Could not find matched word for IndexPath: \(indexPath)") }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_IDENTIFIER) else { fatalError("Could not dequeue cell for identifier: \(Constants.CELL_IDENTIFIER)") }

		cell.textLabel?.text = matchedWord

		return cell
	}

}

// MARK: - Keyboard

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
