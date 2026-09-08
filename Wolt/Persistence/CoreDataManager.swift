//
//  CoreDataManager.swift
//  Wolt
//
//  Created by Awais Akram on 10.7.2024.
//

import CoreData

class CoreDataManager {
    // MARK: - Variables
    static let shared = CoreDataManager()

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

    // MARK: - Functions
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreDataManager.saveContext failed with error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Save an item
    func saveFavoriteItem(id: String) {
        do {
            let entity = NSEntityDescription.entity(forEntityName: "FavoriteItem", in: context)!
            let newVenue = NSManagedObject(entity: entity, insertInto: context)
            newVenue.setValue(id, forKey: "id")
            newVenue.setValue(true, forKey: "isFavorite")

            try context.save()
        } catch {
            print("Favorite item saving failed with error: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete an item
    func deleteFavoriteItem(for id: String) {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Favorite item deleting failed with error: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch all saved items
    func fetchFavoriteItems() -> [FavoriteItem] {
        do {
            let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
            return try context.fetch(fetchRequest)
        } catch {
            print("Favorite items fetching failed with error: \(error.localizedDescription)")
            return []
        }
    }
}
