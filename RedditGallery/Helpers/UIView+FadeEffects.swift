//
//  UIImageView+FadeEffects.swift
//  RedditGallery
//
//  Created by Marco Siino on 06/12/2020.
//

import Foundation
import UIKit

extension UIView {
    /**
     Performs a fade in effect
     - duration: the effect duration
     - resetAlpha: if true, starts with an alpha of 0.0, otherwise starts from the current alpha
     */
    func fadeIn(duration: TimeInterval = 0.5, resetAlpha: Bool = true) {
        if resetAlpha {
            alpha = 0.0
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 1.0
        }
    }
    
    /**
     Performs a fade out effect
     - duration: the effect duration
     - resetAlpha: if true, starts with an alpha of 1.0, otherwise starts from the current alpha
     */
    func fadeOut(duration: TimeInterval = 0.5, resetAlpha: Bool = true) {
        if resetAlpha {
            alpha = 1.0
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 0.0
        }
    }
}
