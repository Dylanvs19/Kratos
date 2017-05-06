//
//  BillSummaryView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol BillInfoViewDelegate: class {
    func scrollViewDid(translate translation: CGFloat, contentOffsetY: CGFloat)
}

class BillSummaryView: UIView, UIScrollViewDelegate {
    
    public var scrollView: UIScrollView = UIScrollView()
    fileprivate var stackView: UIStackView = UIStackView()
    fileprivate var urlPressed: ((String) -> Void)?
    fileprivate var bill: Bill?
    fileprivate var lastContentOffset: CGFloat = 0
    
    weak var billInfoViewDelegate: BillInfoViewDelegate?
    
    public func configure(with bill: Bill, width: CGFloat, urlPressed:@escaping (String) -> Void) {
        self.urlPressed = urlPressed
        
        scrollView.pin(to: self)
        scrollView.alwaysBounceHorizontal = false
        
        stackView.pin(to: scrollView)
        stackView.widthAnchor.constraint(equalToConstant: width)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        scrollView.alwaysBounceHorizontal = false
        stackView.spacing = 2

        
        if let summary = bill.summary {
            let summaryView = SummaryView()
            summaryView.translatesAutoresizingMaskIntoConstraints = false
            summaryView.widthAnchor.constraint(equalToConstant: width).isActive = true
            summaryView.configure(with: summary, title: "Bill Summary", showMorePresentable: true, layoutView: layoutStackViewWithAnimation)
            summaryView.layoutSubviews()
            stackView.addArrangedSubview(summaryView)
            
        }
        
        // add CommitteesView to stackView
        if let committees =  bill.committees {
            let committeesView = BillCommitteesView()
            committeesView.translatesAutoresizingMaskIntoConstraints = false
            committeesView.widthAnchor.constraint(equalToConstant: width).isActive = true
            committeesView.configure(with: committees, layoutStackView: layoutStackView, websiteButtonPressed: urlPressed)
            stackView.addArrangedSubview(committeesView)
        }
        
        if bill.billTextURL != nil {
            let relatedBillView = ButtonView()
            relatedBillView.translatesAutoresizingMaskIntoConstraints = false
            relatedBillView.widthAnchor.constraint(equalToConstant: width).isActive = true 
            relatedBillView.configure(with: "Bill Text", font: Font.title, actionBlock: billTextPressed)
            stackView.addArrangedSubview(relatedBillView)
        }
        
        stackView.layoutSubviews()
        stackView.layoutIfNeeded()
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
        billInfoViewDelegate?.scrollViewDid(translate: translation, contentOffsetY: offsetY)
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
