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

        public static func register(with container: Container, scheduler: SchedulerType?) {

            container.register(Interface.self) { (_, model: Model.Interface) in

                Impl(with: model, scheduler: scheduler ?? MainScheduler.instance)
            }
            .inObjectScope(.transient)
        }

        static func create(with resolver: Resolver, model: Model.Interface) -> Interface {

            resolver.resolve(Interface.self, argument: model)!
        }

    } // Factory

    // MARK: -

    private final class Impl: Interface {

        init(with model: Model.Interface, scheduler: SchedulerType) {

            self.scheduler = scheduler
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

        func selectImage(

            image: UIImage,
            type: Model.ImageType

        ) -> Completable {

            .create { [weak self] completable in

                guard let this = self else {

                    completable(.error(AddNewProfile.Error.genericError))
                    return Disposables.create {}
                }

                guard let model = this.model else {

                    completable(.error(AddNewProfile.Error.modelNotInitalized))
                    return Disposables.create { }
                }

                model.process(image: image, type: type)

                    .do(onSuccess: { [weak self] result in

                        switch type {

                        case .idCard:

                            self?.relay.idCardImg.onNext(result.0)

                        case .profilePic:

                            self?.relay.profilePic.onNext(result.0)
                        }

                        self?.parsedTextCache = result.1
                        print("Completed.")

                        completable(.completed)

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

            email: String,
            profilePic: UIImage?,
            cardImage: UIImage?

        ) -> Completable {

            .create { [weak self] completable in

                guard !email.isEmpty, let profilePic = profilePic, let cardImage = cardImage else {

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

                    id: UUID(),
                    email: email,
                    cardImage: cardImage,
                    profilePic: profilePic,
                    parsedText: this.parsedTextCache
                ))
                // For better looking UX.
                .delay(.seconds(1), scheduler: this.scheduler)
                .do(onError: { error in

                    completable(.error(error))

                }, onCompleted: {

                    completable(.completed)

                }, onSubscribe: {

                    self?.relay.activityInProgress.onNext(true)

                }, onDispose: {

                    self?.relay.activityInProgress.onNext(false)
                })
                .subscribe()
                .disposed(by: this.disposeBag)

                return Disposables.create {}
            }
        }

        // MARK: - Privates

        private let scheduler: SchedulerType
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
        private var parsedTextCache = ""

    } // Impl

} // AddNewProfile.VM
