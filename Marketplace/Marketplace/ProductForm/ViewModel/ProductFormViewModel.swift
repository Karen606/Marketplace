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
    @Published var isEditing = false
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
    
    func fetchMarketplaces() {
        guard let id = product.id else { return }
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            var filteredMarketplaces = marketplaces.filter { marketplace in
                return marketplace.products.contains(where: { $0.product?.id == id }) ?? false
            }
            
            for index in filteredMarketplaces.indices {
                filteredMarketplaces[index].products = filteredMarketplaces[index].products.filter { $0.product?.id == id }
            }
            var marketplacesModel: [MarketplaceInfoModel] = []
            
            for marketplace in filteredMarketplaces {
                let model = MarketplaceInfoModel(id: marketplace.id, name: marketplace.name, product: ProductInfoModel(product: ProductModel(id: marketplace.products.first?.product?.id, name: marketplace.products.first?.product?.name, price: marketplace.products.first?.product?.price, quantity: Int(marketplace.products.first?.product?.quantity ?? 0), photo: marketplace.products.first?.product?.photo), remainder: Int(marketplace.products.first?.remainder ?? 0), sold: Int(marketplace.products.first?.sold ?? 0)))
                marketplacesModel.append(model)
            }
            self.selectedMarketplaces = marketplacesModel
        }
    }
    
    func setRemainder(id: UUID, remainder: Int?) -> Bool {
        guard let index = selectedMarketplaces.firstIndex(where: { $0.id == id }) else { return false }
        let total = selectedMarketplaces.reduce(0) { sum, marketplace in
            sum + (marketplace.product?.remainder ?? 0)
        }
        let stock = (product.quantity ?? 0) - total + (selectedMarketplaces[index].product?.remainder ?? 0)
        
        if (remainder ?? 0) > stock {
            selectedMarketplaces[index].product?.remainder = nil
            return false
        }
        selectedMarketplaces[index].product?.remainder = remainder
        return true
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
        
        if isEditing {
            CoreDataManager.shared.save(marketplaces: selectedMarketplaces) { error in
                completion(error)
            }
        } else {
            CoreDataManager.shared.addProductsToMarketplaces(marketplaces: selectedMarketplaces) { error in
                completion(error)
            }
        }
        
    }
    
    func clear() {
        marketPlaces = []
        selectedMarketplaces = [MarketplaceInfoModel()]
        previousSelectedMarketplacesCount = 1
        product = ProductModel(id: UUID())
        isEditing = false
    }
}
