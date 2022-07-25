//
//  File.swift
//  
//
//  Created by MOH on 2022-07-16.
//

import Foundation
import CoreData
@testable import MKOrderedManagedObjectArray

class InMemoryStore {
    
    private let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var url: URL? {
        persistentContainer.persistentStoreCoordinator.persistentStores.first?.url
    }
    
    
    // Store a static reference to the ManagedObjectModel
    // This emoves a warning that occurs during unit testing:
    // "Multiple NSEntityDescriptions claim NSManagedObject subclass."
    // https://stackoverflow.com/questions/51851485/multiple-nsentitydescriptions-claim-nsmanagedobject-subclass
    
    private static let model: NSManagedObjectModel = {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: "TestModel", withExtension: ".momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    init() {
        let model = Self.model
        let container = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.persistentContainer  = container
    }
    
   
    
    
}



