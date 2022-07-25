//
//  MKOrderedManagedObjectArrayController.swift
//
//
//  Created by MOH on 2022-07-16.
//

import CoreData

open class MKOrderedManagedObjectArrayController<T: MKOrderedManagedObject> {
    
    public let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    open func fetch() -> [T] {
        let request = NSFetchRequest<T>(entityName: T.entity().name!)
        request.sortDescriptors = [.byArrayIndex()]
        do {
            return try context.fetch(request)
        } catch {
            print("OrderedManagedObject fetch failed with error: \(error)")
            return []
        }
    }
    
    @discardableResult
    open func append(_ creationHandler: ((NSManagedObjectContext, Int64) throws -> T)) rethrows  -> T{
        let index = endIndex()
        do {
            let created = try creationHandler(context, index)
            created.arrayIndex = index
            return created
        } catch {
            throw error
        }
    }
    
    open func delete(at index: Int) throws {
        var fetched = fetch()
        if fetched[index].isDeleted {
            throw MKOrderedManagedObjectError.itemMissing
        }
        let removed = fetched.remove(at: index)
        context.delete(removed)
        reassignIndices(fetched: fetched)
    }
    
    open func delete(_ item: T) throws {
        guard !item.isDeleted else {
            throw MKOrderedManagedObjectError.itemMissing
        }
        let fetched = fetch()
        if let index = fetched.firstIndex(of: item) {
            do {
                try delete(at: index)
            } catch {
                throw MKOrderedManagedObjectError.itemMissing
            }
        }
    }
    
    open func move(itemAt index: Int, to destIndex: Int) throws {
        if index == destIndex { return }
        var fetched = fetch()
        guard !fetched[index].isDeleted else {
            throw MKOrderedManagedObjectError.itemMissing
        }
        let removed = fetched.remove(at: index)
        fetched.insert(removed, at: destIndex)
        reassignIndices(fetched: fetched)
    }
    
    open func swap(_ srcIndex: Int, _ destIndex: Int) throws {
        if srcIndex == destIndex { return }
        let fetched = fetch()
        guard !fetched[srcIndex].isDeleted,
              !fetched[destIndex].isDeleted
        else {
            throw MKOrderedManagedObjectError.itemMissing
        }
        fetched[srcIndex].arrayIndex = Int64(destIndex)
        fetched[destIndex].arrayIndex = Int64(srcIndex)
    }
    
    public final func endIndex() -> Int64 {
        Int64(fetch().count)
    }
    
    private func reassignIndices(fetched: [T]) {
        for i in 0..<fetched.count {
            fetched[i].arrayIndex = Int64(i)
        }
    }

    
}



