//
//  ViewLoader.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

protocol ViewBuilder {

    func addSubviews()
    
    func constrainViews()
    
    func styleViews()
    
}
