//
//  TitleLocalizable.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

/**
 A protocol implemented by view controllers which offers a method to return their localized title
 */
protocol TitleLocalizable: UIViewController {
    func getLocalizedTitle() -> String
}
