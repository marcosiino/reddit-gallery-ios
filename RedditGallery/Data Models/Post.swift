//
//  Post.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

class Post: Equatable {
    let id: String
    let author: String
    let title: String
    let images: [String]
    let thumbnail: String?
    let ups: Int?
    let downs: Int?
    let permalink: String
    var favorited: Bool
    
    init(id: String, author: String, title: String, images: [String], thumbnail: String?, ups: Int?, downs: Int?, permalink: String, favorited: Bool) {
        self.id = id
        self.author = author
        self.title = title
        self.images = images
        self.thumbnail = thumbnail
        self.ups = ups
        self.downs = downs
        self.permalink = permalink
        self.favorited = favorited
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    //Recheck if this post is currently favorites and updates its favorited property
    func refreshFavoriteStatus() {
        favorited = CoreDataHelper.isFavorite(postId: id)
    }
}

extension Post: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
