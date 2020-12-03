//
//  FavoritesViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController, LocalizedTitleViewController, DataAccessEnabledProtocol {
    var dataRepository: DataRepository?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getLocalizedTitle() -> String {
        return NSLocalizedString("favorites.title", comment: "favorites.title")
    }
}
