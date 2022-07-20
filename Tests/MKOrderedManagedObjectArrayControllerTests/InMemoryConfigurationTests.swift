//
//  InMemoryConfigurationTests.swift
//  
//
//  Created by MOH on 2022-07-16.
//

import XCTest
import CoreData
@testable import MKOrderedManagedObjectArrayController

class InMemoryStoreTests: XCTestCase {

    var store: InMemoryStore!
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        configureStore()
    }
    
    func configureStore() {
        self.store = InMemoryStore()
        store.context.undoManager = .init()
        store.context.undoManager?.groupsByEvent = false
        store.context.retainsRegisteredObjects = true
        XCTAssertTrue(store.url ==  URL(fileURLWithPath: "/dev/null"))
        XCTAssertNotNil(store.context.undoManager)
        XCTAssertFalse(store.context.undoManager!.groupsByEvent)
        XCTAssertTrue(store.context.retainsRegisteredObjects)
    }
 
    
    func test_createOneItem_fetchCountEqualsOne() {
        let _ = TestItem(context: store.context)
        let request = TestItem.fetchRequest()
        do {
            let fetched = try store.context.fetch(request)
            XCTAssertEqual(fetched.count, 1)
        } catch {
            XCTFail()
        }
    }

}
