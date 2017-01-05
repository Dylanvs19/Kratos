//
//  CommitteeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/2/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class CommitteeView: UIView, Loadable, Tappable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var committeeNameLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet var committeeNameLabelToBottom: NSLayoutConstraint!
    
    var selector: Selector = #selector(viewTapped)
    
    var shouldHideStackView = true {
        didSet {
            hideStackView(shouldHideStackView)
        }
    }
    var layoutStackView: (() -> ())?
    var buttonViewPressedWithString: ((String) -> ())?
    var url: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        configureView()
    }
    
    func configureView() {
        addTap()
    }
    
    func configure(with committee: Committee, layoutStackView: (() -> ())?, buttonViewPressedWithString:((String) -> ())?) {
        let sanitizedCommitteeName = committee.name?.replacingOccurrences(of: "House Committee on ", with: "").replacingOccurrences(of: "Senate Committee on ", with: "").replacingOccurrences(of: " the ", with: "")
        chamberLabel.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        sideView.layer.cornerRadius = 2.0
        committeeNameLabel.text = sanitizedCommitteeName
        if committee.commmitteeType == .senate {
            chamberLabel.text = "Sen"
        } else if committee.commmitteeType == .house {
            chamberLabel.text = "HR"
        }
        
        if let activity = committee.activity {
            var presentationString  = ""
            for (idx, action) in activity.enumerated() {
                if idx == activity.count - 1 {
                    presentationString += action
                } else {
                    presentationString += "\(action), "
                }
            }
        } else {
        }
        
        if let summary = committee.jusrisdiction {
            let summaryView = SummaryView()
            summaryView.configure(with: summary, title: "Jurisdiction")
            stackView.addArrangedSubview(summaryView)
        }
        
        if let url = committee.url {
            self.url = url 
            let buttonView = ButtonView()
            buttonView.configure(with: "Website", actionBlock: buttonViewPressed)
            stackView.addArrangedSubview(buttonView)
        }
        
        self.buttonViewPressedWithString = buttonViewPressedWithString
        self.layoutStackView = layoutStackView
        hideStackView(true)
    }
    
    func hideStackView(_ shouldHide: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.stackView.isHidden = shouldHide
            self.committeeNameLabelToBottom.isActive = shouldHide
            self.layoutStackViews()
        }
    }
    
    func viewTapped() {
        shouldHideStackView = !shouldHideStackView
    }
    
    func buttonViewPressed() {
        if let url = url {
            buttonViewPressedWithString?(url)
        }
    }
    
    func layoutStackViews() {
        //stackView.reloadInputViews()
        //stackView.layoutIfNeeded()
        layoutStackView?()
    }
}
