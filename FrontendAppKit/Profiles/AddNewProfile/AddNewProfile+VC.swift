//
//  AddNewProfile+VC.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/8/22.
//

import CommonKit

import RxCocoa
import RxSwift
import Swinject
import UIKit

class AddNewProfile_VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    required init?(coder: NSCoder) {

        super.init(coder: coder)
    }

    public override func viewDidLoad() {

        super.viewDidLoad()

        profilePicPicker.sourceType = .photoLibrary
        profilePicPicker.delegate = self

        idCardImgPicker.sourceType = .photoLibrary
        idCardImgPicker.delegate = self

        viewModel?.profilePicImg.drive(onNext: { [weak self] img in

            self?.profilePictureImageView.image = img
        })
        .disposed(by: disposeBag)

        viewModel?.idCardImg.drive(onNext: { [weak self] img in

            self?.idCardImageView.image = img
        })
        .disposed(by: disposeBag)

        viewModel?.isActivityInProgress.drive(onNext: { [weak self] inProgress in

            self?.loadingIndicatorView.isHidden = !inProgress
        })
        .disposed(by: disposeBag)
    }

    func setViewModel(viewModel: AddNewProfile.VM.Interface) {

        self.viewModel = viewModel
    }

    // MARK: - IBOutlets:

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var idCardImgButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var idCardImageView: UIImageView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicatorBgView: UIView!

    // MARK: - IBActions:

    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {

        viewModel?.save(

            name: nameTextField.text ?? "",
            email: emailTextField.text ?? "",
            profilePic: profilePictureButton.imageView?.image,
            cardImage: profilePictureButton.imageView?.image

        ).subscribe(onCompleted: {

            print("Added Profile successfully.")

        }, onError: { error in

            print("Error. \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }

    @IBAction func profilePictureButtonAction(_ sender: UIButton) {

        self.present(profilePicPicker, animated: true)
    }

    @IBAction func addIdentityCardButtonAction(_ sender: UIButton) {

        self.present(idCardImgPicker, animated: true)
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(

        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]

    ) {

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

        if picker == profilePicPicker {

            viewModel?.selectProfilePic(image: image)

                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in

                    print("Finished picking profile pic.")

                    self?.dismiss(animated: true, completion: nil)

                }, onError: { [weak self] error in

                    self?.dismiss(animated: true, completion: nil)

                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

                    alert.addAction(.init(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                })
                .disposed(by: disposeBag)

        } else if picker == idCardImgPicker {

            viewModel?.selectIdCardImg(image: image)

                .observe(on: MainScheduler.instance)
                .do(onSubscribe: { [weak self] in

                    self?.dismiss(animated: true, completion: nil)

                })
                .subscribe(onError: { [weak self] error in

                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

                    alert.addAction(.init(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Privates:

    private var viewModel: AddNewProfile.VM.Interface?

    private let disposeBag = DisposeBag()
    private let profilePicPicker = UIImagePickerController()
    private let idCardImgPicker = UIImagePickerController()

} // AddNewProfile_VC
