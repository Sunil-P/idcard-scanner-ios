//
//  Profiles+VM.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import RxCocoa

protocol Profiles_VM_Interface {

    var profiles: Driver<[Model.Profile]> { get }

    var addNewProfileVM: AddNewProfile.VM.Interface { get }

} // Profiles_VM_Interface


extension Profiles {

    public struct VM {

        typealias Interface = Profiles_VM_Interface

    } // VM

} // Profiles
