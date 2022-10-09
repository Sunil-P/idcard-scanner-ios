//
//  Model+Mock.swift
//  FrontendAppKitUnitTests
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

import CommonKit

@testable import FrontendAppKit

import RxRelay
import RxSwift
import RxTest
import Swinject
import UIKit

extension Model {

    final class Mock: Interface {

        enum Calls: Equatable {

            case saveProfile
            case process(image: UIImage, type: Model.ImageType)
        }
        let m_callsObserver: TestableObserver<Calls>

        var m_result: (

            profiles: BehaviorRelay<[Model.Profile]>,
            saveProfile: TestableObservable<Never>,
            process: TestableObservable<(UIImage, String)>
        )

        init(_ testScheduler: TestScheduler) {

            self.m_callsObserver = testScheduler.createObserver(Calls.self)

            self.m_result = (

                profiles: BehaviorRelay<[Model.Profile]>(value: []),
                saveProfile: testScheduler.createColdObservable([]),
                process: testScheduler.createColdObservable([])
            )
        }

        func register(with container: Container) {

            container.register(Interface.self) { _ in self }
        }

        // MARK: - Interface

        var profiles: Observable<[Model.Profile]> {

            m_result.profiles.asObservable()
        }

        func process(image: UIImage, type: Model.ImageType) -> Single<(UIImage, String)> {

            m_callsObserver.onNext(.process(image: image, type: type))

            return m_result.process.asSingle()
        }

        func saveProfile(profile: Model.Profile) -> Completable {

            m_callsObserver.onNext(.saveProfile)

            return m_result.saveProfile.asCompletable()
        }

    } // Mock

} // Model
