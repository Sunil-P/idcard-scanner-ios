//
//  Model+Tests.swift
//  FrontendApplication
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

@testable import FrontendAppKit
@testable import ImageAnalyticsMocks
import ImageAnalyticsKit
import CommonKit

import Nimble
import XCTest
import RxSwift
import Swinject
import RxTest
import UIKit

final class Model_Tests: XCTestCase {

    private final class Mock: Disposable {

        let container = Container()
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)

        lazy var resolver = container.synchronize()
        lazy var visionManagerMock = ImageAnalytics.VisionManager.Mock(testScheduler)

        func register() {

            visionManagerMock.register(with: container)
        }

        func dispose() {

            container.removeAll()
        }
    }
    private lazy var mock: Mock! = Mock()

    override func setUp() {

        super.setUp()

        Model.Factory.register(with: mock.container)

        mock.register()
    }

    override func tearDown() {

        mock.dispose()
        mock = nil

        super.tearDown()
    }

    // MARK: - Helpers:

    private func createModel() -> Model.Interface {

        Model.Factory.create(with: mock.resolver)
    }

    // MARK: - Tests:

    func testFactory() {

        _ = createModel()
    }

    func testErrorLocalization() {

        typealias Error = Model.Error

        XCTAssertEqual(

            Error.cannotCreateProfileExists.localizedDescription,
            "Cannot create new profile, profile already exists."
        )
    }

    func testSaveProfile() {

        var model: Model.Interface! = createModel()

        let bundle = Bundle(for: Model_Tests.self)
        let testImage = UIImage(named: "testImg", in: bundle, with: nil)!

        let observer = (

            saveObserver: mock.testScheduler.createObserver(Never.self),
            profileIdObserver: mock.testScheduler.createObserver(Set<UUID>.self)
        )

        let testProfile = (

            Model.Profile(

                id: UUID(),
                email: "abcd@malwarebytes.com",
                cardImage: testImage,
                profilePic: testImage,
                parsedText: "ParsedText1"
            ),
            Model.Profile(

                id: UUID(),
                email: "abcd2@veriff.com",
                cardImage: testImage,
                profilePic: testImage,
                parsedText: "ParsedText2"
            )
        )

        var disposable: Disposable?

        // Script
        do {

            mock.testScheduler.scheduleAt(5) {

                model.profiles

                    .map { Set($0.map { $0.id }) }
                    .subscribe(observer.profileIdObserver)
                    .disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(10) {

                disposable = model.saveProfile(profile: testProfile.0)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(15) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(20) {

                disposable = model.saveProfile(profile: testProfile.0)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(25) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(30) {

                disposable = model.saveProfile(profile: testProfile.1)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(35) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(99) {

                model = nil
            }
            mock.testScheduler.start()

        } // Script
        expect(observer.saveObserver.events) == [

            .completed(10),
            .error(20, Model.Error.cannotCreateProfileExists),
            .completed(30),
        ]
        expect(observer.profileIdObserver.events) == [

            .next(5, []),
            .next(10, [

                testProfile.0.id
            ]),
            .next(30, [

                testProfile.0.id,
                testProfile.1.id,
            ]),
        ]
    }

    func testProcess() {

        typealias VisionError = ImageAnalytics.VisionManager.VisionError

        let bundle = Bundle(for: Model_Tests.self)
        let testImage = UIImage(named: "testImg", in: bundle, with: nil)!

        var model: Model.Interface! = createModel()

        let observer = (

            errorObserver: mock.testScheduler.createObserver(VisionError.self),
            imageObserver: mock.testScheduler.createObserver(UIImage.self),
            textObserver: mock.testScheduler.createObserver(String.self)
        )

        var disposable: Disposable?

        // Script
        do {
            mock.testScheduler.scheduleAt(5) {

                self.mock.visionManagerMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .next(5, (testImage, "Test_String")),
                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(10) {

                disposable = model.process(image: testImage, type: .profilePic)

                    .subscribe(onSuccess: { (img, text) in

                        observer.imageObserver.onNext(img)
                        observer.textObserver.onNext(text)

                    }, onFailure: { error in

                        observer.errorObserver.onNext(error as! VisionError)
                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(20) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(25) {

                self.mock.visionManagerMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.noFaces)
                ])
            }
            mock.testScheduler.scheduleAt(30) {

                disposable = model.process(image: testImage, type: .profilePic)

                    .asObservable()
                    .subscribe(onNext: { (img, text) in

                        observer.imageObserver.onNext(img)
                        observer.textObserver.onNext(text)

                    }, onError: { error in

                        observer.errorObserver.onNext(error as! VisionError)

                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(40) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(45) {

                self.mock.visionManagerMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.multipleFaces)
                ])
            }
            mock.testScheduler.scheduleAt(50) {

                disposable = model.process(image: testImage, type: .profilePic)

                    .asObservable()
                    .subscribe(onNext: { (img, text) in

                        observer.imageObserver.onNext(img)
                        observer.textObserver.onNext(text)

                    }, onError: { error in

                        observer.errorObserver.onNext(error as! VisionError)

                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(60) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(65) {

                self.mock.visionManagerMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .next(5, (testImage, "Test_String")),
                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(70) {

                disposable = model.process(image: testImage, type: .idCard)

                    .asObservable()
                    .subscribe(onNext: { (img, text) in

                        observer.imageObserver.onNext(img)
                        observer.textObserver.onNext(text)

                    }, onError: { error in

                        observer.errorObserver.onNext(error as! VisionError)

                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(80) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(85) {

                self.mock.visionManagerMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.notAnIdCard)
                ])
            }
            mock.testScheduler.scheduleAt(90) {

                disposable = model.process(image: testImage, type: .idCard)

                    .asObservable()
                    .subscribe(onNext: { (img, text) in

                        observer.imageObserver.onNext(img)
                        observer.textObserver.onNext(text)

                    }, onError: { error in

                        observer.errorObserver.onNext(error as! VisionError)

                    })

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(100) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(999) {

                model = nil
            }
            mock.testScheduler.start()

        } // Script
        expect(observer.textObserver.events) == [

            .next(10 + 5, "Test_String"),
            .next(70 + 5, "Test_String"),
        ]
        expect(observer.imageObserver.events) == [

            .next(10 + 5, testImage),
            .next(70 + 5, testImage),
        ]
        expect(observer.errorObserver.events) == [

            .next(30 + 5, .noFaces),
            .next(50 + 5, .multipleFaces),
            .next(90 + 5, .notAnIdCard),
        ]
        expect(self.mock.visionManagerMock.m_callsObserver.events) == [

            .next(10, .process(image: testImage, type: .profilePicture)),
            .next(30, .process(image: testImage, type: .profilePicture)),
            .next(50, .process(image: testImage, type: .profilePicture)),
            .next(70, .process(image: testImage, type: .idCard)),
            .next(90, .process(image: testImage, type: .idCard)),
        ]
    }
}
