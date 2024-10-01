//
//  ViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var sectionsView: [UIView]!
    @IBOutlet var labels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        sectionsView.forEach { view in
            view.layer.cornerRadius = 30
            view.addShadow()
        }
        labels.forEach({ $0.font = .medium(size: 16) })
    }

    @IBAction func clickedProductManagment(_ sender: UIButton) {
    }
    
    @IBAction func clickedOrderManagment(_ sender: UIButton) {
    }
    
    @IBAction func clickedAnalytics(_ sender: UIButton) {
    }
    
    @IBAction func clickedSettings(_ sender: UIButton) {
    }
}

