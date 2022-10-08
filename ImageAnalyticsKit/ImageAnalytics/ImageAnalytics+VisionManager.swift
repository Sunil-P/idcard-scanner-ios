//
//  ImageAnalytics+VisionManager.swift
//  ImageAnalyticsKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import RxSwift
import UIKit

public protocol ImageAnalytics_VisionManager {

    func processPicture(image: UIImage) -> Single<UIImage>
    func processIdCard(image: UIImage) -> Single<(UIImage, String)>

}

extension ImageAnalytics {

    public struct VisionManager {

        public typealias Interface = ImageAnalytics_VisionManager

        public enum VisionError: LocalizedError {

            case genericVisionError
            case notAnIdCard

            public var errorDescription: String? {
                switch self {
                case .genericVisionError: return "Generic error occured."
                case .notAnIdCard: return "Selected image is not an id card. Please try again with a different image."
                }
            }
        }

    } // VisionManager

} // ImageAnalytics
