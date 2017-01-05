//
//  NSDate+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/23/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var longDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }
    
    static var presentationDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }
    
    static var billDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }
}
