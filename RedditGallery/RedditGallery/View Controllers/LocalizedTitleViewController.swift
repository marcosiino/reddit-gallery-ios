//
//  LocalizedTitleViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

protocol LocalizedTitleViewController: UIViewController {
    func getLocalizedTitle() -> String
}
