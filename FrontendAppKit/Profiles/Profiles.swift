//
//  Profiles.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit

import Swinject

public struct Profiles {

    public struct Factory {

        public static func register(with container: Container) {

            VM.Factory.register(with: container)
            Model.Factory.register(with: container)

            AddNewProfile.VM.Factory.register(with: container, scheduler: nil)
        }

    } // Factory

} // Profiles
