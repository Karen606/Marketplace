//
//  Marketplace+CoreDataProperties.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//
//

import Foundation
import CoreData


extension Marketplace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Marketplace> {
        return NSFetchRequest<Marketplace>(entityName: "Marketplace")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var products: Set<ProductInfo>?

}

extension Marketplace : Identifiable {

}
