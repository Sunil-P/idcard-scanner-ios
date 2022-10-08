//
//  Profiles+VM+Impl.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import Swinject

extension Profiles.VM {

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

            self.resolver = resolver
            self.model = Model.Factory.create(with: resolver)

            print("Class init")
        }

        var addNewProfileVM: AddNewProfile.VM.Interface {

            AddNewProfile.VM.Factory.create(with: resolver, model: model)
        }

        // MARK: - Privates:

        private let resolver: Resolver
        private let model: Model.Interface

    } // Impl

} // Profiles.VM
