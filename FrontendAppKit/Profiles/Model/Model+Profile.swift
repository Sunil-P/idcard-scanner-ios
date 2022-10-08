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
        let name: String
        let email: String
        let cardImage: UIImage
        let profilePic: UIImage

        var parsedText: String = ""

        init(id: UUID, name: String, email: String, cardImage: UIImage, profilePic: UIImage) {

            self.id = id
            self.name = name
            self.email = email
            self.cardImage = cardImage
            self.profilePic = profilePic
        }
    }
}
