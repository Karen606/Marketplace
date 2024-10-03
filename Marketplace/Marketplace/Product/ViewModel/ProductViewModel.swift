//
//  ProductViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import Foundation

class ProductViewModel {
    static let shared = ProductViewModel()
    @Published var marketplaces: [Marketplace] = []
    var productID: UUID?
    
    private init() {}
    
    func fetchMarketplaces() {
        guard let id = productID else { return }
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            let filteredMarketplaces = marketplaces.filter { marketplace in
                return marketplace.products?.contains(where: { $0.product?.id == id }) ?? false
            }
            
            for filteredMarketplace in filteredMarketplaces {
                filteredMarketplace.products = filteredMarketplace.products?.filter { $0.product?.id == id }
            }
            self.marketplaces = filteredMarketplaces
        }
    }

    func saleProduct() {
        
    }
    
    func clear() {
        productID = nil
        for marketplace in marketplaces {
            CoreDataManager.shared.persistentContainer.viewContext.refresh(marketplace, mergeChanges: false)
        }
        marketplaces = []
    }
}
