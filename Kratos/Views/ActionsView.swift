//
//  ActionsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class ActionsView: UIView, Loadable, Tappable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nodeView: UIView!
    @IBOutlet weak var actionTypeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chevronView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var textViewToBottom: NSLayoutConstraint!
    @IBOutlet var stackViewTopToTextViewBottom: NSLayoutConstraint!
    @IBOutlet var stackViewTopToTop: NSLayoutConstraint!
    
    @IBOutlet weak var nodeSizeConstraint: NSLayoutConstraint!
    
    var selector: Selector = #selector(viewTapped)
    
    var shouldHideStackView = true {
        didSet {
            hideStackView(shouldHideStackView, animate: true)
        }
    }
    var layoutStackView: (() -> ())?
    var hideTopView = false
    var viewType: ViewType = .majorAndMinorActions
    var actions = [Action]()
    
    enum ViewType {
        case onlyMinorActions
        case majorAndMinorActions
        case onlyMajorAction
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func isTappable(_ tappable: Bool) {
        if tappable {
            addTap()
        }
    }
    
    func configure(with actionArray: [Action], first: Bool, last: Bool, viewType: ViewType, layoutStackView: (() -> ())?) {
        
        var cpyArray = actionArray
        
        topView.isHidden = first
        bottomView.isHidden = last
        if viewType == .onlyMinorActions {
            bottomView.isHidden = true
        }
        
        func popFirst() -> Action? {
            var action: Action? = nil
            if let firstAction = actionArray.first {
                action = firstAction
                cpyArray.remove(at: 0)
            }
            return action
        }
        
        if let first = popFirst() {
            actionTypeLabel.text = first.presentableType()
            statusLabel.text = first.presentableStatus()
            textView.text = first.text
            if let date = first.date {
                dateLabel.text = DateFormatter.shortPresentationDateFormatter.string(from: date)
            }
        }
        
        for (idx, action) in cpyArray.enumerated() {
            let actionView = MinorActionView()
            let first = idx == 0
            let last = (cpyArray.count - 1) == idx
            actionView.configure(with: action, first: first, last: last)
            stackView.addArrangedSubview(actionView)
        }
        configureView(for: viewType)
        self.layoutStackView = layoutStackView
        
        setupNodeView()
    }
    
    func configureView(for viewType: ViewType) {
        switch viewType {
        case .onlyMajorAction:
            stackViewTopToTextViewBottom.isActive = true
            textViewToBottom.isActive = true
            stackViewTopToTop.isActive = false
            actionTypeLabel.isHidden = false
            statusLabel.isHidden = false
            dateLabel.isHidden = false
            chevronView.isHidden = true
            hideStackView(true, animate: false)
            isTappable(false)
        case .onlyMinorActions:
            textViewToBottom.isActive = false
            stackViewTopToTextViewBottom.isActive = true
            stackViewTopToTop.isActive = false
            actionTypeLabel.isHidden = false
            statusLabel.isHidden = false
            dateLabel.isHidden = false
            hideStackView(true, animate: false)
            isTappable(true)
        case .majorAndMinorActions:
            textViewToBottom.isActive = false
            stackViewTopToTextViewBottom.isActive = true
            stackViewTopToTop.isActive = false
            actionTypeLabel.isHidden = false
            statusLabel.isHidden = false
            dateLabel.isHidden = false
            hideStackView(true, animate: false)
            isTappable(true)
        }
    }
    
    func hideStackView(_ shouldHide: Bool, animate: Bool) {
        if animate {
            UIView.animate(withDuration: 0.2, animations: { 
                self.stackView.isHidden = shouldHide
                self.textViewToBottom.isActive = shouldHide
                self.stackViewTopToTextViewBottom.isActive = !shouldHide
                self.rotateChevronView(closed: shouldHide)
                self.layoutStackView?()
            }, completion: { (success) in
                UIView.animate(withDuration: 0.2) {
                    self.stackView.alpha = shouldHide ? 0 : 1
                    self.layoutStackView?()
                }
            })
        } else {
            self.stackView.alpha = shouldHide ? 0 : 1
            self.stackView.isHidden = shouldHide
            self.textViewToBottom.isActive = shouldHide
            self.stackViewTopToTextViewBottom.isActive = !shouldHide
            self.rotateChevronView(closed: shouldHide)
            self.layoutStackView?()
        }
    }
    
    func rotateChevronView(closed: Bool) {
        if closed {
            self.chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        } else {
            self.chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / Double(2)))
        }
    }
    
    func setupNodeView() {
        switch viewType {
        case .majorAndMinorActions, .onlyMajorAction:
            self.nodeView.layer.borderColor = UIColor.kratosRed.cgColor
        case .onlyMinorActions:
            self.nodeView.layer.borderColor = UIColor.kratosBlue.cgColor
        }
        self.nodeView.layer.borderWidth = 3.0
        self.nodeView.backgroundColor = UIColor.white
        self.nodeView.layer.cornerRadius = nodeView.frame.size.width/2
    }
    
    func viewTapped() {
        if shouldHideStackView {
            
        }
        shouldHideStackView = !shouldHideStackView
    }
}
