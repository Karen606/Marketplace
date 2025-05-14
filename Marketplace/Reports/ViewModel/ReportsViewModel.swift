//
//  ReportsViewModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import Foundation

class ReportsViewModel {
    static let shared = ReportsViewModel()
    @Published var reports: [ReportModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchMarketplaces { [weak self] marketplace, error in
            guard let self = self else { return }
            var reportsModel: [ReportModel] = []
            var totalStock = 0
            var totalEarnings = 0
            var totalSold = 0
            for marketplaceModel in marketplace {
                let totalMarketplaceStock
                = marketplaceModel.products.reduce(0) { sum, marketplace in
                    sum + (marketplace.remainder ?? 0)
                }
                totalStock += totalMarketplaceStock
                let earnings = marketplaceModel.products.reduce(0) { sum, marketplace in
                    sum + Int((marketplace.product?.price ?? 0)) * (marketplace.sold ?? 0)
                }
                let sold = marketplaceModel.products.reduce(0) { sum, marketplace in
                    sum + (marketplace.sold ?? 0)
                }
                totalEarnings += earnings
                let reportModel = ReportModel(name: marketplaceModel.name ?? "", stock: totalMarketplaceStock)
                reportsModel.append(reportModel)
            }
            let totalStockModel = ReportModel(name: "Stock balance", stock: totalStock)
            let totalEarningsModel = ReportModel(name: "Total earnings", stock: totalEarnings)
            let totalSoldModel = ReportModel(name: "Products sold", stock: totalEarnings)
            reportsModel.insert(totalEarningsModel, at: 0)
            reportsModel.insert(totalSoldModel, at: 0)
            reportsModel.insert(totalStockModel, at: 0)
            self.reports = reportsModel
        }
    }
    
    func clear() {
        reports = []
    }
}

