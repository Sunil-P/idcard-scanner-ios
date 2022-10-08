//
//  AddNewProfile+VM+Impl.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import RxCocoa
import RxSwift
import Swinject

extension AddNewProfile.VM {

    public struct Factory {

        public static func register(with container: Container) {

            container.register(Interface.self) { (_, model: Model.Interface) in

                Impl(with: model)
            }
            .inObjectScope(.transient)
        }

        static func create(with resolver: Resolver, model: Model.Interface) -> Interface {

            resolver.resolve(Interface.self, argument: model)!
        }

    } // Factory

    // MARK: -

    private final class Impl: Interface {

        init(with model: Model.Interface) {

            self.model = model
            self.relay = (

                profilePic: BehaviorSubject<UIImage>(value: defaultImage.profilePic),
                idCardImg: BehaviorSubject<UIImage>(value: defaultImage.idCardImg),
                activityInProgress: BehaviorSubject<Bool>(value: false)
            )

            relay.profilePic.subscribe(onNext: { _ in

                print("Relay val changed.")
            })
            .disposed(by: disposeBag)

            print("AddNewProfile.VM initialized.")
        }

        deinit {

            print("AddNewProfile.VM deinitalized.")
        }

        // MARK: - Interface

        var profilePicImg: Driver<UIImage> {

            relay.profilePic

                .asDriver(onErrorDriveWith: .just(defaultImage.idCardImg))
        }

        var idCardImg: Driver<UIImage> {

            relay.idCardImg

                .asDriver(onErrorDriveWith: .just(defaultImage.idCardImg))
        }

        var isActivityInProgress: Driver<Bool> {

            relay.activityInProgress

                .asDriver(onErrorDriveWith: .never())
        }

        func selectProfilePic(image: UIImage) -> Completable {

            .create { [weak self] completable in

                self?.relay.profilePic.onNext(image)

                completable(.completed)
                return Disposables.create { }
            }
        }

        func selectIdCardImg(image: UIImage) -> Completable {

            .create { [weak self] completable in

                guard let this = self else {

                    completable(.error(AddNewProfile.Error.genericError))
                    return Disposables.create {}
                }

                guard let model = this.model else {

                    completable(.error(AddNewProfile.Error.modelNotInitalized))
                    return Disposables.create { }
                }

                model.parseIdCard(image: image)

                    .do(onSuccess: { [weak self] processedImage in

                        print("Completed.")
                        completable(.completed)
                        self?.relay.idCardImg.onNext(processedImage)

                    }, onError: { error in

                        completable(.error(error))

                    }, onSubscribe: { [weak self] in

                        self?.relay.activityInProgress.onNext(true)

                    }, onDispose: { [weak self] in

                        self?.relay.activityInProgress.onNext(false)
                    })
                    .subscribe()
                    .disposed(by: this.disposeBag)

                return Disposables.create { }
            }
        }

        func save(

            name: String,
            email: String,
            profilePic: UIImage?,
            cardImage: UIImage?

        ) -> Completable {

            .create { [weak self] completable in

                guard !name.isEmpty, !email.isEmpty, let profilePic = profilePic, let cardImage = cardImage else {

                    completable(.error(AddNewProfile.Error.missingDetails))
                    return Disposables.create {}
                }

                guard let this = self else {

                    completable(.error(AddNewProfile.Error.genericError))
                    return Disposables.create {}
                }

                guard let model = this.model else {

                    completable(.error(AddNewProfile.Error.modelNotInitalized))
                    return Disposables.create {}
                }

                model.saveProfile(profile: .init(

                    id: UUID(), name: name, email: email, cardImage: cardImage, profilePic: profilePic
                ))
                .subscribe(onCompleted: {

                    completable(.completed)

                }, onError: { error in

                    completable(.error(error))
                })
                .disposed(by: this.disposeBag)

                return Disposables.create {}
            }
        }

        // MARK: - Privates

        private let disposeBag = DisposeBag()
        private let defaultImage = (

            profilePic: UIImage(systemName: "person.crop.circle.fill.badge.plus")!,
            idCardImg: UIImage(systemName: "person.text.rectangle")!
        )

        private let relay: (

            profilePic: BehaviorSubject<UIImage>,
            idCardImg: BehaviorSubject<UIImage>,
            activityInProgress: BehaviorSubject<Bool>
        )

        private weak var model: Model.Interface?

    } // Impl

} // AddNewProfile.VM
