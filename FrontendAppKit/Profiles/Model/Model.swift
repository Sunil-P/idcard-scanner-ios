//
//  Model.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import UIKit

import RxSwift

protocol Model_Data: AnyObject {

    var profiles: Observable<[Model.Profile]> { get }

    func parseIdCard(image: UIImage) -> Single<UIImage>

    func saveProfile(profile: Model.Profile) -> Completable

    func deleteProfile(id: UUID) -> Completable
}

struct Model {

    typealias Interface = Model_Data

    enum Error: LocalizedError {

        case cannotDeleteProfileDoesntExist
        case cannotCreateProfileExists

        var errorDescription: String? {

            switch self {

            case .cannotCreateProfileExists: return "Cannot create new profile, profile already exists."
            case .cannotDeleteProfileDoesntExist: return "Cannot delete profile, profile doesnt exist."
            }
        }
    }

} // Model
