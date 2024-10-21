//
//  OrderManagmentViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 21.10.24.
//

import UIKit
import Combine

class OrderManagmentViewController: UIViewController {
    
    @IBOutlet weak var productsTableView: UITableView!
    private let viewModel = OrderManagmentViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNavigationBackButton()
        setNavigationMenuButton()
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
    }
    
    func subscribe() {
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                self.productsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$marketplaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketplaces in
                guard let self = self else { return }
                self.productsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addProduct() {
        let productFormVC = ProductFormViewController(nibName: "ProductFormViewController", bundle: nil)
        var marketplacesModel: [MarketplaceModel] = []
        for marketplace in viewModel.marketplaces {
            let marketplaceModel = MarketplaceModel(id: marketplace.id, name: marketplace.name)
            marketplacesModel.append(marketplaceModel)
        }
        ProductFormViewModel.shared.marketPlaces = marketplacesModel
        productFormVC.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchData()
            }
        }
        self.navigationController?.pushViewController(productFormVC, animated: true)
    }
}

extension OrderManagmentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        cell.setupAllMarketplacesData(product: viewModel.products[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .center
        button.setImage(UIImage(named: "Add"), for: .normal)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .bold(size: 20)
        button.setTitleColor(.baseBlue, for: .normal)
        button.addTarget(self, action: #selector(addProduct), for: .touchUpInside)
        button.frame = CGRect(x: (footerView.frame.width - 120) / 2, y: (footerView.frame.height - 30) / 2, width: 120, height: 30)
        footerView.addSubview(button)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productVC = ProductViewController(nibName: "ProductViewController", bundle: nil)
        ProductViewModel.shared.productID = viewModel.products[indexPath.row].product?.id
        self.navigationController?.pushViewController(productVC, animated: true)
    }
}
