//
//  CachedImage+CoreDataProperties.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//
//

import Foundation
import CoreData


extension CachedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedImage> {
        return NSFetchRequest<CachedImage>(entityName: "CachedImage")
    }

    @NSManaged public var url: String?
    @NSManaged public var image: Data?

}

extension CachedImage : Identifiable {

}
