//
//  MKOrderedManagedObject.swift
//  
//
//  Created by MOH on 2022-07-16.
//

import CoreData

public protocol MKOrderedManagedObject: NSManagedObject {
    var arrayIndex: Int64 { get set }
}


