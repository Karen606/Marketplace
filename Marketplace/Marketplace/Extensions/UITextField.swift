//
//  UITextField.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit

extension UITextField {
    var isValid: Bool {
        return self.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
}
