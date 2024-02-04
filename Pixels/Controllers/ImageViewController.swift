//
//  ImageViewController.swift
//  Pixels
//
//  Created by ARCHER on 30/05/2023.
//

import Foundation
import UIKit

class ImageViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    var fullSizeImage: UIImage

    init(fullSizeImage: UIImage) {
        self.fullSizeImage = fullSizeImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        return panGesture
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = fullSizeImage
        imageView.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)

        // Add the pan gesture recognizer to the imageView
        imageView.addGestureRecognizer(panGesture)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if imageView.contentMode == .scaleAspectFill {
            animateZoomIn()
        } else {
            animateZoomOut()
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        if gesture.state == .changed || gesture.state == .ended {
            let currentScale = view.frame.size.width / view.bounds.size.width
            var newScale = currentScale * gesture.scale

            if newScale < 1.0 {
                newScale = 1.0
            }
            if newScale > 3.0 {
                newScale = 3.0
            }

            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            view.transform = transform

            gesture.scale = 1.0
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        let translation = gesture.translation(in: view.superview)

        switch gesture.state {
        case .changed:
            // Update the position of the imageView based on the pan gesture translation
            view.transform = CGAffineTransform(translationX: 0, y: translation.y)

        case .ended:
            // Calculate the vertical velocity to determine if the image should be dismissed
            let velocity = gesture.velocity(in: view.superview)
            let isFlickDown = velocity.y > 1000.0

            if translation.y > view.bounds.height * 0.3 || isFlickDown {
                navigationController?.popViewController(animated: true)
            } else {
                // Otherwise, animate back to the original position
                UIView.animate(withDuration: 0.3) {
                    view.transform = .identity
                }
            }

        default:
            break
        }
    }

    private func animateZoomIn() {
        UIView.animate(withDuration: 0.3) {
            self.imageView.contentMode = .scaleAspectFit
        }
    }

    private func animateZoomOut() {
        UIView.animate(withDuration: 0.3) {
            self.imageView.contentMode = .scaleAspectFill
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }

    private func setupUI() {
        setupImageView()
    }

    private func setupImageView() {
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001).translatedBy(x: -self.view.bounds.width, y: 0)
            }) { _ in
                self.view.transform = .identity
            }
        }
    }
}
