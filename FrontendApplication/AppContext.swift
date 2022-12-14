//
//  AppContext.swift
//  FrontendApplication
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit
import FrontendAppKit
import ImageAnalyticsKit

import Swinject

struct AppContext {

    init() {

        let container = Container.default.container

        Profiles.Factory.register(with: container)
        ImageAnalytics.VisionManager.Factory.register(with: container)

    }

} // AppContext
