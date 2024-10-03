//
//  CoreDataManager.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Marketplace")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
//    func fetchMarketplaces(completion: @escaping ([Marketplace], Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                for marketplace in results {
//                    _ = marketplace.name // Force property to load
//                    print("Marketplace name: \(marketplace.name)")
//                }
//                DispatchQueue.main.async {
//                    completion(results, nil)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion([], error)
//                }
//            }
//        }
//    }
    
//    func fetchMarketplaces(completion: @escaping ([Marketplace], Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
//            
//            do {
//                let marketplaces = try backgroundContext.fetch(fetchRequest)
//                for marketplace in marketplaces {
//                    if let products = marketplace.products {
//                        for productInfo in products {
//                            print("Product Info - Remainder: \(productInfo.remainder), Sold: \(productInfo.sold)")
//                            if let product = productInfo.product {
//                                print("Product - Name: \(product.name ?? "No Name"), Price: \(product.price)")
//                            }
//                        }
//                    }
//                }
//                completion(marketplaces, nil) // Call completion with the fetched data
//            } catch {
//                completion([], error) // Call completion with the error
//            }
//        }
//        
//    }
    
    func fetchMarketplaces(completion: @escaping ([MarketplaceModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()

            do {
                // Fetch the Marketplace objects in the background context
                let marketplaces = try backgroundContext.fetch(fetchRequest)
                
                // Get their object IDs (thread-safe)
                let marketplaceObjectIDs = marketplaces.map { $0.objectID }
                
                // Switch to the main context to get the objects back
                DispatchQueue.main.async {
                    let mainContext = self.persistentContainer.viewContext
                    var marketplacesOnMainThread: [Marketplace] = []
                    
                    for objectID in marketplaceObjectIDs {
                        if let marketplace = try? mainContext.existingObject(with: objectID) as? Marketplace {
                            marketplacesOnMainThread.append(marketplace)
                        }
                    }
                    
                    var marketplacesModel: [MarketplaceModel] = []
//                    var productsInfoModel: [ProductInfoModel] = []
                    for marketplace in marketplacesOnMainThread {
                        var productsInfoModel: [ProductInfoModel] = []
                        for productInfo in marketplace.products ?? [] {
                            let infoModel = ProductInfoModel(product: ProductModel(id: productInfo.product?.id, name: productInfo.product?.name, price: productInfo.product?.price, quantity: Int(productInfo.product?.quantity ?? 0), photo: productInfo.product?.photo), remainder: Int(productInfo.remainder), sold: Int(productInfo.sold))
                            productsInfoModel.append(infoModel)
                        }
                        let marketplaceModel = MarketplaceModel(id: marketplace.id, name: marketplace.name, products: productsInfoModel)
                        marketplacesModel.append(marketplaceModel)
                    }
                    
                    completion(marketplacesModel, nil) // Call completion on the main thread
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion([], error) // Call completion on the main thread with the error
                }
            }
        }
    }
    
    func addDefaultMarketplaces(completion: @escaping (Error?) -> Void) {
        let marketplaces = ["Amazon", "Temu", "Ebay", "Aliexpress", "Ozon", "Wildberries"]
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            for marketplace in marketplaces {
                let newMarketplace = Marketplace(context: backgroundContext)
                newMarketplace.id = UUID()
                newMarketplace.name = marketplace
            }
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func addMarketplace(name: String, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                if results.count > 0 {
                    DispatchQueue.main.async {
                        completion(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Marketplace with the same name already exists."]))
                    }
                } else {
                    let newMarketplace = Marketplace(context: backgroundContext)
                    newMarketplace.id = UUID()
                    newMarketplace.name = name
                    newMarketplace.products = []
                    do {
                        try backgroundContext.save()
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func addProductsToMarketplaces(marketplaces: [MarketplaceInfoModel], completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let marketplaceIDs = marketplaces.map { $0.id }
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", marketplaceIDs)
            
            do {
                let fetchedMarketplaces = try backgroundContext.fetch(fetchRequest)
                
                for entry in marketplaces {
                        // Create a new ProductInfo object
                        let newProductInfo = ProductInfo(context: backgroundContext)
                        newProductInfo.remainder = Int32(entry.product?.remainder ?? 0)
                        newProductInfo.sold = Int32(entry.product?.sold ?? 0)
                    let product = Product(context: backgroundContext)
                    product.id = entry.product?.product?.id
                    product.name = entry.product?.product?.name
                    product.price = entry.product?.product?.price ?? 0
                    product.quantity = Int32(entry.product?.product?.quantity ?? 0)
                    product.photo = entry.product?.product?.photo
                    newProductInfo.product = product
                    if let marketplace = fetchedMarketplaces.first(where: { $0.id == entry.id }) {
                        var array: [ProductInfo] = []
                        if let products = marketplace.products as? Set<ProductInfo> {
                            array = Array(products)
                        } else {
                            array = []
                        }
                        array.append(newProductInfo)
                        marketplace.products = NSSet(array: array) as! Set<ProductInfo>
                    }
                }
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func save(marketplaces: [MarketplaceInfoModel], completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let marketplaceIDs = marketplaces.map { $0.id }
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", marketplaceIDs)
            
            do {
                let fetchedMarketplaces = try backgroundContext.fetch(fetchRequest)
                
                for entry in marketplaces {
                    // Fetch or create ProductInfo
                    if let marketplace = fetchedMarketplaces.first(where: { $0.id == entry.id }) {
                        var productInfo: ProductInfo?

                        if let products = marketplace.products, let existingProductInfo = products.first(where: { ($0 as! ProductInfo).product?.id == entry.product?.product?.id }) as? ProductInfo {
                            // Existing product info, update it
                            productInfo = existingProductInfo
                            productInfo?.remainder = Int32(entry.product?.remainder ?? 0)
                            productInfo?.sold = Int32(entry.product?.sold ?? 0)
                            productInfo?.product?.name = entry.product?.product?.name
                            productInfo?.product?.price = entry.product?.product?.price ?? 0
                            productInfo?.product?.quantity = Int32(entry.product?.product?.quantity ?? 0)
                            productInfo?.product?.photo = entry.product?.product?.photo
                        } else {
                            // Create new ProductInfo and Product
                            productInfo = ProductInfo(context: backgroundContext)
                            productInfo?.remainder = Int32(entry.product?.remainder ?? 0)
                            productInfo?.sold = Int32(entry.product?.sold ?? 0)
                            
                            let newProduct = Product(context: backgroundContext)
                            newProduct.id = entry.product?.product?.id
                            newProduct.name = entry.product?.product?.name
                            newProduct.price = entry.product?.product?.price ?? 0
                            newProduct.quantity = Int32(entry.product?.product?.quantity ?? 0)
                            newProduct.photo = entry.product?.product?.photo
                            productInfo?.product = newProduct
                            
                            // Append to marketplace's products
                            var array: [ProductInfo] = []
                            if let existingProducts = marketplace.products {
                                array = Array(existingProducts )
                            }
                            array.append(productInfo!)
                            marketplace.products = NSSet(array: array) as! Set<ProductInfo>
                        }
                    }
                }
                
                // Save the context
                do {
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    
    func fetchMarketplacesByProductID(id: UUID, completion: @escaping ([Marketplace], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            let predicate = NSPredicate(format: "SUBQUERY(products, $productInfo, SUBQUERY($productInfo.product, $product, $product.id == %@).@count > 0).@count > 0", id as CVarArg)
                fetchRequest.predicate = predicate
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func saleProduct(productID: UUID, marketplaceID: UUID, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            // Fetch the Marketplace by ID
            let marketplaceFetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            marketplaceFetchRequest.predicate = NSPredicate(format: "id == %@", marketplaceID as CVarArg)
            
            do {
                let fetchedMarketplaces = try backgroundContext.fetch(marketplaceFetchRequest)
                guard let marketplace = fetchedMarketplaces.first else {
                    // Marketplace not found
                    DispatchQueue.main.async {
                        completion(NSError(domain: "MarketplaceNotFound", code: 404, userInfo: nil))
                    }
                    return
                }
                
                // Find the ProductInfo in the marketplace by productID
                if let productInfo = marketplace.products?.first(where: { ($0 as! ProductInfo).product?.id == productID }) as? ProductInfo,
                   let product = productInfo.product {
                    
                    // Check if the product has enough quantity
                    if product.quantity > 0 && productInfo.remainder > 0 {
                        // Decrease quantity and remainder by 1
                        product.quantity -= 1
                        productInfo.remainder -= 1
                        
                        // Increase sold by 1
                        productInfo.sold += 1
                        
                        // Save the context
                        do {
                            try backgroundContext.save()
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(error)
                            }
                        }
                    } else {
                        // Insufficient quantity or remainder
                        DispatchQueue.main.async {
                            completion(NSError(domain: "InsufficientQuantity", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient quantity or remainder for product"]))
                        }
                    }
                } else {
                    // Product not found
                    DispatchQueue.main.async {
                        completion(NSError(domain: "ProductNotFound", code: 404, userInfo: nil))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
