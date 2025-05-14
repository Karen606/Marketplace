//
//  OrderManagmentViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 21.10.24.
//

import Foundation

class OrderManagmentViewModel {
    static let shared = OrderManagmentViewModel()
    @Published var products: [ProductInfoModel] = []
    @Published var marketplaces: [MarketplaceModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchAllUniqueProductInfo { [weak self] result, error in
            guard let self = self else { return }
            self.products = (result).sorted(by: { $0.product?.name ?? "" < $1.product?.name ?? ""})
        }
        
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            self.marketplaces = marketplaces
        }
    }
    
    func clear() {
        products = []
    }
}
