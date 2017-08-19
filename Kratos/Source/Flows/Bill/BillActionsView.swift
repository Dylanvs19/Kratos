//
//  BillActionsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class BillActionsView: UIView {
    
    
    func configure(with bill: Bill) {
        if let actions = bill.actions {
            let actionsView = BillCommitteesView()
            let sortedActions = actions.sorted { $0.date ?? Date() > $1.date ?? Date() }
            //actionsView.configure(with: sortedActions, layoutStackView: layoutStackView)
            //stackView.addArrangedSubview(actionsView)
        }
    }
}
