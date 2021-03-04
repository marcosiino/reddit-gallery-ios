//
//  FavoritesRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
import CoreData

/**
 Concrete DataRepository
 */
class FavoritesRepository: DataRepositoryProtocol {
    
    /**
     Retrieves the favorited posts from the database
     - searchKeyword: the search keyword
     - completionHandler: the completion closure which returns the queried Posts. This closure is called in the main queue
     */
    
    func getPosts(searchKeyword: String, afterId: String? = nil, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () ) {
        
        //Favorites doesn't has paging
        if let _ = afterId {
            completionHandler(.success([Post]()))
            return
        }
        
        if let favorites = CoreDataHelper.getFavorites(searchKeyword: searchKeyword) {
            let posts = favorites.map { (favorite) -> Post in
                return Post(id: favorite.postId ?? "", author: favorite.author ?? "", title: favorite.title ?? "", images: [favorite.imageUrl ?? ""], thumbnail: favorite.thumbnailUrl ?? "", ups: nil, downs: nil, permalink: favorite.permalink ?? "", favorited: true)
            }
            completionHandler(.success(posts))
        }
        else {
            completionHandler(.error(nil))
        }
    }
    
    func supportsPaging() -> Bool {
        return false
    }
}
