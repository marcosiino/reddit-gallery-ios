//
//  FavoritesService.swift
//  RedditGallery
//
//  Created by Marco Siino on 04/03/21.
//

import Foundation

class FavoritesService: FavoritesServiceProtocol {
    func addFavorite(post: Post) -> Bool {
        let res = CoreDataHelper.saveFavorite(post: post)
        if res == true {
            NotificationCenter.default.post(name: .addedFavorite, object: post.id)
        }
        return res
    }
    
    func removeFavorite(postId: String) -> Bool {
        let res = CoreDataHelper.removeFavorite(postId: postId)
        if res == true {
            NotificationCenter.default.post(name: .removedFavorite, object: postId)
        }
        return res
    }
    
    func removeFavorite(post: Post) -> Bool {
        let res = removeFavorite(postId: post.id)
        if res == true {
            NotificationCenter.default.post(name: .removedFavorite, object: post.id)
        }
        return res
    }
}
