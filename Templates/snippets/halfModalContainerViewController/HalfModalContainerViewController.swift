//
//  {{fileName}}
//  {{projectName}}
//
//  Created by {{author}} on {{date}}.
//  {{copyright}}
//

import Foundation
import UIKit

final class HalfModalContainerViewController: UIViewController {
    private lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return bdView
    }()

    private let panelView = UIView()
    private let panelHeight: CGFloat
    private var topCornerRadius: CGFloat
    private var isPresenting = false

    private let controller: UIViewController

    init(controller: UIViewController, topCornerRadius: CGFloat = 10, panelHeight: CGFloat? = nil) {
        self.controller = controller
        self.topCornerRadius = topCornerRadius
        self.panelHeight = panelHeight ?? (UIScreen.main.bounds.height / 2)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HalfModalContainerViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension HalfModalContainerViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else {
            return
        }

        isPresenting.toggle()

        if isPresenting == true {
            containerView.addSubview(toVC.view)

            panelView.frame.origin.y += panelHeight
            backdropView.alpha = 0

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.panelView.frame.origin.y -= self.panelHeight
                self.backdropView.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.panelView.frame.origin.y += self.panelHeight
                self.backdropView.alpha = 0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}

private extension HalfModalContainerViewController {
    func setupView() {
        view.addSubview(backdropView)

        panelView.layer.cornerRadius = topCornerRadius
        panelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panelView.clipsToBounds = true

        panelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panelView)
        NSLayoutConstraint.activate([
            panelView.heightAnchor.constraint(equalToConstant: panelHeight),
            panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // add child view controller view to container

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: panelView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: panelView.bottomAnchor)
        ])

        controller.didMove(toParent: self)
    }
}
