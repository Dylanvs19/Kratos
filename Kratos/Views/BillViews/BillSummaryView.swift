//
//  BillSummaryView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol BillInfoViewDelegate: class {
    func scrollViewDid(translate translation: CGFloat)
}

class BillSummaryView: UIView, UIScrollViewDelegate {
    
    public var scrollView: UIScrollView = UIScrollView()
    fileprivate var stackView: UIStackView = UIStackView()
    fileprivate var urlPressed: ((String) -> Void)?
    fileprivate var bill: Bill?
    fileprivate var lastContentOffset: CGFloat = 0
    
    weak var billInfoViewDelegate:BillInfoViewDelegate?
    
    public func configure(with bill: Bill, width: CGFloat, urlPressed:@escaping (String) -> Void) {
        stackView.axis = .vertical
        scrollView.alwaysBounceHorizontal = false
        stackView.translatesAutoresizingMaskIntoConstraints = false 
        stackView.widthAnchor.constraint(equalToConstant: width).isActive = true
        stackView.spacing = 2
        
        self.urlPressed = urlPressed
        
        scrollView.pin(to: self)
        stackView.pin(to: scrollView)
        
        if let summary = bill.summary {
            let summaryView = SummaryView()
            summaryView.configure(with: summary, title: "Bill Summary", showMorePresentable: true, layoutView: layoutStackViewWithAnimation)
            stackView.addArrangedSubview(summaryView)
        }
        
        // add CommitteesView to stackView
        if let committees =  bill.committees {
            let committeesView = BillCommitteesView()
            committeesView.configure(with: committees, layoutStackView: layoutStackView, websiteButtonPressed: urlPressed)
            stackView.addArrangedSubview(committeesView)
        }
        
        if bill.billTextURL != nil {
            let relatedBillView = ButtonView()
            relatedBillView.configure(with: "Bill Text", font: Font.title, actionBlock: billTextPressed)
            stackView.addArrangedSubview(relatedBillView)
        }
    }
    
    private func billTextPressed() {
        if let billText = bill?.billTextURL {
            urlPressed?(billText)
        }
    }
    
    //MARK: ScrollViewDelegate Method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let translation =  offsetY - lastContentOffset
        lastContentOffset = offsetY
        billInfoViewDelegate?.scrollViewDid(translate: translation)
    }
    
    private func layoutStackViewWithAnimation() {
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutSubviews()
            self.layoutIfNeeded()
        })
    }
    
    private func layoutStackView() {
        layoutSubviews()
        layoutIfNeeded()
    }
}
