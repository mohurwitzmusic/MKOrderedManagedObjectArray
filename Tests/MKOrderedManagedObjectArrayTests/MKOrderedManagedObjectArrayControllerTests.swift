//
//  OrderedManagedObjectArrayControllerTests.swift
//  
//
//  Created by MOH on 2022-07-16.
//

import XCTest
import CoreData
@testable import MKOrderedManagedObjectArray

extension TestItem: MKOrderedManagedObject { }

class MKOrderedManagedObjectArrayControllerTests: XCTestCase {
    
    var store: InMemoryStore!
    var arrayController: MKOrderedManagedObjectArrayController<TestItem>!

    override func setUp() {
        super.setUp()
        store = .init()
        arrayController = .init(context: store.context)
    }
    
    func test_noItemsCreated_fetchCountEqualsZero() {
        XCTAssertEqual(arrayController.fetch().count, 0)
    }
    
    func test_appendItems_indicesAreIncremented() {
        createTestItems(count: 5)
        let fetched = arrayController.fetch()
        XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2, 3, 4])
        XCTAssertEqual(fetched.names(), ["0", "1", "2", "3", "4"])
    }
    
    func test_deleteItemAtIndex_indicesAreReincremented() {
        createTestItems(count: 4)
        do {
            try arrayController.delete(at: 1)
            var fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2])
            XCTAssertEqual(fetched.names(), ["0", "2", "3"] )
            try arrayController.delete(at: 0)
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1])
            XCTAssertEqual(fetched.names(), ["2", "3"])
            try arrayController.delete(at: 1)
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0])
            XCTAssertEqual(fetched.names(), ["2"])
            try arrayController.delete(at: 0)
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [])
            XCTAssertEqual(fetched.names(), [])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_deleteItem_indicesAreReincremented() {
        createTestItems(count: 2)
        do {
            var fetched = arrayController.fetch()
            try arrayController.delete(fetched[0])
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0])
            XCTAssertEqual(fetched.names(), ["1"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_deleteAlreadyDeletedItem_throwsError() {
        createTestItems(count: 2)
        let fetched = arrayController.fetch()
        let item = fetched[0]
        try! arrayController.delete(item)
        XCTAssertThrowsError(try arrayController.delete(item)) { error in
            XCTAssertTrue((error as? MKOrderedManagedObjectError) == .itemMissing)
        }
    }
    
    func test_deleteThenAppend_indicesAreReincremented() {
        createTestItems(count: 3)
        do {
            try arrayController.delete(at: 0)
            var fetched = arrayController.fetch()
            arrayController.append { context, index in
                let item = TestItem(context: context)
                item.name = "Hello"
                item.arrayIndex = index
                return item
            }
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2])
            XCTAssertEqual(fetched.names(), ["1", "2", "Hello"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
   
    func test_moveItemsByIndex_indicesAreAdjusted() {
        createTestItems(count: 4)
        do {
            try arrayController.move(itemAt: 0, to: 1)
            var fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2, 3])
            XCTAssertEqual(fetched.names(), ["1", "0", "2", "3"])
            try arrayController.move(itemAt: 3, to: 2)
            fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2, 3])
            XCTAssertEqual(fetched.names(), ["1", "0", "3", "2"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_swapItems_indicesAreSwapped() {
        createTestItems(count: 3)
        do {
            try arrayController.swap(0, 2)
            let fetched = arrayController.fetch()
            XCTAssertEqual(fetched.arrayIndices(), [0, 1, 2])
            XCTAssertEqual(fetched.names(), ["2", "1", "0"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    var isPerformanceTestsEnabled = false
    
    func test_performance_creatingAndDeleting1000Items() throws {
        guard isPerformanceTestsEnabled else { throw XCTSkip() }
        let testSize = 1000
        self.measure {
            createTestItems(count: testSize)
            print(arrayController.fetch().count)
            for i in 0..<testSize {
                do {
                    try arrayController.delete(at: testSize - i - 1)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        XCTAssertEqual(arrayController.fetch().count, 0)
    }
    
}


fileprivate extension MKOrderedManagedObjectArrayControllerTests {
    
    @discardableResult
    private func createTestItems(count: Int) -> [TestItem] {
        var created = [TestItem]()
        for i in 0..<count {
            arrayController.append { context, index in
                let item = TestItem(context: context)
                item.name = "\(i)"
                item.arrayIndex = index
                created.append(item)
                return item
            }
        }
        return created
    }
    
}


fileprivate extension Array where Element == TestItem {
    
    func arrayIndices() -> [Int64] {
        return self.map { $0.arrayIndex }
    }
    
    func names() -> [String] {
        return self.map { $0.name! }
    }
}
