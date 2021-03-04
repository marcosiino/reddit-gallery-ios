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
    static let addedFavorite = NSNotification.Name(rawValue: "notificationFavoritesAdded")
    static let removedFavorite = NSNotification.Name(rawValue: "notificationFavoritesRemoved")
}

/**
 DataRepository interface
 */
protocol DataRepositoryProtocol {
    func getPosts(searchKeyword keyword: String, afterId: String?, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () )
    func supportsPaging() -> Bool //returns true if the datarepository supports loading more data (in this case you must pass the afterId parameter to getPosts to fetch the other posts after the given afterId
}
