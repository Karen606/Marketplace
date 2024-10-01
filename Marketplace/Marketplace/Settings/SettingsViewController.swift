//
//  SettingsViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var sectionButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBackButton()
        sectionButton.forEach({ $0.titleLabel?.font = .medium(size: 24); $0.addShadow(); $0.layer.cornerRadius = 30 })
    }

    @IBAction func clickedContactUs(_ sender: UIButton) {
    }
    
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
    }
    
    @IBAction func clickedRateUs(_ sender: UIButton) {
    }
}
