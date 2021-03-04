//
//  DataRepositoryInjectable.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

/**
 A protocol which indicates that the class has a method to inject a DataRepository
 */
protocol DataRepositoryInjectable {
    var dataRepository: DataRepositoryProtocol? { get set }
}
