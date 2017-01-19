//
//  BillComitteesView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillCommitteesView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var committeeIdSet = Set<Int>()
    var committeeArray: [Committee]?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit() 
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with committeeArray: [Committee], layoutStackView: (() -> ())?, websiteButtonPressed: ((String) -> ())?) {
        self.committeeArray = committeeArray
        title.text =  committeeArray.count == 1 ? "Committee" : "Committees"
        committeeArray.forEach { (committee) in
            if let id = committee.id, !committeeIdSet.contains(id) {
                let committeeView = CommitteeView()
                committeeView.configure(with: committee, layoutStackView: layoutStackView, buttonViewPressedWithString: websiteButtonPressed)
                stackView.addArrangedSubview(committeeView)
                committeeIdSet.insert(id)
            }
        }
    }
    
    func configure(with actionsArray: [Action], layoutStackView: (() -> ())?) {
        title.text =  actionsArray.count == 1 ? "Action" : "Actions"
        var actionsMap = [[Action]]()
        var holdArray = [Action]()
        for (idx, action) in actionsArray.enumerated() {
            if action.status != nil && !holdArray.isEmpty {
                actionsMap.append(holdArray)
                holdArray = []
            }
            holdArray.append(action)
            if idx == (actionsArray.count - 1) {
                actionsMap.append(holdArray)
            }
        }
        for (idx, value) in actionsMap.enumerated() {
            let first = idx == 0
            let last = (actionsMap.count - 1) == idx
            let actionView = ActionsView()
            actionView.configure(with: value, first: first, last: last, layoutStackView: layoutStackView)
            stackView.addArrangedSubview(actionView)
        }
    }
}
