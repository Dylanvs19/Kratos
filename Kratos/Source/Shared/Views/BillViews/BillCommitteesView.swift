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
    
    func configure(with committeeArray: [Committee], layoutStackView: (() -> ())?, websiteButtonPressed: ((String) -> Void)?) {
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
    
    func configure(with actionsArray: [BillAction], layoutStackView: (() -> Void)?) {
        title.text =  actionsArray.count == 1 ? "Action" : "Actions"
        var actionsMap = [[BillAction]]()
        var holdArray = [BillAction]()
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
        var previosViewType: ActionsView.ViewType = .majorAndMinorActions
        for (idx, value) in actionsMap.enumerated() {
            
            let actionView = ActionsView()
            var viewType: ActionsView.ViewType = .majorAndMinorActions
            if value.count == 1 {
                if value.first?.status != nil {
                    viewType = .onlyMajorAction
                } else {
                    viewType = .onlyMinorActions
                }
            } else {
                if value.first?.status == nil {
                    viewType = .onlyMinorActions
                }
            }
            var first = idx == 0
            if previosViewType == .onlyMinorActions && idx == 1 {
                first = true
            }
            let last = (actionsMap.count - 1) == idx
            actionView.configure(with: value, first: first, last: last, viewType: viewType, layoutStackView: layoutStackView)
            stackView.addArrangedSubview(actionView)
            previosViewType = viewType
        }
    }
    
    func configure(with termsArray: [Term]) {
        title.text =  termsArray.count == 1 ? "Term" : "Terms"
//        termsArray.forEach { (term) in
//            let view = TermView()
//            view.configure(with: term)
//            stackView.addArrangedSubview(view)
//        }
    }
}
