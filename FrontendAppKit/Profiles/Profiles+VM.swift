//
//  Profiles+VM.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

protocol Profiles_VM_Interface {

    var addNewProfileVM: AddNewProfile.VM.Interface { get }

} // Profiles_VM_Interface


extension Profiles {

    public struct VM {

        typealias Interface = Profiles_VM_Interface

    } // VM

} // Profiles
