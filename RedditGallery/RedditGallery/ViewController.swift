//
//  ViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import UIKit

class ViewController: UIViewController {

    let client = RedditClient()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.request(endpoint: .top(keyword: "cats")) { (response) in
            switch(response) {
            case .success(let responseModel, let httpStatusCode):
                break
            case .error(let error, let httpStatusCode):
                //TODO: show error
                break
            }
        }
    }


}

