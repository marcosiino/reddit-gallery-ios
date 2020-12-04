//
//  Favorite+CoreDataProperties.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var author: String?
    @NSManaged public var image: Data?
    @NSManaged public var permalink: String?
    @NSManaged public var postId: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var title: String?

}

extension Favorite : Identifiable {

}
