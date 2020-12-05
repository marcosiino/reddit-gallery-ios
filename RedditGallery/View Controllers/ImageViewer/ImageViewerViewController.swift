//
//  ImageViewerViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
import UIKit

/**
 A view controller which allows to view an image with pinch to zoom feature
 */

class ImageViewerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var scrollView: UIScrollView?
    
    var image: UIImage?
    
    static func instantiate(image: UIImage) -> ImageViewerViewController {
        let vc = UIStoryboard(name: "ImageViewer", bundle: nil).instantiateViewController(identifier: "ImageViewerViewController") as! ImageViewerViewController
        
        vc.image = image
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.minimumZoomScale = 1.0
        scrollView?.maximumZoomScale = 3.0
        
        let tapToZoomGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToZoom))
        tapToZoomGestureRecognizer.numberOfTapsRequired = 2
        scrollView?.addGestureRecognizer(tapToZoomGestureRecognizer)
        
        self.imageView?.image = image
    }
    
    @objc func tapToZoom() {
        //Every time a double tap is performed, zoom to maximum zoom if the current zoom is less than 1.5, or to minimumScale if the current zoom is greater or equal than 1.5
        if let scrollView = scrollView {
            if scrollView.zoomScale < 1.5 {
                scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
            }
            else {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
