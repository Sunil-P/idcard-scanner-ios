//
//  AppContext.swift
//  FrontendApplication
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit
import FrontendAppKit

import Swinject

struct AppContext {

    init() {

        let container = Container.default.container

        Root.VM.Factory.register(with: container)
    }

} // AppContext
