//
//  BaseButton.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import UIKit

class BaseButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? .buttonBlue.withAlphaComponent(1) : .buttonBlue.withAlphaComponent(0.5)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
