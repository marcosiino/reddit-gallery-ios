//
//  CollectionHeaderSearchView.swift
//  RedditGallery
//
//  Created by Marco Siino on 06/12/2020.
//

import Foundation
import UIKit

class CollectionHeaderSearchView: UICollectionReusableView {
    
    weak var delegate: UISearchBarDelegate? {
        get {
            return searchBar.delegate
        }
        set {
            searchBar.delegate = newValue
        }
    }
    
    private let searchBar: UISearchBar
    var searchPlaceholder: String? {
        set {
            searchBar.placeholder = newValue
        }
        get {
            return searchBar.placeholder
        }
    }
        
    override init(frame: CGRect) {
        searchBar = UISearchBar(frame: frame)
        super.init(frame: frame)
        
        addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
