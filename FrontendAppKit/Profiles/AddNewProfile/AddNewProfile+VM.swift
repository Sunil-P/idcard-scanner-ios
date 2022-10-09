//
//  AddNewProfile+VM.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import UIKit

import RxCocoa

import RxSwift

protocol AddNewProfile_VM_Interface {

    var profilePicImg: Driver<UIImage> { get }
    var idCardImg: Driver<UIImage> { get }
    var isActivityInProgress: Driver<Bool> { get }

    func selectImage(image: UIImage, type: Model.ImageType) -> Completable

    func save(

        email: String,
        profilePic: UIImage?,
        cardImage: UIImage?

    ) -> Completable

} // AddNewProfile_VM_Interface


extension AddNewProfile {

    public struct VM {

        typealias Interface = AddNewProfile_VM_Interface

    } // VM

    enum Error: LocalizedError {

        case genericError
        case modelNotInitalized
        case missingDetails
        case visionReturnedInvalidId
        case visionReturnedInvalidFace

        public var errorDescription: String? {
            switch self {
            case .genericError: return "Generic error occured."
            case .modelNotInitalized: return "Model not initialized."
            case .missingDetails: return "Missing details in setting up profile."
            case .visionReturnedInvalidId: return "Cannot use selected picture as id card. Please select another one."
            case .visionReturnedInvalidFace: return "Cannot detect face in selected pic. Please select another one."
            }
        }
    }

} // AddNewProfile
