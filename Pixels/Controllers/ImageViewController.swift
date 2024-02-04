//
//  ImageViewController.swift
//  Pixels
//
//  Created by ARCHER on 30/05/2023.
//

import Foundation
import UIKit
import UIKit

class ImageViewController: UIViewController {
    // MARK: - Properties
    var fullSizeImage:UIImage
    init(fullSizeImage:UIImage) {
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
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = fullSizeImage
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    // MARK: - UI Setup
    
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
               // Apply a scaling and translation transformation for the bounce effect during dismissal
               UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                   self.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001).translatedBy(x: -self.view.bounds.width, y: 0)
               }) { _ in
                   self.view.transform = .identity
               }
           }
       }
}
