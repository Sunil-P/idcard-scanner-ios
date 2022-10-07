//
//  Root+VM+Impl.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import Swinject

extension Root.VM {

    public struct Factory {

        public static func register(with container: Container) {

            container.register(Interface.self) { _ in

                Impl(with: container.synchronize())
            }
            .inObjectScope(.transient)
        }

        static func create(with resolver: Resolver) -> Interface {

            resolver.resolve(Interface.self)!
        }

    } // Factory

    // MARK: -

    private final class Impl: Interface {

        init(with resolver: Resolver) {

            print("Class init")
        }

    } // Impl

} // Root.VM
