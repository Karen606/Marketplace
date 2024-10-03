//
//  ProductFormViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import Foundation

class ProductFormViewModel {
    static let shared = ProductFormViewModel()
    var marketPlaces: [MarketplaceModel] = []
    @Published var product: ProductModel = ProductModel(id: UUID())
    @Published var selectedMarketplaces: [MarketplaceInfoModel] = [MarketplaceInfoModel()]
    var previousSelectedMarketplacesCount: Int = 1

    func chooseMarketplace(marketplace: MarketplaceModel, index: Int) -> Bool {
        if selectedMarketplaces.contains(where: { $0.id == marketplace.id && selectedMarketplaces[index].id != marketplace.id }) {
            return false
        } else {
            selectedMarketplaces[index].id = marketplace.id
            selectedMarketplaces[index].name = marketplace.name
            if selectedMarketplaces[index].product == nil {
                selectedMarketplaces[index].product = ProductInfoModel(product: product)
            }
            return true
        }
    }
    
    func setRemainder(id: UUID, remainder: Int?) {
        if let index = selectedMarketplaces.firstIndex(where: { $0.id == id }) {
            selectedMarketplaces[index].product?.remainder = remainder
        }
    }
    
    func addMarketplace() {
        selectedMarketplaces.append(MarketplaceInfoModel())
    }
    
    private init() {
        previousSelectedMarketplacesCount = selectedMarketplaces.count
    }
    
    func saveProduct(completion: @escaping (Error?) -> Void) {
        for index in selectedMarketplaces.indices {
            selectedMarketplaces[index].product?.product = product
        }
        CoreDataManager.shared.addProductsToMarketplaces(marketplaces: selectedMarketplaces) { error in
            completion(error)
        }
    }
    
    func clear() {
        marketPlaces = []
        selectedMarketplaces = [MarketplaceInfoModel()]
        previousSelectedMarketplacesCount = 1
        product = ProductModel(id: UUID())
    }
}
