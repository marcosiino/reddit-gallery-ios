//
//  MainViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Instantiating view controllers for each tab.
         Each ListingViewController has a different DataRepository injected. One for retrieving the posts from the Reddit apis, the other to retrieve posts from the saved favorites
         */
 
        
        let subredditGalleryVC = GalleryViewController(dataRepository: RedditDataRepository())
        subredditGalleryVC.title = NSLocalizedString("gallery.title", comment: "gallery.title")
        
        let favoritesVC = FavoritesViewController(dataRepository: FavoritesRepository())
        favoritesVC.title = NSLocalizedString("favorites.title", comment: "favorites.title")
                                                                   
        viewControllers = [
            UINavigationController(rootViewController: subredditGalleryVC),
            UINavigationController(rootViewController: favoritesVC)
        ]
        
    }
}

