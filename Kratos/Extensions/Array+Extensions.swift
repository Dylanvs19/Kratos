//
//  Array+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/7/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension Array {
    func groupedBySection<T: Hashable> (groupBy: (Element) -> (T)) -> [Int: [Element]] {
        
        var mappedItems = [Int: [Element]]()
        var index = -1
        var mapped = [T: Int]()
        
        for item in self {
            let groupingValue = groupBy(item)
            
            if let i = mapped[groupingValue] {
                var cpy = mappedItems[i]
                cpy?.append(item)
                mappedItems[i] = cpy 
            } else {
                index += 1
                mappedItems[index] = [item]
                mapped[groupingValue] = index
            }
        }
        
        return mappedItems
    }
}
