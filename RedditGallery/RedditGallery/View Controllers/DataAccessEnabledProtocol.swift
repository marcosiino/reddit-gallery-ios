//
//  DataAccessViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

protocol DataAccessEnabledProtocol {
    var dataRepository: DataRepository? { get set }
}
