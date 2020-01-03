import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, handler: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.async { handler() }
        }
        controller.addAction(okAction)

        present(controller, animated: true)
    }
}
