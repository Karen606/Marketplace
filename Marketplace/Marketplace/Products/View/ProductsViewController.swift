//
//  ProductsViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit
import iOSDropDown
import Combine

class ProductsViewController: UIViewController {

    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var dropDownTextField: DropDown!
    private let viewModel = ProductsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fecthMarketplaces()
    }
    
    func setupUI() {
        setNavigationBackButton()
        setNavigationMenuButton()
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        dropDownTextField.font = .medium(size: 22)
        dropDownTextField.optionArray = []
        dropDownTextField.didSelect { [weak self] selectedText, index, id in
            guard let self = self else { return }
            self.viewModel.chooseMarketplace(marketplace: self.viewModel.marketplaces[index])
        }
        if let marketplace = viewModel.selectedMarketplace {
            dropDownTextField.text = marketplace.name
        }
    }
    
    func subscribe() {
        viewModel.$marketplaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketplaces in
                guard let self = self else { return }
                let array = marketplaces.map({ $0.name })
                self.dropDownTextField.optionArray = array
            }
            .store(in: &cancellables)
        
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
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
        self.navigationController?.pushViewController(productFormVC, animated: true)
    }
    
    @IBAction func handleTapDropDown(_ sender: UITapGestureRecognizer) {
        dropDownTextField.showList()
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        cell.setupData(product: viewModel.products[indexPath.row])
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
}


extension DropDown {
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 53))
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 53))
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 53))
    }
}
