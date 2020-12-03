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

enum DataRepositoryPostType {
    case top
}

protocol DataRepository {
    func getPosts(type: DataRepositoryPostType, forKeyword keyword: String, afterId: String?, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () )
}
