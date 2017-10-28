//
//  UITableView+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/29/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Provides basic default configuration for a tableView
    /// - verticalScrollIndicator = false
    /// - sets tableFooterView to empty UIView()
    /// - sets layout Margins to .zero
    /// - sets seperator Insets to .zero
    func basicSetup() {
        showsVerticalScrollIndicator = false
        tableFooterView = UIView()
        layoutMargins = .zero
        separatorInset = .zero
    }
    
}
