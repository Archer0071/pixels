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

class ImagesViewModel: ObservableObject {
    private var currentPage: Int = 0
    private var pageSize: Int = 20 // Set an initial page size
    @Published var imagePairs: [ImageModel] = []
    var isSelected = false
    private var cancellables: Set<AnyCancellable> = []

    func fetchPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = pageSize

        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)

        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, fetchResult.count)

        if startIndex >= endIndex {
            return
        }

        var newImageModels: [ImageModel] = []

        for index in startIndex..<endIndex {
            let asset = fetchResult.object(at: index)

            let fullSizePublisher = Future<UIImage, Error> { promise in
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true

                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFill,
                    options: requestOptions
                ) { fullSizeImage, _ in
                    if let fullSizeImage = fullSizeImage {
                        promise(.success(fullSizeImage))
                    } else {
                        promise(.failure(NSError(domain: "Image Fetch Error", code: 1, userInfo: nil)))
                    }
                }
            }

            let thumbnailPublisher = Future<UIImage, Error> { promise in
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true

                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: 200, height: 200),
                    contentMode: .aspectFill,
                    options: requestOptions
                ) { thumbnailImage, _ in
                    if let thumbnailImage = thumbnailImage {
                        promise(.success(thumbnailImage))
                    } else {
                        promise(.failure(NSError(domain: "Image Fetch Error", code: 1, userInfo: nil)))
                    }
                }
            }

            Publishers.CombineLatest(fullSizePublisher, thumbnailPublisher)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching images: \(error)")
                    }
                } receiveValue: { (fullSizeImage, thumbnailImage) in
                    let imageModel = ImageModel(fullSize: fullSizeImage, thumbnail: thumbnailImage)
                    newImageModels.append(imageModel)
                }
                .store(in: &cancellables)
        }

        imagePairs.append(contentsOf: newImageModels)
        currentPage += 1
    }

    func resetPagination() {
        self.currentPage = 0
        self.pageSize = 20
        self.imagePairs = []
    }

    // Return total number of image pairs stored
    func totalImagePairs() -> Int {
        return imagePairs.count
    }

    // Return the image model by passing the index of the pair
    func imageModelAt(index: Int) -> ImageModel {
        return imagePairs[index]
    }
}
