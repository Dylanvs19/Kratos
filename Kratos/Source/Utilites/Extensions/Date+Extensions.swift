//
//  Date+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/9/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

extension Date {
    
    var dayValue: Int {
        let calendar = NSCalendar.current
        let day = calendar.component(.day, from: self)
        return day
    }
    var monthValue: Int {
        let calendar = NSCalendar.current
        let month = calendar.component(.month, from: self)
        return month
    }
    var yearValue: Int {
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: self)
        return year
    }
    
    var computedDayFromDate: Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.day = self.dayValue
        components.month = self.monthValue
        components.year = self.yearValue
        if let date = calendar.date(from: components) {
            return date
        } else {
            return self
        }
    }
}
