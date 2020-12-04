//
//  Post.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

struct Post {
    let id: String
    let author: String
    let title: String
    let images: [String]
    let thumbnail: String?
    let ups: Int
    let downs: Int
    let permalink: String
}
