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
    
    func fetchMarketplaces(completion: @escaping ([Marketplace], Error?) -> Void) {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Marketplace> = Marketplace.fetchRequest()
            
            do {
                let marketplaces = try context.fetch(fetchRequest)
                completion(marketplaces, nil) // Call completion with the fetched data
            } catch {
                completion([], error) // Call completion with the error
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

    
    
    
//    func saveRecord(recordModel: RecordModel?, completion: @escaping (Error?) -> Void) {
//        let id = recordModel?.id ?? UUID()
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                let record: Record
//
//                if let existingMaterial = results.first {
//                    record = existingMaterial
//                } else {
//                    record = Record(context: backgroundContext)
//                    record.id = id
//                }
//                record.name = recordModel?.name
//                record.email = recordModel?.email
//                record.phone = recordModel?.phoneNumber
//                record.typeOfManicure = recordModel?.type
//                record.designAndColor = recordModel?.design
//                record.date = recordModel?.date
//                record.time = recordModel?.time
//                try backgroundContext.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
//    }
//    
//    func removeRecord(id: UUID, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                if let recordToDelete = results.first {
//                    backgroundContext.delete(recordToDelete)
//                    try backgroundContext.save()
//                    completion(nil)
//                } else {
//                    let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Record not found"])
//                    completion(error)
//                }
//            } catch {
//                completion(error)
//            }
//        }
//    }
//    
//    func fetchDesigns(completion: @escaping ([DesignModel], Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Design> = Design.fetchRequest()
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                var designModels: [DesignModel] = []
//                for result in results {
//                    let designModel = DesignModel(id: result.id, photo: result.photo, title: result.title)
//                    designModels.append(designModel)
//                }
//                completion(designModels, nil)
//            } catch {
//                completion([], error)
//            }
//        }
//    }
//    
//    func saveDesign(designModel: DesignModel?, completion: @escaping (Error?) -> Void) {
//        let id = designModel?.id ?? UUID()
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Design> = Design.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                let design: Design
//
//                if let existingMaterial = results.first {
//                    design = existingMaterial
//                } else {
//                    design = Design(context: backgroundContext)
//                    design.id = id
//                }
//                design.photo = designModel?.photo
//                design.title = designModel?.title
//                try backgroundContext.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
//    }
//    
//    func fetchMaterials(completion: @escaping ([MaterialModel], Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                var materialModels: [MaterialModel] = []
//                for result in results {
//                    let materialModel = MaterialModel(id: result.id, photo: result.photo, title: result.title, count: result.count)
//                    materialModels.append(materialModel)
//                }
//                completion(materialModels, nil)
//            } catch {
//                completion([], error)
//            }
//        }
//    }
//    
//    func saveMaterial(materialModel: MaterialModel?, completion: @escaping (Error?) -> Void) {
//        let id = materialModel?.id ?? UUID()
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                let material: Material
//
//                if let existingMaterial = results.first {
//                    material = existingMaterial
//                } else {
//                    material = Material(context: backgroundContext)
//                    material.id = id
//                }
//                material.photo = materialModel?.photo
//                material.title = materialModel?.title
//                material.count = materialModel?.count ?? 1
//                try backgroundContext.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
//    }
//    
//    func incrementMaterialCount(by id: UUID, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                if let material = results.first {
//                    material.count += 1
//                    try backgroundContext.save()
//                    completion(nil)
//                } else {
//                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Material not found"]))
//                }
//            } catch {
//                completion(error)
//            }
//        }
//    }
//
//    func decrementMaterialCount(by id: UUID, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                if let material = results.first {
//                    if material.count > 0 {
//                        material.count -= 1
//                        try backgroundContext.save()
//                        completion(nil)
//                    } else {
//                        completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Material count is already zero"]))
//                    }
//                } else {
//                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Material not found"]))
//                }
//            } catch {
//                completion(error)
//            }
//        }
//    }
}
