//
//  RepInfoManagerBarView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepInfoManagerBarViewDelegate: class {
    func buttonPressed(for viewType: RepInfoManagerView.ViewType)
}

class RepInfoManagerBarView: UIView, Loadable {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var indicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorViewLeadingConstraint: NSLayoutConstraint!
    
    weak var delegate: RepInfoManagerBarViewDelegate?
    
    var viewMap:[RepInfoManagerView.ViewType: Int] = [:]
    var subViewWidth: CGFloat = 367
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with viewTypes: [RepInfoManagerView.ViewType], selectedViewType: RepInfoManagerView.ViewType) {
        for (i, viewType) in viewTypes.enumerated() {
            let view = RepInfoButtonView()
            view.setButton(with: viewType, buttonPress: buttonSelected)
            stackView.addArrangedSubview(view)
            viewMap[viewType] = i
        }
        self.layoutIfNeeded()

        guard let firstView = stackView.arrangedSubviews.first,
              let selectedViewIndex = viewMap[selectedViewType] else {
            indicatorView.isHidden = true
            return
        }
        
        subViewWidth = firstView.frame.size.width + 10
        indicatorViewWidthConstraint.constant = subViewWidth
        indicatorViewLeadingConstraint.constant = CGFloat(selectedViewIndex) * subViewWidth	
        self.layoutIfNeeded()
    }
    
    func buttonSelected(for viewType: RepInfoManagerView.ViewType) {
        delegate?.buttonPressed(for: viewType)
        guard let selectedViewIndex = viewMap[viewType] else {
            indicatorView.isHidden = true
            return
        }
        UIView.animate(withDuration: 0.2) { 
            self.indicatorViewLeadingConstraint.constant = CGFloat(selectedViewIndex) * self.subViewWidth
            self.layoutIfNeeded()
        }
    }
}
