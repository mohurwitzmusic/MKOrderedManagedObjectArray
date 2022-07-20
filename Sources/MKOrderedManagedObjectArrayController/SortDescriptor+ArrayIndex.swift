//
//  File.swift
//  
//
//  Created by MOH on 2022-07-20.
//

import Foundation
import CoreData

public extension NSSortDescriptor {
    
    static func byArrayIndex() -> NSSortDescriptor {
        .init(key: "arrayIndex", ascending: true)
    }
}
