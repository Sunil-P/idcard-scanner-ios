//
//  ImageAnalytics+VisionManager.swift
//  ImageAnalyticsKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import RxSwift
import UIKit

public protocol ImageAnalytics_VisionManager {

    func process(image: UIImage, type: ImageAnalytics.VisionManager.ImageType) -> Single<(UIImage, String)>

}

extension ImageAnalytics {

    public struct VisionManager {

        public typealias Interface = ImageAnalytics_VisionManager

        public enum ImageType {

            case profilePicture
            case idCard
        }

        public enum VisionError: LocalizedError {

            case genericVisionError
            case notAnIdCard
            case multipleFaces
            case noFaces

            public var errorDescription: String? {
                switch self {
                case .genericVisionError: return "Generic error occured."
                case .notAnIdCard: return "Selected image is not an id card. Please try again."
                case .multipleFaces: return "Selected image has multiple faces. Please try again."
                case .noFaces: return "Selected image has no faces. Please try again."
                }
            }
        }

    } // VisionManager

} // ImageAnalytics
