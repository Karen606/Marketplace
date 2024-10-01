//
//  MarketplaceModel.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import Foundation

struct MarketplaceModel {
    var id: UUID?
    var name: String?
    var products: [ProductInfoModel] = []
}

struct ProductInfoModel {
    var product: ProductModel?
    var remainder: Int?
    var sold: Int?
}

struct ProductModel {
    var id: UUID?
    var name: String?
    var price: Double?
    var quantity: Int?
}
