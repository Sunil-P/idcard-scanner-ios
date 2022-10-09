//
//  Profiles+VC.swift
//  FrontendAppKit
//
//  Created by Subhrajyoti Patra on 10/7/22.
//

import CommonKit

import Swinject
import RxSwift
import UIKit

class Profiles_VC: UIViewController {

    required init?(coder: NSCoder) {

        let resolver = Container.default.resolver

        self.viewModel = Profiles.VM.Factory.create(with: resolver)

        super.init(coder: coder)
    }

    public override func viewDidLoad() {

        super.viewDidLoad()

        print("Profiles.VC loaded.")

        viewModel.profiles.drive(tableView.rx.items(cellIdentifier: "cell")) { row, person, cell in

            var content = cell.defaultContentConfiguration()

            content.text = person.email

            cell.contentConfiguration = content

        }.disposed(by: disposeBag)

        tableView.rx.modelSelected(Model.Profile.self).subscribe(onNext: { [weak self] person in

            self?.performSegue(withIdentifier: "showProfileSegue", sender: person)
        })
        .disposed(by: disposeBag)

        viewModel.profiles.map { !$0.isEmpty }.drive(profileLabel.rx.isHidden).disposed(by: disposeBag)
    }

    // MARK: - IBActions:

    @IBAction func unwind( _ seg: UIStoryboardSegue) {

    }

    // MARK: - IBOutlets:

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileLabel: UILabel!

    // MARK: - Overrides:

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let addNewProfileVC = segue.destination as? AddNewProfile_VC {

            addNewProfileVC.setViewModel(viewModel: viewModel.addNewProfileVM)
        }

        if segue.identifier == "showProfileSegue" {

            let profileVC = segue.destination as! Details_VC
            let profile = sender as! Model.Profile

            profileVC.setObject(profile: profile)
        }
    }

    // MARK: - Privates:

    private let viewModel: Profiles.VM.Interface
    private let disposeBag = DisposeBag()

} // Profiles_VC
