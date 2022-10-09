//
//  AddNewProfile+VM+Tests.swift
//  FrontendAppKitUnitTests
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

import CommonKit
@testable import FrontendAppKit
import ImageAnalyticsKit

import Nimble
import RxSwift
import RxTest
import Swinject
import UIKit
import XCTest

final class AddNewProfile_VM_Tests: XCTestCase {

    private final class Mock: Disposable {

        let container = Container()
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)

        lazy var resolver = container.synchronize()
        lazy var modelMock = Model.Mock(testScheduler)

        func register() {

            modelMock.register(with: container)
        }

        func dispose() {

            container.removeAll()
        }
    }
    private lazy var mock: Mock! = Mock()

    override func setUp() {

        super.setUp()

        VM.Factory.register(with: mock.container, scheduler: mock.testScheduler)

        mock.register()
    }

    override func tearDown() {

        mock.dispose()
        mock = nil

        super.tearDown()
    }

    private typealias VM = AddNewProfile.VM

    // MARK: - Helpers:

    private func createViewModel() -> VM.Interface {

        VM.Factory.create(with: mock.resolver, model: mock.modelMock)
    }

    // MARK: - Tests:

    func testFactory() {

        _ = createViewModel()
    }

    func testErrorLocalization() {

        typealias Error = AddNewProfile.Error

        XCTAssertEqual(

            Error.genericError.localizedDescription,
            "Generic error occured."
        )
        XCTAssertEqual(

            Error.modelNotInitalized.localizedDescription,
            "Model not initialized."
        )
        XCTAssertEqual(

            Error.missingDetails.localizedDescription,
            "Missing details in setting up profile."
        )
        XCTAssertEqual(

            Error.visionReturnedInvalidId.localizedDescription,
            "Cannot use selected picture as id card. Please select another one."
        )
        XCTAssertEqual(

            Error.visionReturnedInvalidFace.localizedDescription,
            "Cannot detect face in selected pic. Please select another one."
        )
    }

    func testSelectImage() {

        typealias ModelError = Model.Error
        typealias VisionError = ImageAnalytics.VisionManager.VisionError

        var viewModel: VM.Interface! = createViewModel()

        let bundle = Bundle(for: Model_Tests.self)
        let defaultProfilePic = UIImage(systemName: "person.crop.circle")!
        let defaultIdCardImg = UIImage(systemName: "person.text.rectangle")!
        let testImage = UIImage(named: "testImg", in: bundle, with: nil)!

        let observer = (

            selectImageObserver: mock.testScheduler.createObserver(Never.self),
            profilePicObserver: mock.testScheduler.createObserver(UIImage.self),
            idCardObserver: mock.testScheduler.createObserver(UIImage.self),
            activityObserver: mock.testScheduler.createObserver(Bool.self)
        )

        var disposable: Disposable?

        // Script
        do {

            mock.testScheduler.scheduleAt(5) {

                self.mock.disposeBag.insert([

                    viewModel.profilePicImg.asObservable().subscribe(observer.profilePicObserver),
                    viewModel.idCardImg.asObservable().subscribe(observer.idCardObserver),
                    viewModel.isActivityInProgress.asObservable().subscribe(observer.activityObserver),
                ])

                self.mock.modelMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .next(5, (testImage, "Test_String")),
                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(10) {

                disposable = viewModel.selectImage(image: testImage, type: .idCard)

                    .asObservable()
                    .subscribe(observer.selectImageObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(20) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(30) {

                self.mock.modelMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .next(5, (testImage, "")),
                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(40) {

                disposable = viewModel.selectImage(image: testImage, type: .profilePic)

                    .asObservable()
                    .subscribe(observer.selectImageObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(50) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(60) {

                self.mock.modelMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.notAnIdCard),
                ])
            }
            mock.testScheduler.scheduleAt(70) {

                disposable = viewModel.selectImage(image: testImage, type: .idCard)

                    .asObservable()
                    .subscribe(observer.selectImageObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(80) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(90) {

                self.mock.modelMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.noFaces),
                ])
            }
            mock.testScheduler.scheduleAt(100) {

                disposable = viewModel.selectImage(image: testImage, type: .profilePic)

                    .asObservable()
                    .subscribe(observer.selectImageObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(110) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(120) {

                self.mock.modelMock.m_result.process = self.mock.testScheduler.createColdObservable([

                    .error(5, VisionError.multipleFaces),
                ])
            }
            mock.testScheduler.scheduleAt(130) {

                disposable = viewModel.selectImage(image: testImage, type: .profilePic)

                    .asObservable()
                    .subscribe(observer.selectImageObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(140) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(999) {

                viewModel = nil
            }
            mock.testScheduler.start()

        } // Script

        expect(self.mock.modelMock.m_callsObserver.events) == [

            .next(10, .process(image: testImage, type: .idCard)),
            .next(40, .process(image: testImage, type: .profilePic)),
            .next(70, .process(image: testImage, type: .idCard)),
            .next(100, .process(image: testImage, type: .profilePic)),
            .next(130, .process(image: testImage, type: .profilePic)),
        ]
        expect(observer.activityObserver.events) == [

            .next(5, false),
            .next(10, true),
            .next(10 + 5, false),
            .next(40, true),
            .next(40 + 5, false),
            .next(70, true),
            .next(70 + 5, false),
            .next(100, true),
            .next(100 + 5, false),
            .next(130, true),
            .next(130 + 5, false),
        ]
        expect(observer.idCardObserver.events) == [

            .next(5, defaultIdCardImg),
            .next(10 + 5, testImage),
        ]
        expect(observer.profilePicObserver.events) == [

            .next(5, defaultProfilePic),
            .next(40 + 5, testImage)
        ]
        expect(observer.selectImageObserver.events) == [

            .completed(10 + 5),
            .completed(40 + 5),
            .error(70 + 5, VisionError.notAnIdCard),
            .error(100 + 5, VisionError.noFaces),
            .error(130 + 5, VisionError.multipleFaces),
        ]
    }

    func testSave() {

        typealias VMError = AddNewProfile.Error
        typealias ModelError = Model.Error

        var viewModel: VM.Interface! = createViewModel()

        let bundle = Bundle(for: Model_Tests.self)
        let testEmail = "abc@veriff.com"
        let testImage = UIImage(named: "testImg", in: bundle, with: nil)!

        let observer = (

            saveObserver: mock.testScheduler.createObserver(Never.self),
            activityObserver: mock.testScheduler.createObserver(Bool.self)
        )

        var disposable: Disposable?

        // Script
        do {

            mock.testScheduler.scheduleAt(5) {

                self.mock.disposeBag.insert([

                    viewModel.isActivityInProgress.asObservable().subscribe(observer.activityObserver),
                ])

                self.mock.modelMock.m_result.saveProfile = self.mock.testScheduler.createColdObservable([

                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(10) {

                disposable = viewModel.save(email: testEmail, profilePic: testImage, cardImage: testImage)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(20) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(30) {

                self.mock.modelMock.m_result.saveProfile = self.mock.testScheduler.createColdObservable([

                    .completed(5)
                ])
            }
            mock.testScheduler.scheduleAt(40) {

                disposable = viewModel.save(email: "", profilePic: nil, cardImage: testImage)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(50) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(60) {

                self.mock.modelMock.m_result.saveProfile = self.mock.testScheduler.createColdObservable([

                    .error(5, ModelError.cannotCreateProfileExists)
                ])
            }
            mock.testScheduler.scheduleAt(70) {

                disposable = viewModel.save(email: testEmail, profilePic: testImage, cardImage: testImage)

                    .asObservable()
                    .subscribe(observer.saveObserver)

                disposable?.disposed(by: self.mock.disposeBag)
            }
            mock.testScheduler.scheduleAt(80) {

                disposable?.dispose()
                disposable = nil
            }
            mock.testScheduler.scheduleAt(99) {

                viewModel = nil
            }
            mock.testScheduler.start()

        } // Script

        expect(self.mock.modelMock.m_callsObserver.events) == [

            .next(10, .saveProfile),
            .next(70, .saveProfile),
        ]
        expect(observer.activityObserver.events) == [

            .next(5, false),
            .next(10, true),
            .next(10 + 5 + 1, false),
            .next(70, true),
            .next(70 + 5, false),
        ]
        expect(observer.saveObserver.events) == [

            .completed(10 + 5 + 1),
            .error(40, VMError.missingDetails),
            .error(70 + 5, ModelError.cannotCreateProfileExists),
        ]
    }

} // AddNewProfile_VM_Tests
