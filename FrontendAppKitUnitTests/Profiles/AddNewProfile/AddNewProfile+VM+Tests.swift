//
//  AddNewProfile+VM+Tests.swift
//  FrontendAppKitUnitTests
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

@testable import FrontendAppKit

import CommonKit

import Nimble
import XCTest
import RxSwift
import Swinject
import RxTest
import UIKit

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

    func testSelectImage() {

        typealias ModelError = Model.Error

        var viewModel: VM.Interface! = createViewModel()

        let bundle = Bundle(for: Model_Tests.self)
        let defaultProfilePic = UIImage(systemName: "person.crop.circle.fill.badge.plus")!
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
            mock.testScheduler.scheduleAt(99) {

                viewModel = nil
            }
            mock.testScheduler.start()

        } // Script

        expect(self.mock.modelMock.m_callsObserver.events) == [

            .next(10, .process(image: testImage, type: .idCard)),
            .next(40, .process(image: testImage, type: .profilePic)),
        ]
        expect(observer.activityObserver.events) == [

            .next(5, false),
            .next(10, true),
            .next(10 + 5, false),
            .next(40, true),
            .next(40 + 5, false),
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
