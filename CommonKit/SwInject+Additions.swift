//
//  Additions.swift
//  CommonKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import Swinject

extension Container {

    public struct SyncPair {

        public let container = Container()

        public let resolver: Resolver

        public init() {

            self.resolver = container.synchronize()
        }
    }

    public static let `default` = SyncPair()
}
