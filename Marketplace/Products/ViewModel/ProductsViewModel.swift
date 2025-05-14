//
//  ProductViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import Foundation

class ProductsViewModel {
    static let shared = ProductsViewModel()
    @Published var marketplaces: [MarketplaceModel] = []
    @Published var products: [ProductInfoModel] = []
    var selectedMarketplace: MarketplaceModel?
    
    
    private init() {}
    
    func fecthMarketplaces() {
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            self.marketplaces = marketplaces
            if let selectedMarketplace = selectedMarketplace {
                self.selectedMarketplace = marketplaces.first(where: { $0.id == selectedMarketplace.id })
            }
            self.products = (selectedMarketplace?.products ?? []).sorted(by: { $0.product?.name ?? "" < $1.product?.name ?? ""})
        }
    }
    
    func chooseMarketplace(marketplace: MarketplaceModel) {
        self.selectedMarketplace = marketplace
        self.products = marketplace.products
    }
    
    func clear() {
        marketplaces = []
        products = []
        selectedMarketplace = nil
    }
    
}
