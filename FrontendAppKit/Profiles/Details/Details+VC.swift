//
//  Details+VC.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

import UIKit

class Details_VC: UIViewController {

    var profile: Model.Profile?

    override func viewDidLoad() {

        super.viewDidLoad()

        print("Details.VC loaded.")

        if let profile = profile {

            self.idCardImageView.image = profile.cardImage
            self.profilePicImageView.image = profile.profilePic
            self.title = profile.email
            self.parsedTextView.text = profile.parsedText
            self.parsedTextView.isEditable = false
        }
    }

    func setObject(profile: Model.Profile) {

        self.profile = profile
    }

    // MARK: - IBOutlets:
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var idCardImageView: UIImageView!
    @IBOutlet weak var parsedTextView: UITextView!


}
