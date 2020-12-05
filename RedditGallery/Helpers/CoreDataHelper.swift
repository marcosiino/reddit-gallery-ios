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

    static func isFavorite(postId: String) -> Bool {
        let request : NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "postId == %@", postId)
        
        if let results = try? persistentContainer.viewContext.fetch(request), results.count > 0 {
            return true
        }
        else {
            return false
        }
        
    }
    
    static func saveFavorite(post: Post) -> Bool {
        
        let favorite = Favorite(context: persistentContainer.viewContext)
        
        favorite.title = post.title
        favorite.author = post.author
        favorite.postId = post.id
        favorite.permalink = post.permalink
        favorite.imageUrl = post.images.first
        favorite.thumbnailUrl = post.thumbnail
        
        do {
            try persistentContainer.viewContext.save()
        }
        catch(let error) {
            print(error)
            return false
        }
        
        return true
    }
    
    static func removeFavorite(postId: String) -> Bool {
        let request : NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "postId == %@", postId)
        
        if let results = try? persistentContainer.viewContext.fetch(request) {

            do {
                for favorite in results {
                    try persistentContainer.viewContext.delete(favorite)
                }
                
                try persistentContainer.viewContext.save()
            }
            catch(let error) {
                print("Can't remove favorite from db")
                //TODO: manage error
                return false
            }
        }
        
        return true
    }
}
