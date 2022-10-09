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

class AddNewProfile_VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    required init?(coder: NSCoder) {

        super.init(coder: coder)
    }

    public override func viewDidLoad() {

        super.viewDidLoad()

        profilePicPicker.sourceType = .photoLibrary
        profilePicPicker.delegate = self

        idCardImgPicker.sourceType = .photoLibrary
        idCardImgPicker.delegate = self
        emailTextField.delegate = self

        self.rightBarButtonItem = navigationItem.rightBarButtonItem

        viewModel?.profilePicImg

            .drive(onNext: { [weak self] img in

                self?.profilePictureImageView.image = img
            })
            .disposed(by: disposeBag)

        viewModel?.idCardImg

            .drive(onNext: { [weak self] img in

                self?.idCardImageView.image = img
            })
            .disposed(by: disposeBag)

        viewModel?.isActivityInProgress

            .drive(onNext: { [weak self, rightBarButtonItem] inProgress in

                self?.view.alpha = inProgress ? 0.5 : 1
                self?.navigationItem.hidesBackButton = inProgress
                self?.navigationItem.rightBarButtonItem = inProgress ? nil : rightBarButtonItem

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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var idCardImageView: UIImageView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    
    // MARK: - IBActions:

    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {

        viewModel?.save(

            email: emailTextField.text ?? "",
            profilePic: profilePictureImageView.image,
            cardImage: idCardImageView.image

        )
        .observe(on: MainScheduler.instance)
        .subscribe(onCompleted: { [weak self] in

            self?.performSegue(withIdentifier: "unwindAddNewProfile", sender: self)

        }, onError: {  [weak self] error in

            self?.presentErrorAlert(message: error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }

    @IBAction func profilePictureButtonAction(_ sender: UIButton) {

        emailTextField.endEditing(true)
        self.present(profilePicPicker, animated: true)
    }

    @IBAction func addIdentityCardButtonAction(_ sender: UIButton) {

        emailTextField.endEditing(true)
        self.present(idCardImgPicker, animated: true)
    }

    // MARK: UITextFieldDelegate

    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(

        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]

    ) {

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageType = picker == profilePicPicker ? Model.ImageType.profilePic : .idCard

        viewModel?.selectImage(image: image, type: imageType)

            .observe(on: MainScheduler.instance)
            .do(onError: { [weak self] error in

                self?.presentErrorAlert(message: error.localizedDescription)

            }, onSubscribe: { [weak self] in

                self?.dismiss(animated: true, completion: nil)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    // MARK: - Privates:

    private var viewModel: AddNewProfile.VM.Interface?

    private let disposeBag = DisposeBag()
    private let profilePicPicker = UIImagePickerController()
    private let idCardImgPicker = UIImagePickerController()

    private var rightBarButtonItem: UIBarButtonItem?

    private func presentErrorAlert(message: String) {

        let alert = UIAlertController(

            title: "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

} // AddNewProfile_VC
