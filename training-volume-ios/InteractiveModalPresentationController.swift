import UIKit

class InteractiveModalPresentationController: UIPresentationController {
    private var direction: UISwipeGestureRecognizer.Direction

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: UISwipeGestureRecognizer.Direction) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupSwipeGestureRecognizer()
    }

    private func setupSwipeGestureRecognizer() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizer.direction = direction
        presentedViewController.view.addGestureRecognizer(swipeGestureRecognizer)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
}
