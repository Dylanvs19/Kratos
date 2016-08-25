//
//  NSDate+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/23/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    static var longDateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }
    
    static var presentationDateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }
}