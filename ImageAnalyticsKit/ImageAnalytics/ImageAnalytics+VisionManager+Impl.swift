//
//  VisionManager+Impl.swift
//  ImageAnalyticsKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import CommonKit

import Dispatch
import UIKit
import RxSwift
import Swinject
import Vision

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

extension ImageAnalytics.VisionManager {

    public struct Factory {

        public static func register(with container: Container, dispatchQueue: DispatchQueueType? = nil) {

            container.register(Interface.self) { _ in

                let dispatchQueue = dispatchQueue ?? DispatchQueue.main

                return Impl(dispatchQueue: dispatchQueue)
            }
            .inObjectScope(.transient)
        }

        public static func create(with resolver: Resolver) -> Interface {

            resolver.resolve(Interface.self)!
        }

    } // Factory

    // MARK: -

    public class Impl: Interface {

        init(dispatchQueue: DispatchQueueType) {

            self.dispatchQueue = dispatchQueue
            print("VisionManager initialized.")
        }

        deinit {

            print("VisionManager deinitalized.")
        }

        // MARK: - Interface:

        public func process(

            image: UIImage,
            type: ImageAnalytics.VisionManager.ImageType

        ) -> Single<(UIImage, String)> {

            .create { [weak self] single in

                // Convert from UIImageOrientation to CGImagePropertyOrientation.
                let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)

                // Fire off request based on URL of chosen photo.
                guard let cgImage = image.cgImage else {

                    single(.failure(VisionError.genericVisionError))
                    return Disposables.create { }
                }

                // TODO: Aspect/Perspective correction for image ?

                switch type {

                case .profilePicture: {

                    self?.profilePictureRequestClosure = { detectedFaces in

                        switch detectedFaces {

                        case let x where x <= 0: single(.failure(VisionError.noFaces))
                        case 1: single(.success((image, "")))
                        case let x where x > 0: single(.failure(VisionError.multipleFaces))
                        default: single(.failure(VisionError.genericVisionError))
                        }
                    }
                }()
                case .idCard: {

                    self?.idCardImageRequestClosure = { parsedText in

                        if parsedText.isEmpty {

                            single(.failure(VisionError.notAnIdCard))

                        } else {

                            single(.success((image, parsedText)))
                        }
                    }
                }()
                }

                self?.performVisionRequest(

                    image: cgImage,
                    orientation: cgOrientation,
                    requestType: type
                )

                return Disposables.create { }
            }
        }

        // MARK: - Privates:

        private let dispatchQueue: DispatchQueueType

        private var idCardImageRequestClosure: ((String)->())?
        private var profilePictureRequestClosure: ((Int)->())?

        private lazy var textRecognizeRequest = VNRecognizeTextRequest(

            completionHandler: self.handleDetectedRecognizedText
        )
        private lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(

            completionHandler: self.handleDetectedFaces
        )

        private func handleDetectedFaces(request: VNRequest?, error: Error?) {

            if let _ = error as NSError? {
                return
            }

            guard let results = request?.results as? [VNFaceObservation] else {
                return
            }

            profilePictureRequestClosure?(results.count)
        }

        private func handleDetectedRecognizedText(request: VNRequest?, error: Error?) {

            if let nsError = error as NSError? {

                print("Error: \(nsError.localizedDescription)")
                return
            }

            guard let request = request else { return }

            guard let results = request.results as? [VNRecognizedTextObservation] else { return }

            var fullText = ""
            let textResults = results.map { $0.topCandidates(1).first?.string }
            for text in textResults {
                guard let candidate = text else { continue }
                fullText.append(candidate + "\n")
            }

            idCardImageRequestClosure?(fullText)
        }

        /// - Tag: PerformRequests
        private func performVisionRequest(

            image: CGImage,
            orientation: CGImagePropertyOrientation,
            requestType: ImageType

        ) {

            // Fetch desired requests based on switch status.
            let requests = createVisionRequests(requestType: requestType)
            // Create a request handler.
            let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                            orientation: orientation,
                                                            options: [:])
            // Send the requests to the request handler.
                dispatchQueue.async {
                do {
                    try imageRequestHandler.perform(requests)
                } catch let error as NSError {
                    print("Failed to perform image request: \(error)")
                    return
                }
            }
        }

        /// - Tag: CreateRequests
        private func createVisionRequests(requestType: ImageType) -> [VNRequest] {

            // Create an array to collect all desired requests.
            var requests: [VNRequest] = []

            switch requestType {

            case .idCard:

                requests.append(self.textRecognizeRequest)

            case .profilePicture:

                requests.append(self.faceDetectionRequest)
            }

            // Return grouped requests as a single array.
            return requests
        }

    } // VisionManager
}
