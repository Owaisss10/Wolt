//
//  CoreDataManager.swift
//  Wolt
//
//  Created by Awais Akram on 10.7.2024.
//

import CoreData
import Combine

class CoreDataManager {
//    static let shared = CoreDataManager()
//
//    private init() {}
//
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "RestaurantDB")
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
//
//    var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//
//    func saveContext() {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    static let shared = CoreDataManager()

        private init() {}

        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "RestaurantDB")
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()

        var context: NSManagedObjectContext {
            return persistentContainer.viewContext
        }

        func saveContext() -> AnyPublisher<Void, Error> {
            return Future<Void, Error> { [weak self] promise in
                guard let self = self else { return }
                let context = self.persistentContainer.viewContext
                if context.hasChanges {
                    do {
                        try context.save()
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                } else {
                    promise(.success(()))
                }
            }
            .eraseToAnyPublisher()
        }
}

