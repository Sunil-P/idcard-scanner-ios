//
//  VisionManager+Tests.swift
//  ImageAnalyticsKitUnitTests
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

@testable import ImageAnalyticsKit

import ImageAnalyticsMocks

import UIKit
import CommonKit

import Nimble
import XCTest
import RxSwift
import Swinject
import RxTest

final class VisionManager_Tests: XCTestCase {

    private final class Mock: Disposable {

        let container = Container()
        let testScheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)
        let disposeBag = DisposeBag()
        let dispatchQueueMock = DispatchQueueMock()

        lazy var resolver = container.synchronize()

        func register() {
        }

        func dispose() {

            container.removeAll()
        }
    }
    private lazy var mock: Mock! = Mock()

    override func setUp() {

        super.setUp()

        VisionManager.Factory.register(with: mock.container, dispatchQueue: mock.dispatchQueueMock)

        mock.register()
    }

    override func tearDown() {

        super.tearDown()

        mock.dispose()
        mock = nil
    }

    private typealias VisionManager = ImageAnalytics.VisionManager

    // MARK: - Helpers:

    private func createManager() -> VisionManager.Interface {

        VisionManager.Factory.create(with: mock.resolver)
    }

    // MARK: - Tests:

    func testFactory() {

        _ = createManager()
    }

    func testErrorLocalization() {

        typealias Error = VisionManager.VisionError

        XCTAssertEqual(

            Error.genericVisionError.localizedDescription,
            "Generic error occured."
        )
        XCTAssertEqual(

            Error.notAnIdCard.localizedDescription,
            "Selected image is not an id card. Please try again."
        )
        XCTAssertEqual(

            Error.multipleFaces.localizedDescription,
            "Selected image has multiple faces. Please try again."
        )
        XCTAssertEqual(

            Error.noFaces.localizedDescription,
            "Selected image has no faces. Please try again."
        )
    }

    func testprofilePic_invalid() {

        let manager = createManager()

        let imageObserver = mock.testScheduler.createObserver(UIImage.self)
        let textEmptyObserver = mock.testScheduler.createObserver(Bool.self)
        let errorObserver = mock.testScheduler.createObserver(VisionManager.VisionError.self)

        let bundle = Bundle.init(for: VisionManager_Tests.self)

        let testImage = (

            group: UIImage(named: "groupOfPeople", in: bundle, with: nil)!,
            idCard: UIImage(named: "id-kaart", in: bundle, with: nil)!,
            scenery: UIImage(named: "scenery", in: bundle, with: nil)!,
            selfie: UIImage(named: "selfie", in: bundle, with: nil)!
        )

        var disposable: Disposable?

        // Script
        do {

            mock.testScheduler.scheduleAt(10) {

                disposable = manager.process(image: testImage.group, type: .profilePicture)

                    .asObservable()
                    .subscribe(onNext: { (image, text) in

                        imageObserver.onNext(image)
                        textEmptyObserver.onNext(text.isEmpty)

                    }, onError: { error in

                        if let visionError = error as? VisionManager.VisionError {

                            errorObserver.onNext(visionError)
                        }
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(15) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(20) {

                disposable = manager.process(image: testImage.selfie, type: .profilePicture)

                    .asObservable()
                    .subscribe(onNext: { (image, text) in

                        imageObserver.onNext(image)
                        textEmptyObserver.onNext(text.isEmpty)

                    }, onError: { error in

                        if let visionError = error as? VisionManager.VisionError {

                            errorObserver.onNext(visionError)
                        }
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(25) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(30) {

                disposable = manager.process(image: testImage.scenery, type: .profilePicture)

                    .asObservable()
                    .subscribe(onNext: { (image, text) in

                        imageObserver.onNext(image)
                        textEmptyObserver.onNext(text.isEmpty)

                    }, onError: { error in

                        if let visionError = error as? VisionManager.VisionError {

                            errorObserver.onNext(visionError)
                        }
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(35) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(40) {

                disposable = manager.process(image: testImage.scenery, type: .idCard)

                    .asObservable()
                    .subscribe(onNext: { (image, text) in

                        imageObserver.onNext(image)
                        textEmptyObserver.onNext(text.isEmpty)

                    }, onError: { error in

                        if let visionError = error as? VisionManager.VisionError {

                            errorObserver.onNext(visionError)
                        }
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(45) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(50) {

                disposable = manager.process(image: testImage.idCard, type: .idCard)

                    .asObservable()
                    .subscribe(onNext: { (image, text) in

                        imageObserver.onNext(image)
                        textEmptyObserver.onNext(text.isEmpty)

                    }, onError: { error in

                        if let visionError = error as? VisionManager.VisionError {

                            errorObserver.onNext(visionError)
                        }
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(55) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.start()

        } // Script
        expect(textEmptyObserver.events) == [

            .next(20, true),
            .next(50, false),
        ]
        expect(imageObserver.events) == [

            .next(20, testImage.selfie),
            .next(50, testImage.idCard),
        ]
        expect(errorObserver.events) == [

            .next(10, .multipleFaces),
            .next(30, .noFaces),
            .next(40, .notAnIdCard),
        ]
    }
}
