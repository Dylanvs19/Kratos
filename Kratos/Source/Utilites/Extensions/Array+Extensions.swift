//
//  Array+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/7/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension Array {

    
    /// Groups an array into dictionary
    ///
    /// - Parameters:
    ///   - groupBy: Returns element to group by. Elements with equivalent elements are grouped.
    ///   - elementsSort: Compares elements within one group, returns true if first element should preceed.
    ///   - groupSort: Compares elements within two groups, return true if first element should preceeed.
    /// - Returns: Returns dictionary where key is the element that was grouped by, and the value an array whose the elements have an equivalent groupBy value.
    func groupBySection<T: Hashable> (groupBy: ((Element) -> T),
                                      sortGroupsBy groupSort: ((T, T) -> Bool)? = nil,
                                      sortElementsBy elementsSort: ((Element, Element) -> Bool)? = nil) -> [[Element]] {
        
        var mappedItems = [T: [Element]]()
        var index = -1
        var mapped = [T: Int]()
        
        let elements = self
        for element in elements {
            let groupingValue = groupBy(element)
            
            if mapped[groupingValue] != nil {
                var cpy = mappedItems[groupingValue]
                cpy?.append(element)
                mappedItems[groupingValue] = cpy
            } else {
                index += 1
                mappedItems[groupingValue] = [element]
                mapped[groupingValue] = index
            }
        }
        
        if let elementsSort = elementsSort {
            for (key, elements) in mappedItems {
                mappedItems[key] = elements.sorted(by: elementsSort)
            }
        }
        
        if let sort = groupSort {
            return mappedItems.keys.sorted(by: sort).flatMap { mappedItems[$0] }
        }
    
        return mappedItems.keys.flatMap { mappedItems[$0] }
    }
}
