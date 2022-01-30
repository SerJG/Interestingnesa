//
//  PhotosProvider.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import Foundation

protocol PhotosProviderDelegate: AnyObject {
    /// Update with amount of images to download
    func didRecieveTotalPhotosInfo(numberOfPhotos: Int);
    /// Update with image data loaded
    func didRecievePhotoData(_ data: PhotoInfo);
    /// Update with duration time when all images are loaded
    func didFinishLoadPhotos(loadTime:TimeInterval);
    /// Update with error during  loading images
    func didFailToLoadPhotos(error: PhotosLoadError);
}

enum PhotosLoadError: Error {
    /// Error on getting list of interesing photos
    case GetPhotosListError
    /// Error on fail load photo's image data
    case LoadPhotoDataError
    /// Error on photos request timeout
    case LoadTimeoutError
}

class PhotosProvider {
    /// Deleate for reciveing image laoding callbacks
    weak var delegate: PhotosProviderDelegate?
    /// Custom URL session for image loading process
    private let urlSession: URLSession
    
    // MARK: - Life cycle
    init() {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    
    // Public methods
    
    /// Start interesting photos request 
    func fetchPhotos() {
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            
            guard let self = self else { return }
            
            // Dispatch group to syncronize completion
            let dispatchGroup = DispatchGroup()
            let startTime = Date()
            var isCanceled = false
            
            guard let requestURL = URL(string: NetworkAPI.interestingPhotosURLString()) else { return }
            dispatchGroup.enter()
            
            // 1. Get list of available images info
            self.urlSession.dataTask(with: requestURL) { [weak self] data, response, error in
                
                defer { dispatchGroup.leave() }
                guard let self = self else { return }
                
                if error != nil {
                    self.delegate?.didFailToLoadPhotos(error: .GetPhotosListError)
                    isCanceled = true
                    return
                } else if let data = data {
                    let photosInfoList = try? JSONDecoder().decode(InteresingPhotoResponse.self, from: data)
                    if let photos =  photosInfoList?.photos.photosList {
                        
                        self.delegate?.didRecieveTotalPhotosInfo(numberOfPhotos: photos.count)
                        // 2. Enumerate through images info list and request image data for each
                        for var photoInfo in photos {
                            // if error occured - interapt queueing new tasks to URLSession
                            if isCanceled { break }
                            
                            let urlString = photoInfo.photoURLString()
                            guard let photoRequestURL = URL(string: urlString) else { return }
                            // Default URLSessionConfiguration holds up to 6 connection to host at a time
                            // URLSession will load images upto 6 images simultaniusly
                            dispatchGroup.enter()
                            self.urlSession.dataTask(with: photoRequestURL) { [weak self] data, response, error in
                                
                                defer { dispatchGroup.leave() }
                                guard let self = self else { return }
                                
                                if error != nil {
                                    // Cancel all tasks in session
                                    self.urlSession.invalidateAndCancel()
                                    self.delegate?.didFailToLoadPhotos(error: .LoadPhotoDataError)
                                    isCanceled = true
                                    return
                                } else if let data = data {
                                    photoInfo.imageData = data
                                    self.delegate?.didRecievePhotoData(photoInfo)
                                }
                            }.resume()
                        }
                    }
                }
            }.resume()
            
            if dispatchGroup.wait(timeout: self.defaultTimeout()) == .timedOut {
                if !isCanceled {
                    // Cancel all tasks in case of timeout
                    self.urlSession.invalidateAndCancel()
                    self.delegate?.didFailToLoadPhotos(error: .LoadTimeoutError)
                }
            } else {
                if !isCanceled {
                    let time = Date().timeIntervalSince(startTime)
                    self.delegate?.didFinishLoadPhotos(loadTime: time)
                }
            }
        }
    }
}

extension PhotosProvider {
    private func defaultTimeout()->DispatchTime { .now() + 5*60 } // 5 min timeout
}
