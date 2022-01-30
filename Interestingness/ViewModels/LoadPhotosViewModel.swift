//
//  LoadPhotosViewModel.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import Foundation
import UIKit

class LoadPhotosViewModel {

    private let photosProvider: PhotosProvider
    
    /// Queues for thread-safe read-write
    private let saveValuesQueue = DispatchQueue(label: "com.interesingness.LoadPhotosViewModel.values",
                                                    qos: .userInitiated,
                                                    attributes: .concurrent)
    private let savePhotosListQueue = DispatchQueue(label: "com.interesingness.LoadPhotosViewModel.photos",
                                                    qos: .userInitiated,
                                                    attributes: .concurrent)
    
    private var _totalRecievedBytes: Int = 0
    /// Thread-safe property for total amount of recieved bytes
    private(set) var totalRecievedBytes: Int {
        get {
            return self.saveValuesQueue.sync { _totalRecievedBytes }
        }
        set {
            self.saveValuesQueue.async(flags: .barrier) {
                self._totalRecievedBytes = newValue
                if let onLoadImageUpdate = self.onLoadImageUpdate {
                    DispatchQueue.main.async {
                        onLoadImageUpdate()
                    }
                }
            }
        }
    }
    
    private var _numberOfRequestedPhotos: Int = 0
    /// Thread-safe property for amount of requested photos
    private(set) var numberOfRequestedPhotos: Int {
        get {
            return self.saveValuesQueue.sync { _numberOfRequestedPhotos }
        }
        set {
            self.saveValuesQueue.async(flags: .barrier) {
                self._numberOfRequestedPhotos = newValue
                if let onLoadImageUpdate = self.onLoadImageUpdate {
                    DispatchQueue.main.async {
                        onLoadImageUpdate()
                    }
                }
            }
        }
    }
    
    private var photos: [PhotoInfo] = []
    /// Thread-safe getter for loaded images count
    func numberOfLoadedImages() -> Int {
        var result = 0
        self.savePhotosListQueue.sync { result = self.photos.count }
        return result
    }
    
    // MARK: - Life cycle
    init(imageProvider: PhotosProvider) {
        self.photosProvider = imageProvider
    }
    
    // MARK: - Model callbacks
    /// Callback for each image load update. Invokes on main thread
    var onLoadImageUpdate: (()->Void)?
    /// Callback for error durin loading image. Invokes on main thread
    var onError: ((PhotosLoadError)->Void)?
    /// Callback for finishing image loading. Invokes on main thread
    var onLoadFinish: ((Int, TimeInterval)->Void)?
    
    // MARK: - Model actions
    func requestPhotos() {
        self.photosProvider.fetchPhotos()
    }
}

// MARK: - PhotosProviderDelegate
extension LoadPhotosViewModel: PhotosProviderDelegate {
    
    func didRecieveTotalPhotosInfo(numberOfPhotos: Int) {
        self.numberOfRequestedPhotos = numberOfPhotos
    }
    
    func didRecievePhotoData(_ photo: PhotoInfo) {
        savePhotosListQueue.async(flags: .barrier) {
            self.photos.append(photo)
        }
        self.totalRecievedBytes += photo.imageData!.count
    }
    
    func didFinishLoadPhotos(loadTime: TimeInterval) {
        if let onLoadFinish = self.onLoadFinish {
            DispatchQueue.main.async {
                onLoadFinish(self.totalRecievedBytes, loadTime)
            }
        }
    }
    
    func didFailToLoadPhotos(error: PhotosLoadError) {
        if let onError = self.onError {
            DispatchQueue.main.async {
                onError(error)
            }
        }
    }
}
