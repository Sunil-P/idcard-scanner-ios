//
//  AddNewProfile+VM+Mock.swift
//  FrontendAppKitUnitTests
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

@testable import FrontendAppKit

import RxCocoa
import RxSwift
import RxTest
import Swinject

extension AddNewProfile.VM {

    final class Mock: Interface {

        enum Calls: Equatable {

            case selectImage(image: UIImage, type: Model.ImageType)
            case save(email: String, profilePic: UIImage?, cardImage: UIImage?)
        }
        let m_callsObserver: TestableObserver<Calls>

        var m_result: (

            profilePicImg: BehaviorRelay<UIImage>,
            idCardImg: BehaviorRelay<UIImage>,
            isActivityInProgress: BehaviorRelay<Bool>,
            selectImage: TestableObservable<Never>,
            save: TestableObservable<Never>
        )

        init(_ testScheduler: TestScheduler) {

            self.m_callsObserver = testScheduler.createObserver(Calls.self)

            let defaultImage = (

                profilePic: UIImage(systemName: "person.crop.circle")!,
                idCardImg: UIImage(systemName: "person.text.rectangle")!
            )

            self.m_result = (

                profilePicImg: BehaviorRelay<UIImage>(value: defaultImage.profilePic),
                idCardImg: BehaviorRelay<UIImage>(value: defaultImage.idCardImg),
                isActivityInProgress: BehaviorRelay<Bool>(value: false),
                selectImage: testScheduler.createColdObservable([]),
                save: testScheduler.createColdObservable([])
            )
        }

        func register(with container: Container) {

            container.register(Interface.self) { _ in self }
        }

        // MARK: - Interface

        var profilePicImg: Driver<UIImage> {

            m_result.profilePicImg.asDriver()
        }

        var idCardImg: Driver<UIImage> {

            m_result.idCardImg.asDriver()
        }

        var isActivityInProgress: Driver<Bool> {

            m_result.isActivityInProgress.asDriver()
        }

        func selectImage(image: UIImage, type: Model.ImageType) -> Completable {

            m_callsObserver.onNext(.selectImage(image: image, type: type))

            return m_result.selectImage.asCompletable()
        }

        func save(email: String, profilePic: UIImage?, cardImage: UIImage?) -> Completable {

            return m_result.save.asCompletable()
        }


    } // Mock

} // AddNewProfile.VM
