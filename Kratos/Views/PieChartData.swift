//
//  PieChartData.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

struct PieChartData {
    var type: VoteType
    var value: CGFloat
    
    init(with value: Int, and type: VoteType) {
        self.type = type
        self.value = CGFloat(value)
    }
    
}
