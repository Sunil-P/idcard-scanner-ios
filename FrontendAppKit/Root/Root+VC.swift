//
//  Root+VC.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit

import Swinject
import UIKit

public class Root_VC: UIViewController {

    required init?(coder: NSCoder) {

        let resolver = Container.default.resolver

        self.viewModel = Root.VM.Factory.create(with: resolver)

        super.init(coder: coder)
    }

    public override func viewDidLoad() {

        super.viewDidLoad()
    }

    // MARK: - Privates:

    private let viewModel: Root.VM.Interface

} // Root_VC
