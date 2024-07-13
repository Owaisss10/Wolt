//
//  CoreDataManager.swift
//  Wolt
//
//  Created by Awais Akram on 10.7.2024.
//

import CoreData
import Combine

class CoreDataManager {
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

    func fetchFavoriteItem(withId id: String) -> AnyPublisher<NSManagedObject?, Error> {
        Future<NSManagedObject?, Error> { [weak self] promise in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteItem")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)

            do {
                let results = try self.context.fetch(fetchRequest)
                promise(.success(results.first))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchFavoriteItems() -> AnyPublisher<[NSManagedObject], Error> {
        Future<[NSManagedObject], Error> { [weak self] promise in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteItem")

            do {
                let results = try self.context.fetch(fetchRequest)
                promise(.success(results))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

