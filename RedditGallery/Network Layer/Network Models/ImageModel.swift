//
//  ImageModel.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

class ImageModel: Codable {
    let url: String
    let width: Int
    let height: Int
}

class ImageSetModel: Codable {
    let source: ImageModel
    var resolutions: [ImageModel] {
        didSet {
            resolutions.sort { (first, second) -> Bool in
                return first.width*first.height < second.width*second.height
            }
        }
    }
    
    var smaller: ImageModel? {
        get {
            return resolutions.first
        }
    }
    
    var medium: ImageModel? {
        get {
            if resolutions.count == 0 {
                return nil
            }
            else if resolutions.count <= 2 {
                return resolutions.first
            }
            else {
                return resolutions[resolutions.count/2]
            }
        }
    }
    
    var original: ImageModel {
        get {
            return source
        }
    }
}
