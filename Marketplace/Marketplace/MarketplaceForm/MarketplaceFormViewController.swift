//
//  MarketplaceFormViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit

class MarketplaceFormViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButton()
        setNavigationMenuButton()
        nameTextField.delegate = self
        saveButton.titleLabel?.font = .semibold(size: 16)
        saveButton.layer.cornerRadius = 20
    }

    @IBAction func clickedSave(_ sender: UIButton) {
        if let name = nameTextField.text {
            MarketplacesViewModel.shared.addMarketplace(name: name) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension MarketplaceFormViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        saveButton.isHidden = !textField.isValid
    }
}
