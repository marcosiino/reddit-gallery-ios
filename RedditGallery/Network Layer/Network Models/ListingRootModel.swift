//
//  ListingRootModel.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

class ListingRootModel: Codable, RedditResponse {
    let kind: String
    let data: ListingDataModel
}
