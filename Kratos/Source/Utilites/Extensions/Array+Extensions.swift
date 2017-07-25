//
//  Array+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/7/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension Array {
    func groupBySection<T: Hashable> (groupBy: (Element) -> (T)) -> [Int: [Element]] {
        
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
    
    func group<T:Hashable>(by: (Element) -> T) -> [[Element]] {
        var mappedItems = [T: [Element]]()
        var index = -1
        var mapped = [T: Int]()
        
        for item in self {
            let groupingValue = by(item)
            
            if mapped[groupingValue] != nil {
                var cpy = mappedItems[groupingValue]
                cpy?.append(item)
                mappedItems[groupingValue] = cpy
            } else {
                index += 1
                mappedItems[groupingValue] = [item]
                mapped[groupingValue] = index
            }
        }
        
        return mappedItems.map { $0.1 }
    }
    
    func singleSection() -> [Int: [Element]] {
        return [0: self]
    }
    
    func slice(from: Int, to: Int) -> [Element]? {
        guard from < self.count,
            0 <= from,
            to < self.count,
            0 <= to,
            from <= to else { return nil }
        return Array(self[from...to])
    }
}

extension Array where Element: Hashable {
    func groupBySection<T: Hashable> (groupBy: (Element) -> (T)) -> [T: [Element]] {
        
        var mappedItems = [T: [Element]]()
        var index = -1
        var mapped = [T: Int]()
        
        for item in self {
            let groupingValue = groupBy(item)
            
            if mapped[groupingValue] != nil {
                var cpy = mappedItems[groupingValue]
                cpy?.append(item)
                mappedItems[groupingValue] = cpy
            } else {
                index += 1
                mappedItems[groupingValue] = [item]
                mapped[groupingValue] = index
            }
        }
        
        return mappedItems
    }
    
    func uniqueGroupBySection<T: Hashable> (groupBy: (Element) -> (T)) -> [Int: Set<Element>] {
        
        var mappedItems = [Int: Set<Element>]()
        var index = -1
        var mapped = [T: Int]()
        
        for item in self {
            let groupingValue = groupBy(item)
            
            if let i = mapped[groupingValue] {
                var cpy = mappedItems[i]
                cpy?.insert(item)
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
