//
//  ImagesViewModel.swift
//  Pixels
//
//  Created by ARCHER on 30/05/2023.
//

import Foundation
import Photos
import UIKit
import Combine
class ImagesViewModel:ObservableObject {
    private var currentPage: Int = 0
    private var pageSize: Int = 20 // Set an initial page size
    var images: [UIImage] = []
    func fetchPhotos(completion: @escaping ([UIImage], Bool) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = pageSize

        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)

        var newImages: [UIImage] = []

        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, fetchResult.count)

        if startIndex >= endIndex {
            completion([], false)
            return
        }

        for index in startIndex..<endIndex {
            let asset = fetchResult.object(at: index)
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 200, height: 200),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    newImages.append(image)
                }
            }
        }

        images.append(contentsOf: newImages)
        currentPage += 1

        // Check if there are more images available
        let hasMoreImages = fetchResult.count > currentPage * pageSize

        completion(newImages, hasMoreImages)
    }

    func resetPagination(){
        self.currentPage = 0
        self.pageSize = 20
    }
    //return total No of Images stored
    func totalImages() -> Int {
        return images.count
    }
    // return the image by passing the indexPath of cell
    func imageAt(indexPath:IndexPath) -> UIImage {
       return images[indexPath.row]
    }
}
