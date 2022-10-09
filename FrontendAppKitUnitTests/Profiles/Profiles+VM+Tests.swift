//
//  Profiles+VM+Tests.swift
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

final class Profiles_VM_Tests: XCTestCase {

    private final class Mock: Disposable {

        let container = Container()
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)

        lazy var resolver = container.synchronize()
        lazy var modelMock = Model.Mock(testScheduler)
        lazy var addNewProfileVM = AddNewProfile.VM.Mock(testScheduler)

        func register() {

            modelMock.register(with: container)
            addNewProfileVM.register(with: container)
        }

        func dispose() {

            container.removeAll()
        }
    }
    private lazy var mock: Mock! = Mock()

    override func setUp() {

        super.setUp()

        VM.Factory.register(with: mock.container)

        mock.register()
    }

    override func tearDown() {

        mock.dispose()
        mock = nil

        super.tearDown()
    }

    private typealias VM = Profiles.VM

    // MARK: - Helpers:

    private func createViewModel() -> VM.Interface {

        VM.Factory.create(with: mock.resolver)
    }

    // MARK: - Tests:

    func testFactory() {

        _ = createViewModel()
    }

    func testProfiles() {

        var viewModel: VM.Interface! = createViewModel()

        let bundle = Bundle(for: Model_Tests.self)
        let testImage = UIImage(named: "testImg", in: bundle, with: nil)!
        let testProfile = (

            Model.Profile(

                id: UUID(),
                email: "abc@veriff.com",
                cardImage: testImage,
                profilePic: testImage,
                parsedText: "ABCD"
            ),
            Model.Profile(

                id: UUID(),
                email: "abcd@malwarebytes.com",
                cardImage: testImage,
                profilePic: testImage,
                parsedText: "ABCDE"
            )
        )

        let observer = (

            profileId: mock.testScheduler.createObserver(Set<UUID>.self),
            ()
        )

        viewModel.profiles

            .map { Set($0.map { $0.id }) }
            .asObservable()
            .subscribe(observer.profileId)
            .disposed(by: mock.disposeBag)

        // Script
        do {

            mock.testScheduler.scheduleAt(10) {

                self.mock.modelMock.m_result.profiles.accept([

                    testProfile.0,
                ])
            }
            mock.testScheduler.scheduleAt(20) {

                self.mock.modelMock.m_result.profiles.accept([

                    testProfile.0,
                    testProfile.1
                ])
            }
            mock.testScheduler.scheduleAt(30) {

                self.mock.modelMock.m_result.profiles.accept([
                ])
            }
            mock.testScheduler.scheduleAt(99) {

                viewModel = nil
            }
            mock.testScheduler.start()

        } // Script

        expect(observer.profileId.events) == [

            .next(0, []),
            .next(10, [testProfile.0.id]),
            .next(20, [testProfile.0.id, testProfile.1.id]),
            .next(30, []),
        ]
    }

} // Profiles_VM_Tests
