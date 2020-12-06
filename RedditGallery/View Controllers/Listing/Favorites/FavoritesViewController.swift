//
//  FavoritesViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

class FavoritesViewController: ListingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBarPlaceholderText(text: NSLocalizedString("favorites.searchbar.placeholder", comment: "favorites.searchbar.placeholder"))
        setEmptyStateMessage(text: NSLocalizedString("favorites.initialEmptyMessage", comment: "favorites.initialEmptyMessage"))
        
    }
    
    override func favoritesChanged() {
        super.favoritesChanged()
        //When favorites changes, call the search function again to requery the favorites
        search(keyword: lastSearchKeyword ?? "")
    }
    
    override func updateUI() {
        super.updateUI()
        
        if let posts = posts, posts.count == 0 {
            if getLastSearchKeyword() != "" {
                setEmptyStateMessage(text: NSLocalizedString("favorites.noResults", comment: "favorites.noResults"))
            }
            else {
                setEmptyStateMessage(text: NSLocalizedString("favorites.initialEmptyMessage", comment: "favorites.initialEmptyMessage"))
            }
        }
    }
    
}
