//
//  ProductViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import Foundation

class ProductViewModel {
    static let shared = ProductViewModel()
    @Published var marketplaces: [MarketplaceModel] = []
    var selectedMarketplaces: [MarketplaceInfoModel] = []
    var productID: UUID?
    
    private init() {}
    
    func fetchMarketplaces() {
        guard let id = productID else { return }
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            var filteredMarketplaces = marketplaces.filter { marketplace in
                return marketplace.products.contains(where: { $0.product?.id == id })
            }
            
            for index in filteredMarketplaces.indices {
                filteredMarketplaces[index].products = filteredMarketplaces[index].products.filter { $0.product?.id == id }
            }
            self.marketplaces = filteredMarketplaces
        }
    }
    
    func calculateEarnings() -> String {
        var sum: Double = 0
        marketplaces.forEach { marketplace in
            sum += (marketplace.products.first?.product?.price ?? 0) * Double(marketplace.products.first?.sold ?? 0)
        }
        return "\(sum)$"
    }

    func saleProduct(marketplaceID: UUID, completion: @escaping (Error?) -> Void) {
        guard let productID = productID else { return }
        CoreDataManager.shared.saleProduct(productID: productID, marketplaceID: marketplaceID) { error in
            completion(error)
        }
    }
    
    func clear() {
        productID = nil
        marketplaces = []
        selectedMarketplaces = []
    }
}
