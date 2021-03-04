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
 
        
        let subredditGalleryVC = GalleryViewController(mainRepository: NewRedditImagesRepository(), topRepository: TopRedditImagesRepository(), favoritesServices: FavoritesService())
        subredditGalleryVC.title = NSLocalizedString("gallery.title", comment: "gallery.title")
        subredditGalleryVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        
        let favoritesVC = FavoritesViewController(favoritesRepository: FavoritesRepository(), favoritesService: FavoritesService())
        favoritesVC.title = NSLocalizedString("favorites.title", comment: "favorites.title")
        favoritesVC.tabBarItem.image = UIImage(systemName: "heart")
        
        viewControllers = [
            UINavigationController(rootViewController: subredditGalleryVC),
            UINavigationController(rootViewController: favoritesVC)
        ]
        
    }
}

