//
//  MarketplaceTableViewCell.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit

class MarketplaceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: PaddingLabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.font = .medium(size: 22)
        bgView.layer.cornerRadius = 15
        bgView.addShadow()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupData(name: String?) {
        nameLabel.text = name
    }
    
}
