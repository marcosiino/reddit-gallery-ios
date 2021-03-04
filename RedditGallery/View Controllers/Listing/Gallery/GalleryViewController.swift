//
//  GalleryViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
class GalleryViewController: ListingViewController {
    
    convenience init(mainRepository: DataRepositoryProtocol, topRepository: DataRepositoryProtocol, favoritesServices: FavoritesServiceProtocol) {
        self.init(mode: .posts(mainRepository: mainRepository, topRepository: topRepository), favoritesService: favoritesServices)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBarPlaceholderText(text: NSLocalizedString("gallery.searchbar.placeholder", comment: "gallery.searchbar.placeholder"))
        
        setEmptyStateMessage(text: NSLocalizedString("gallery.initialEmptyMessage", comment: "gallery.initialEmptyMessage"))
    }
    
    override func favoritesChanged() {
        super.favoritesChanged()
        
        guard let posts = posts else {
            return
        }

        //When a favorite is added/removed, I update all the loaded posts favorite status
        for post in posts {
            post.refreshFavoriteStatus()
        }
    }
    
    override func updateUI() {
        super.updateUI()
        
        if let posts = posts, posts.count == 0 {
            if getLastSearchKeyword() != "" {
                setEmptyStateMessage(text: NSLocalizedString("gallery.noResults", comment: "gallery.noResults"))
            }
            else {
                setEmptyStateMessage(text: NSLocalizedString("gallery.initialEmptyMessage", comment: "gallery.initialEmptyMessage"))
            }
        }
    }
}
