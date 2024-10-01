//
//  Product+CoreDataProperties.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int32

}

extension Product : Identifiable {

}
