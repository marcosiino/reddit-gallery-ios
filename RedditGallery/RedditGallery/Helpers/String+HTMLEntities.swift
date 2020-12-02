//
//  String+HTMLEntities.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

extension String {

    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)
    }
    
    func decodeHtmlEncodedString() -> String {
        return String(htmlEncodedString: self) ?? self
    }

}
