//
//  Model.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import UIKit

import RxSwift
import ImageAnalyticsKit

protocol Model_Data: AnyObject {

    var profiles: Observable<[Model.Profile]> { get }

    func process(image: UIImage, type: Model.ImageType) -> Single<(UIImage, String)>

    func saveProfile(profile: Model.Profile) -> Completable
}

struct Model {

    typealias Interface = Model_Data

    enum ImageType {

        case profilePic
        case idCard

        var imageAnalyticsType: ImageAnalytics.VisionManager.ImageType {

            switch self {
            case .profilePic: return .profilePicture
            case .idCard: return .idCard
            }
        }
    }

    enum Error: LocalizedError {

        case cannotCreateProfileExists

        var errorDescription: String? {

            switch self {

            case .cannotCreateProfileExists: return "Cannot create new profile, profile already exists."
            }
        }
    }

} // Model
