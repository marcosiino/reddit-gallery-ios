//
//  FavoritesServiceProtocol.swift
//  RedditGallery
//
//  Created by Marco Siino on 04/03/21.
//

import Foundation

protocol FavoritesServiceProtocol {
    func addFavorite(post: Post) -> Bool
    func removeFavorite(postId: String) -> Bool
    func removeFavorite(post: Post) -> Bool
}
