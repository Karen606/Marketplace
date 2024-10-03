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
                let product = marketplaces[0].products?.first
                let marketplaces = self.viewModel.marketplaces.compactMap { $0.name }.joined(separator: ", ")
                self.nameLabel.text = product?.product?.name
                self.infoLabels[0].text = "Price: \(product?.product?.price ?? 0)$"
                self.infoLabels[1].text = "Earnings:"
                self.infoLabels[2].text = "On sale at: \(marketplaces)"
                self.infoLabels[3].text = "Remainder: \(product?.remainder ?? 0)"
                if let data = product?.product?.photo {
                    self.imageView.image = UIImage(data: data)
                } else {
                    self.imageView.image = nil
                }
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
