//
//  RootViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 14.05.25.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let menuVC = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") {
            self.navigationController?.viewControllers = [menuVC]
        }
    }
}
