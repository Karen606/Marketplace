//
//  MarketplacesViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit
import Combine

class MarketplacesViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var marketplaceTableView: UITableView!
    private let viewModel = MarketplacesViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        searchTextField.addShadow()
        setNavigationBackButton()
        setNavigationMenuButton()
        marketplaceTableView.delegate = self
        marketplaceTableView.dataSource = self
        marketplaceTableView.register(UINib(nibName: "MarketplaceTableViewCell", bundle: nil), forCellReuseIdentifier: "MarketplaceTableViewCell")
        searchTextField.delegate = self
    }
    
    func subscribe() {
        viewModel.$filteredMarketplaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketplaces in
                guard let self = self else { return }
                self.marketplaceTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addMarketplace() {
        let marketplaceFormVC = MarketplaceFormViewController(nibName: "MarketplaceFormViewController", bundle: nil)
        self.navigationController?.pushViewController(marketplaceFormVC, animated: true)
    }
}

extension MarketplacesViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.filter(by: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension MarketplacesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMarketplaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketplaceTableViewCell", for: indexPath) as! MarketplaceTableViewCell
        cell.setupData(name: viewModel.filteredMarketplaces[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .center
        button.setImage(UIImage(named: "Add"), for: .normal)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .bold(size: 20)
        button.setTitleColor(.baseBlue, for: .normal)
        button.addTarget(self, action: #selector(addMarketplace), for: .touchUpInside)
        button.frame = CGRect(x: (footerView.frame.width - 120) / 2, y: (footerView.frame.height - 30) / 2, width: 120, height: 30)
        footerView.addSubview(button)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productsVC = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
        ProductsViewModel.shared.chooseMarketplace(marketplace: viewModel.marketplaces[indexPath.row])
        self.navigationController?.pushViewController(productsVC, animated: true)
    }
}
