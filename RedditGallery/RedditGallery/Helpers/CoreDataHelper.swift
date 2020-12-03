//
//  CoreDataHelper.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation
import UIKit
import CoreData

class CoreDataHelper {
    
    var persistentContainer: NSPersistentContainer {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
    }
    
    func getCachedImage(url: String) -> CachedImage {
        
    }

    
}
