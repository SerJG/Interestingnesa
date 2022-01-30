//
//  Helpers.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import UIKit

struct NetworkAPI {
    // URLs
    static let baseURLString = "https://api.flickr.com/services/rest"
    static let liveBaseURLString = "https://live.staticflickr.com"
    // Methods
    static let interestingPhotosMethod = "flickr.interestingness.getList"
    
    // Set your API key
    static let apiKey = ""  // NB!!! <---
}

extension NetworkAPI {
    static func interestingPhotosURLString(quantity: Int = 50) -> String {
        "\(baseURLString)/?method=\(interestingPhotosMethod)&api_key=\(apiKey)&format=json&nojsoncallback=1&per_page=\(quantity)"
    }
}

extension PhotoInfo {
    func photoURLString() -> String {
        "\(NetworkAPI.liveBaseURLString)/\(self.server)/\(self.id)_\(self.secret).jpg"
    }
}

extension UIStoryboard {
    static let mainStoryboardID = "Main"
}

extension LoadPhotosViewController {
    static let storyboardID = "LoadPhotosViewControllerID"
}

extension ResultsViewController {
    static let storyboardID = "ResultsViewControllerID"
}
