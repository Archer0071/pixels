//
//  ImageCell.swift
//  Pixels
//
//  Created by ARCHER on 30/05/2023.
//

import Foundation
import UIKit
class ImageCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCell"
    // Add an image view or any other UI elements you need to display the image
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set up constraints for the image view
        return imageView
    }()
    
    // Add any additional setup code or UI elements for the cell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        // Set up constraints for the image view within the cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
