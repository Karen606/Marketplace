//
//  ReportCollectionViewCell.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import UIKit

class ReportCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: PaddingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = #colorLiteral(red: 0.3138786554, green: 0.6180545688, blue: 1, alpha: 1)
        numberLabel.font = .bold(size: 36)
        descriptionLabel.leftInset = 4
        descriptionLabel.rightInset = 4
        descriptionLabel.font = .regular(size: 16)
        self.layer.cornerRadius = 19
        self.layer.masksToBounds = true
    }
    
    func setupData(report: ReportModel, index: Int) {
        switch index {
        case 0...1:
            numberLabel.text = "\(report.stock)"
            descriptionLabel.text = report.name
        case 2:
            numberLabel.text = "\(report.stock)$"
            descriptionLabel.text = report.name
        default:
            numberLabel.text = "\(report.stock)"
            descriptionLabel.text = "The rest of the product on the \(report.name)"
        }
    }
}
