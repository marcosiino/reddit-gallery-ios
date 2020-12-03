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
    
    static var persistentContainer: NSPersistentContainer {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
    }
    
    static func getCachedImage(url: String) -> CachedImage? {
        let request : NSFetchRequest<CachedImage> = CachedImage.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", url)
        
        if let results = try? persistentContainer.viewContext.fetch(request) {
            
            return results.first
        }
        else {
            return nil
        }
    }
    
    static func saveCachedImage(url: String, imageData: Data) -> Bool {
        let cachedImage = CachedImage(context: persistentContainer.viewContext)
        cachedImage.url = url
        cachedImage.image = imageData
        
        do {
            try persistentContainer.viewContext.save()
        }
        catch(let error) {
            print(error)
            return false
        }
        
        return true
    }
    
}
