//
//  ImagesCollectionLayout.swift
//  Pixels
//
//  Created by ARCHER on 30/05/2023.
//

import Foundation
import UIKit

class ImagesCollectionLayout:UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        self.itemSize = CGSize(width:30, height: 30)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
