//
//  ProductInfo+CoreDataProperties.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//
//

import Foundation
import CoreData


extension ProductInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductInfo> {
        return NSFetchRequest<ProductInfo>(entityName: "ProductInfo")
    }

    @NSManaged public var remainder: Int32
    @NSManaged public var sold: Int32
    @NSManaged public var product: Product?

}

extension ProductInfo : Identifiable {

}
