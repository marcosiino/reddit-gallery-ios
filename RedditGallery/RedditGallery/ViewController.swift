//
//  ViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import UIKit

class ViewController: UIViewController {

    let repo = DataRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repo.getPosts(type: .top, forKeyword: "cats") { (result) in
            switch(result) {
            case .success(let posts):
                print(posts)
            case .error(let error):
                print(error)
                //TODO: show error
                break
            }
        }
    }


}

