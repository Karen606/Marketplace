//
//  ProductTableViewCell.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketplaceLabel: UILabel!
    @IBOutlet weak var soldCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.font = .medium(size: 16)
        marketplaceLabel.font = .regular(size: 14)
        soldCountLabel.font = .regular(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupData(product: ProductInfoModel) {
        nameLabel.text = product.product?.name
        marketplaceLabel.text = "\(ProductsViewModel.shared.selectedMarketplace?.name ?? "") warehouse: \(product.remainder ?? 0)"
        let sold = "Sold \(product.sold ?? 0)"
        let attributedString = NSMutableAttributedString(string: sold)
        let range = NSRange(location: 0, length: sold.count)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)

        soldCountLabel.attributedText = attributedString
        if let data = product.product?.photo {
            productImageView.image = UIImage(data: data)
        } else {
            return
        }
    }
    
    func setupAllMarketplacesData(product: ProductInfoModel) {
        nameLabel.text = product.product?.name
       
        if let data = product.product?.photo {
            productImageView.image = UIImage(data: data)
        } else {
            return
        }
        var totalRemainder = 0
        var totalSold = 0
        OrderManagmentViewModel.shared.marketplaces.forEach { marketplace in
            let product = marketplace.products.first(where: { $0.product?.id == product.product?.id })
            totalRemainder += product?.remainder ?? 0
            totalSold += product?.sold ?? 0
        }
        marketplaceLabel.text = "All warehouses: \(totalRemainder)"
        let sold = "Sold \(totalSold)"
        let attributedString = NSMutableAttributedString(string: sold)
        let range = NSRange(location: 0, length: sold.count)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)

        soldCountLabel.attributedText = attributedString
    }
    
}
