//
//  ImageAnalytics+VisionManager+Mock.swift
//  ImageAnalyticsMocks
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

import CommonKit
import ImageAnalyticsKit

import UIKit
import RxSwift
import RxTest
import Swinject

extension ImageAnalytics.VisionManager {

    public class Mock: Interface {

        enum Calls: Equatable {

            case process(image: UIImage, type: ImageAnalytics.VisionManager.ImageType)
        }
        let m_callsObserver: TestableObserver<Calls>

        var m_result: (

            process: TestableObservable<(UIImage, String)>,
            ()
        )

        init(_ testScheduler: TestScheduler) {

            self.m_callsObserver = testScheduler.createObserver(Calls.self)

            self.m_result = (

                process: testScheduler.createColdObservable([]),
                ()
            )
        }

        func register(with container: Container) {

            container.register(Interface.self) { _ in self }
        }

        // MARK: - Interface

        public func process(

            image: UIImage,
            type: ImageAnalytics.VisionManager.ImageType

        ) -> Single<(UIImage, String)> {

            m_callsObserver.onNext(.process(image: image, type: type))

            return m_result.process.asSingle()
        }

    } // Mock

} // ImageAnalytics.VisionManager
