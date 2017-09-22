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
    func grouped<T: Hashable> (groupBy: ((Element) -> T),
                                      sortGroupsBy groupSort: ((Element, Element) -> Bool)? = nil,
                                      sortElementsBy elementsSort: ((Element, Element) -> Bool)? = nil) -> [[Element]] {
        
        var mappedItems = [Int: [Element]]()
        var index = -1
        var mapped = [T: Int]()
        
        var elements = self
        if let groupSort = groupSort {
            elements = sorted(by: groupSort)
        }
        for element in elements {
            let groupingValue = groupBy(element)
            
            if let i = mapped[groupingValue] {
                var cpy = mappedItems[i]
                cpy?.append(element)
                mappedItems[i] = cpy
            } else {
                index += 1
                mappedItems[index] = [element]
                mapped[groupingValue] = index
            }
        }
        
        if let elementSort = elementsSort {
            for (key, elements) in mappedItems {
                mappedItems[key] = elements.sorted(by: elementSort)
            }
        }
    
        return mappedItems.keys.sorted().flatMap { mappedItems[$0] }
    }
}
