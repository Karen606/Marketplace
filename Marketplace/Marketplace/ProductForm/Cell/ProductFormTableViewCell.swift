//
//  ProductFormTableViewCell.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import UIKit
import iOSDropDown

class ProductFormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var marketplaceDropDown: DropDown!
    @IBOutlet weak var quantityTextField: BaseTextField!
    private let tapGesture = UITapGestureRecognizer()
    private var index: Int = 0
    private var id: UUID? {
        didSet {
            quantityTextField.isEnabled = id != nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        marketplaceDropDown.layer.cornerRadius = 5
        marketplaceDropDown.layer.borderWidth = 1
        marketplaceDropDown.layer.borderColor = UIColor.black.cgColor
        marketplaceDropDown.selectedRowColor = .clear
        marketplaceDropDown.checkMarkEnabled = false
        tapGesture.addTarget(self, action: #selector(handleTap))
        quantityTextField.delegate = self
        marketplaceDropDown.addGestureRecognizer(tapGesture)
        marketplaceDropDown.optionArray = ProductFormViewModel.shared.marketPlaces.map({ $0.name ?? "" })
        
        marketplaceDropDown.didSelect { [weak self] selectedText, index, id in
            guard let self = self else { return }
            if !ProductFormViewModel.shared.chooseMarketplace(marketplace: ProductFormViewModel.shared.marketPlaces[index], index: self.index) {
                self.marketplaceDropDown.listDidDisappear {
                    self.marketplaceDropDown.showList()
                    self.marketplaceDropDown.attributedText = NSAttributedString(string: "existing", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                }
                
            } else {
                self.marketplaceDropDown.listDidDisappear {}
                self.id = ProductFormViewModel.shared.marketPlaces[index].id
            }
        }
    }
    
    @objc func handleTap() {
        marketplaceDropDown.showList()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        index = 0
        id = nil
    }
    
    func setupData(marketplaceInfo: MarketplaceInfoModel, index: Int) {
        self.index = index
        self.id = marketplaceInfo.id
        marketplaceDropDown.text = marketplaceInfo.name
        if let quantity = marketplaceInfo.product?.remainder {
            quantityTextField.text = "\(quantity)"
        } else {
            quantityTextField.text = nil
        }
    }
}

extension ProductFormTableViewCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let id = self.id else { return }
        if let value = textField.text {
            if !ProductFormViewModel.shared.setRemainder(id: id, remainder: Int(value)) {
                quantityTextField.showError(error: "not enough stock")
            } else {
                quantityTextField.showError(error: nil)
            }
        }
    }
}
