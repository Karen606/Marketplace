//
//  ProductViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import UIKit
import Combine

class ProductViewController: UIViewController {

    @IBOutlet weak var marketplacesTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var infoLabels: [UILabel]!
    private let viewModel = ProductViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        marketplacesTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setupUI()
        subscribe()
        viewModel.fetchMarketplaces()
    }
    
    func setupUI() {
        setNavigationBackButton()
        setNavigationMenuButton()
        nameLabel.font = .medium(size: 16)
        infoLabels.forEach({ $0.font = .regular(size: 14) })
        marketplacesTableView.delegate = self
        marketplacesTableView.dataSource = self
        marketplacesTableView.register(UINib(nibName: "MarketplaceInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "MarketplaceInfoTableViewCell")
    }
    
    func subscribe() {
        viewModel.$marketplaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketplaces in
                guard let self = self, !marketplaces.isEmpty else { return }
                let product = marketplaces[0].products.first
                let marketplaces = self.viewModel.marketplaces.compactMap { $0.name }.joined(separator: ", ")
                self.nameLabel.text = product?.product?.name
                self.infoLabels[0].text = "Price: \(product?.product?.price ?? 0)$"
                self.infoLabels[1].text = "Earnings: \(self.viewModel.calculateEarnings())"
                self.infoLabels[2].text = "On sale at: \(marketplaces)"
                self.infoLabels[3].text = "Remainder: \((product?.product?.quantity ?? 0) - self.viewModel.calculateTotalRemainder())"
                if let data = product?.product?.photo {
                    self.imageView.image = UIImage(data: data)
                } else {
                    self.imageView.image = nil
                }
                self.marketplacesTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }

    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func clickedEdit(_ sender: UIButton) {
        let productFormVC = ProductFormViewController(nibName: "ProductFormViewController", bundle: nil)
        var marketplacesModel: [MarketplaceModel] = []
        for marketplace in MarketplacesViewModel.shared.marketplaces {
            let marketplaceModel = MarketplaceModel(id: marketplace.id, name: marketplace.name)
            marketplacesModel.append(marketplaceModel)
        }
        
        ProductFormViewModel.shared.marketPlaces = marketplacesModel
        if !viewModel.marketplaces.isEmpty, let product = viewModel.marketplaces.first?.products.first?.product {
            ProductFormViewModel.shared.product = ProductModel(id: product.id, name: product.name, price: product.price, quantity: Int(product.quantity ?? 0), photo: product.photo)
        }
        ProductFormViewModel.shared.fetchMarketplaces()
        ProductFormViewModel.shared.isEditing = true
        ProductFormViewModel.shared.selectedMarketplaces = viewModel.selectedMarketplaces
        productFormVC.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchMarketplaces()
            }
        }
        self.navigationController?.pushViewController(productFormVC, animated: true)
    }
    
    deinit {
        viewModel.clear()
    }
}

extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.marketplaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketplaceInfoTableViewCell", for: indexPath) as! MarketplaceInfoTableViewCell
        cell.setupData(marketplace: viewModel.marketplaces[indexPath.row])
        return cell
    }
}
