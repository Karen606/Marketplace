//
//  ProductViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import Foundation

class ProductsViewModel {
    static let shared = ProductsViewModel()
    @Published var marketplaces: [Marketplace] = []
    @Published var products: [ProductInfo] = []
    var selectedMarketplace: Marketplace?
    
    
    private init() {}
    
    func fecthMarketplaces() {
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            self.marketplaces = marketplaces
            if let productsInfo = selectedMarketplace?.products as? Set<ProductInfo> {
                self.products = Array(productsInfo)
            }
        }
    }
    
    func chooseMarketplace(marketplace: Marketplace) {
        self.selectedMarketplace = marketplace
        if let productsInfo = marketplace.products as? Set<ProductInfo> {
            self.products = Array(productsInfo)
        }
    }
    
    func clear() {
        marketplaces = []
        products = []
        selectedMarketplace = nil
    }
    
}
