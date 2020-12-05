//
//  Post.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

struct Post: Equatable {
    let id: String
    let author: String
    let title: String
    let images: [String]
    let thumbnail: String?
    let ups: Int
    let downs: Int
    let permalink: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
