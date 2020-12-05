//
//  DataRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation

enum DataRepositoryResult<T> {
    case success(T)
    case error(Error?)
}

extension Notification.Name {
    static let favoritesChanged = NSNotification.Name(rawValue: "notificationFavoritesChanged")
}

/**
 DataRepository interface
 */
protocol DataRepository {
    func getPosts(searchKeyword keyword: String, afterId: String?, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () )
    func supportsPaging() -> Bool //returns true if the datarepository supports loading more data (in this case you must pass the afterId parameter to getPosts to fetch the other posts after the given afterId
    
    func addFavorite(post: Post) -> Bool
    func removeFavorite(postId: String) -> Bool
    func removeFavorite(post: Post) -> Bool
}

extension DataRepository {
    func addFavorite(post: Post) -> Bool {
        let res = CoreDataHelper.saveFavorite(post: post)
        if res == true {
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
        }
        return res
    }
    
    func removeFavorite(postId: String) -> Bool {
        let res = CoreDataHelper.removeFavorite(postId: postId)
        if res == true {
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
        }
        return res
    }
    
    func removeFavorite(post: Post) -> Bool {
        let res = removeFavorite(postId: post.id)
        if res == true {
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
        }
        return res
    }
}
