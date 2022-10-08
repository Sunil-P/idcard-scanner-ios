//
//  VisionManager+Impl.swift
//  ImageAnalyticsKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import CommonKit

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

        public static func register(with container: Container) {

            container.register(Interface.self) { _ in

                Impl()
            }
            .inObjectScope(.transient)
        }

        public static func create(with resolver: Resolver) -> Interface {

            resolver.resolve(Interface.self)!
        }

    } // Factory

    // MARK: -

    public class Impl: Interface {

        init() {

            print("VisionManager initialized.")
        }

        deinit {

            print("VisionManager deinitalized.")
        }

        // MARK: - Interface:

        public func processPicture(image: UIImage) -> Single<UIImage> {

            .create { single in

                single(.success(.init(named: "person.icloud.fill")!))
                return Disposables.create {}
            }
        }

        public func processIdCard(image: UIImage) -> Single<(UIImage, String)> {

            .create { [weak self] single in

                // Convert from UIImageOrientation to CGImagePropertyOrientation.
                let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)

                // Fire off request based on URL of chosen photo.
                guard let cgImage = image.cgImage else {

                    single(.failure(VisionError.genericVisionError))
                    return Disposables.create { }
                }

                // TODO: Aspect/Perspective correction for image ?

                self?.idCardImageRequestClosure = { parsedText in

                    if parsedText.isEmpty {

                        single(.failure(VisionError.notAnIdCard))

                    } else {

                        single(.success((image, parsedText)))
                    }
                }

                self?.performVisionRequest(

                    image: cgImage,
                    orientation: cgOrientation ,
                    requestType: .idCard
                )

                return Disposables.create { }
            }
        }

        // MARK: - Privates:

        private var idCardImageRequestClosure: ((String)->())?
        private var idCardImageRectRequestClosure: ((CGRect)->())?

        private enum VisionRequestType {

            case idCard
            case profilePicture
        }

        private lazy var textRecognizeRequest = VNRecognizeTextRequest(

            completionHandler: self.handleDetectedRecognizedText
        )
        private lazy var textDetectionRequest = { () -> VNDetectTextRectanglesRequest in

            let request = VNDetectTextRectanglesRequest(completionHandler: self.handleDetectedText)
            request.reportCharacterBoxes = true
            return request
        }()
        private lazy var rectangleDetectionRequest = { () -> VNDetectRectanglesRequest in

            let request = VNDetectRectanglesRequest(

                completionHandler: self.handleDetectedRectangles
            )
            request.maximumObservations = 1 // Vision currently supports up to 16.
            request.minimumConfidence = 0.8 // Be confident.
            request.minimumAspectRatio = 0.3 // height / width

            return request
        }()
        private lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(

            completionHandler: self.handleDetectedFaces
        )
        private lazy var faceLandmarkRequest = VNDetectFaceLandmarksRequest(

            completionHandler: self.handleDetectedFaceLandmarks
        )

        fileprivate func handleDetectedRectangles(request: VNRequest?, error: Error?) {

            if let _ = error as NSError? {
                return
            }

            guard let results = request?.results as? [VNRectangleObservation] else {
                return
            }

            guard let firstResult = results.first else {
                return
            }

            idCardImageRectRequestClosure?(firstResult.boundingBox)
        }

        fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
            if let nsError = error as NSError? {
    //            self.presentAlert("Face Detection Error", error: nsError)
    //            return
            }
            // Perform drawing on the main thread.
            DispatchQueue.main.async {
    //            guard let drawLayer = self.pathLayer,
    //                let results = request?.results as? [VNFaceObservation] else {
    //                    return
    //            }
    //            self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
    //            drawLayer.setNeedsDisplay()
            }
        }

        fileprivate func handleDetectedFaceLandmarks(request: VNRequest?, error: Error?) {
            if let nsError = error as NSError? {
    //            self.presentAlert("Face Landmark Detection Error", error: nsError)
                return
            }
            // Perform drawing on the main thread.
            DispatchQueue.main.async {
    //            guard let drawLayer = self.pathLayer,
    //                let results = request?.results as? [VNFaceObservation] else {
    //                    return
    //            }
    //            self.drawFeatures(onFaces: results, onImageWithBounds: drawLayer.bounds)
    //            drawLayer.setNeedsDisplay()
            }
        }

        fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
            if let nsError = error as NSError? {
    //            self.presentAlert("Text Detection Error", error: nsError)
                return
            }
            // Perform drawing on the main thread.
            DispatchQueue.main.async {
    //            guard let drawLayer = self.pathLayer,
    //                let results = request?.results as? [VNTextObservation] else {
    //                    return
    //            }
    //            self.draw(text: results, onImageWithBounds: drawLayer.bounds)
    //            drawLayer.setNeedsDisplay()
            }
        }

        fileprivate func handleDetectedRecognizedText(request: VNRequest?, error: Error?) {

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
        private func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation, requestType: VisionRequestType) {

            // Fetch desired requests based on switch status.
            let requests = createVisionRequests(requestType: requestType)
            // Create a request handler.
            let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                            orientation: orientation,
                                                            options: [:])
            // Send the requests to the request handler.
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform(requests)
                } catch let error as NSError {
                    print("Failed to perform image request: \(error)")
                    return
                }
            }
        }

        /// - Tag: CreateRequests
        private func createVisionRequests(requestType: VisionRequestType) -> [VNRequest] {

            // Create an array to collect all desired requests.
            var requests: [VNRequest] = []

            switch requestType {

            case .idCard:

                requests.append(self.rectangleDetectionRequest)
                requests.append(self.textDetectionRequest)
                requests.append(self.textRecognizeRequest)

            case .profilePicture:

                requests.append(self.faceDetectionRequest)
                requests.append(self.faceLandmarkRequest)
            }

            // Return grouped requests as a single array.
            return requests
        }

    } // VisionManager
}
