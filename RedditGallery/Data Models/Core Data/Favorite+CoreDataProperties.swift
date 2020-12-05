//
//  Favorite+CoreDataProperties.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var author: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var permalink: String?
    @NSManaged public var postId: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var title: String?

}

extension Favorite : Identifiable {

}
