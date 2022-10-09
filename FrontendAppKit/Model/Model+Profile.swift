//
//  Profile.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import UIKit

extension Model {

    struct Profile: Identifiable {

        let id: UUID
        let email: String
        let cardImage: UIImage
        let profilePic: UIImage
        var parsedText: String = ""

        init(id: UUID, email: String, cardImage: UIImage, profilePic: UIImage, parsedText: String) {

            self.id = id
            self.email = email
            self.cardImage = cardImage
            self.profilePic = profilePic
            self.parsedText = parsedText
        }
    }
}
