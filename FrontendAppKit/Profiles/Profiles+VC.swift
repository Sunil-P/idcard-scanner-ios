//
//  Profiles+VC.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit

import Swinject
import UIKit

class Profiles_VC: UIViewController {

    required init?(coder: NSCoder) {

        let resolver = Container.default.resolver

        self.viewModel = Profiles.VM.Factory.create(with: resolver)

        super.init(coder: coder)
    }

    public override func viewDidLoad() {

        super.viewDidLoad()
    }

    // MARK: - Overrides:

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let addNewProfileVC = segue.destination as? AddNewProfile_VC else {

            return
        }

        addNewProfileVC.setViewModel(viewModel: viewModel.addNewProfileVM)
    }

    // MARK: - Privates:

    private let viewModel: Profiles.VM.Interface

} // Profiles_VC
