//
//  Model+Impl.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import CommonKit
import ImageAnalyticsKit

import RxRelay
import RxSwift
import Swinject

extension Model {

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

    private final class Impl: Interface {

        init(with resolver: Resolver) {

            self.profilesRelay = BehaviorRelay(value: [:])
            self.visionManager = ImageAnalytics.VisionManager.Factory.create(with: resolver)
        }

        // MARK: - Interface:

        var profiles: Observable<[Model.Profile]> {

            profilesRelay.map { Array($0.values) }

                .asObservable()
        }

        func parseIdCard(image: UIImage) -> Single<UIImage> {

            .create { [disposeBag, visionManager] single in

                visionManager.processIdCard(image: image)

                    .subscribe(onSuccess: { result in

                        print(result.1)

                        single(.success(result.0))

                    }, onFailure: { error in

                        single(.failure(error))
                    })
                    .disposed(by: disposeBag)

                return Disposables.create { }
            }
        }

        func saveProfile(profile: Model.Profile) -> Completable {

            .create { [profilesRelay] completable in

                var profiles = profilesRelay.value

                guard !profiles.keys.contains(profile.id) else {

                    print("Error: Profile already exists.")
                    completable(.error(Model.Error.cannotCreateProfileExists))
                    return Disposables.create {}
                }

                profiles[profile.id] = profile
                profilesRelay.accept(profiles)

                completable(.completed)
                return Disposables.create {}
            }
        }

        func deleteProfile(id: UUID) -> Completable {

            .create { [profilesRelay] completable in

                var profiles = profilesRelay.value

                guard profiles.keys.contains(id) else {

                    print("Error: Profile doesnt exist, cannot delete.")
                    completable(.error(Model.Error.cannotDeleteProfileDoesntExist))
                    return Disposables.create {}
                }

                profiles.removeValue(forKey: id)
                profilesRelay.accept(profiles)

                completable(.completed)
                return Disposables.create {}
            }
        }

        // MARK: - Privates:

        private let disposeBag = DisposeBag()
        private let visionManager: ImageAnalytics.VisionManager.Interface
        private let profilesRelay: BehaviorRelay<[UUID: Model.Profile]>
    }

} // Model
