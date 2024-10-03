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
        let marketplaceVC = MarketplacesViewController(nibName: "MarketplacesViewController", bundle: nil)
        self.navigationController?.pushViewController(marketplaceVC, animated: true)
    }
    
    @IBAction func clickedOrderManagment(_ sender: UIButton) {
    }
    
    @IBAction func clickedAnalytics(_ sender: UIButton) {
        let reportsVC = ReportsViewController(nibName: "ReportsViewController", bundle: nil)
        self.navigationController?.pushViewController(reportsVC, animated: true)
    }
    
    @IBAction func clickedSettings(_ sender: UIButton) {
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
}

