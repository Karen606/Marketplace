//
//  MarketplaceInfoTableViewCell.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import UIKit

class MarketplaceInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var marketplaceLabel: UILabel!
    @IBOutlet weak var soldLabel: UILabel!
    @IBOutlet weak var saleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        marketplaceLabel.font = .regular(size: 14)
        soldLabel.font = .regular(size: 14)
        saleButton.titleLabel?.font = .medium(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupData(marketplace: Marketplace) {
        marketplaceLabel.text = "\(marketplace.name) warehouse: \(marketplace.products?.first?.remainder ?? 0)"
        let sold = "Sold \(marketplace.products?.first?.sold ?? 0)"
        let attributedString = NSMutableAttributedString(string: sold)
        let range = NSRange(location: 0, length: sold.count)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        soldLabel.attributedText = attributedString
    }
    
    @IBAction func clickedSale(_ sender: UIButton) {
        
    }
}
