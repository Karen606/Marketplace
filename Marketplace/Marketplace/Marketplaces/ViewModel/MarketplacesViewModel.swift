//
//  MarketplacesViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import Foundation

class MarketplacesViewModel {
    static let shared = MarketplacesViewModel()
    var marketplaces: [Marketplace] = []
    @Published var filteredMarketplaces: [Marketplace] = []
    var search: String?
    
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplaces, error in
            guard let self = self else { return }
            self.marketplaces = marketplaces
            self.filter(by: search)
        }
    }
    
    func addMarketplace(name: String, completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.addMarketplace(name: name) { [weak self] error in
            guard let self = self else { return }
            completion(error)
            self.fetchData()
        }
    }
    
    func filter(by value: String?) {
        self.search = value
        if let value = value, !value.isEmpty {
            filteredMarketplaces = marketplaces.filter { ($0.name).localizedCaseInsensitiveContains(value) }
        } else {
            filteredMarketplaces = marketplaces
        }
    }
    
    func clear() {
        search = nil
        filteredMarketplaces = []
    }
}

