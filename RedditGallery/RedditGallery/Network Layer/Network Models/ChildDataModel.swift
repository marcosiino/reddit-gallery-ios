//
//  ChildDataModel.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

class ChildDataModel: Codable {
    let author: String
    let title: String
    let permalink: String
    let thumbnail: String?
    let ups: Int
    let downs: Int
    let is_video: Bool
    let preview: ChildDataPreviewModel?
}

class ChildDataPreviewModel: Codable {
    let images: [ImageSetModel]
}
