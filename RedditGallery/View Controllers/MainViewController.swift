//
//  MainViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Settings localized titles for viewcontrollers within tabs, at the time the MainViewController is loaded, because setting them in each viewController's viewDidLoad would set the title only when each viewcontroller is loaded (when the user click on their tabs)
        if let viewControllers = viewControllers {
            for tabVC in viewControllers {
                if let tabNavViewController = tabVC as? UINavigationController {
                    //Setting localized titles to view controllers which adheres to LocalizedTitleViewController
                    if let titleLocalizableVC = tabNavViewController.viewControllers.first as? TitleLocalizable {
                        titleLocalizableVC.title = titleLocalizableVC.getLocalizedTitle()
                    }
                    
                    //Injecting RedditDataRepository to viewcontrollers which  adheres to DataAccessViewController interface
                    if var dataRepoInjectableVC = tabNavViewController.viewControllers.first as? DataRepositoryInjectable {
                        dataRepoInjectableVC.dataRepository = RedditDataRepository()
                    }
                }
            }
        }
    }
}

