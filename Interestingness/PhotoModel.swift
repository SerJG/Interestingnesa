//
//  PhotoModel.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import Foundation

struct PhotoInfo: Decodable {
    let id: String
    let server: String
    let secret: String
    var imageData: Data?
}

struct PhotoInfoList: Decodable {
    let photosList: [PhotoInfo]
    
    private enum CodingKeys : String, CodingKey {
        case photosList = "photo"
    }
}

struct InteresingPhotoResponse: Decodable {
    let photos: PhotoInfoList
}
