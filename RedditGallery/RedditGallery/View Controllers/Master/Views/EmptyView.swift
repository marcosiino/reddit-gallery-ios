//
//  EmptyView.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

class EmptyView: UIView {
    @IBOutlet weak var emptyMessageLabel: UILabel?
    
    func setMessage(message: String) {
        emptyMessageLabel?.text = message
    }
}
