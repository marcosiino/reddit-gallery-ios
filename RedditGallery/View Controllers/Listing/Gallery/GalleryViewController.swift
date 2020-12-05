//
//  GalleryViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
class GalleryViewController: ListingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBoxPlaceholder(placeholder: NSLocalizedString("gallery.searchbar.placeholder", comment: "gallery.searchbar.placeholder"))
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
}
