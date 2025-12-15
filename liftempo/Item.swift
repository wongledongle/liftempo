//
//  Item.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
