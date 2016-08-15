//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController, RepViewDelegate {
    
    @IBOutlet var oneRepView: RepresentativeView!
    @IBOutlet var twoRepView: RepresentativeView!
    @IBOutlet var threeRepView: RepresentativeView!
    
    @IBOutlet var oneRepViewTopPosition: NSLayoutConstraint!
    @IBOutlet var oneRepViewMiddlePosition: NSLayoutConstraint!
    @IBOutlet var oneRepViewBottomPosition: NSLayoutConstraint!
    
    @IBOutlet var oneRepViewCompact: NSLayoutConstraint!
    @IBOutlet var oneRepViewExpanded: NSLayoutConstraint!
    
    @IBOutlet var twoRepViewTopPosition: NSLayoutConstraint!
    @IBOutlet var twoRepViewMiddlePosition: NSLayoutConstraint!
    @IBOutlet var twoRepViewBottomPosition: NSLayoutConstraint!
    
    @IBOutlet var twoRepViewCompact: NSLayoutConstraint!
    @IBOutlet var twoRepViewExpanded: NSLayoutConstraint!
    
    @IBOutlet var threeRepViewTopPosition: NSLayoutConstraint!
    @IBOutlet var threeRepViewMiddlePosition: NSLayoutConstraint!
    @IBOutlet var threeRepViewBottomPosition: NSLayoutConstraint!
    
    @IBOutlet var threeRepViewCompact: NSLayoutConstraint!
    @IBOutlet var threeRepViewExpanded: NSLayoutConstraint!
    
    var representatives: [Representative] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupRepresentatives()
    }
    
    func loadData() {
        if let reps = Datastore.sharedDatastore.representatives {
            representatives = reps
        }
    }
    
    func setupRepresentatives() {
        let repViews = [(oneRepView, 0), (twoRepView, 1), (threeRepView, 2)]
        repViews.map { (repView) in
            repView.0.configure(with: representatives[repView.1])
            setupRepViews(repView.0)
            repView.0.repViewDelegate = self
            switch repView.1 {
            case 0:
                repView.0.position = .top
            case 1:
                repView.0.position = .middle
            default:
                repView.0.position = .bottom
            }
        }
    }
    
    func setupRepViews(repView: RepresentativeView) {
        repView.representativeViewContentView.layer.cornerRadius = 3.0
        repView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        repView.layer.shadowColor = UIColor.blackColor().CGColor
        repView.layer.shadowOffset = CGSize(width: 0, height: 3)
        repView.layer.shadowOpacity = 0.2
        repView.layer.shadowRadius = 3
    }
    
    func tapped(position: RepresentativeView.Position) {
        if oneRepView.position == position {
            
        }
        if twoRepView.position == position {
            
        }
        if threeRepView.position == position {
            
        }
    }
    
    func oneRepViewExpanded(bool: Bool) {
        if bool {
        UIView.animateWithDuration(1) {
            self.oneRepViewBottomPosition.active = false
            self.oneRepViewTopPosition.active = false
            self.oneRepViewMiddlePosition.active = true
            self.oneRepViewCompact.active = false
            self.oneRepViewExpanded.active = true
            self.view.layoutIfNeeded()
        }
        } else {
            UIView.animateWithDuration(1) {
                self.oneRepViewBottomPosition.active = false
                self.oneRepViewMiddlePosition.active = false
                self.oneRepViewTopPosition.active = true
                self.oneRepViewExpanded.active = false
                self.oneRepViewCompact.active = true
                self.view.layoutIfNeeded()
            }
 
        }
    }
    
//    func oneRepViewShouldExitScreen(bool: Bool, withTappedScreen position: RepresentativeView.Position) {
//        switch position {
//        case .top:
//            
//        case .middle:
//            <#code#>
//        case .bottom:
//            <#code#>
//        }
//        
//        UIView.animateWithDuration(1) {
//                self.view.layoutIfNeeded()
//        }
//    }
//    
    
    // MARK: RepViewDelegate Methods
    func shouldExpand(bool: Bool, for position: RepresentativeView.Position) {
        switch position {
        case .top:
            oneRepViewExpanded(bool)
        case .middle:
            break
        case .bottom:
            break
        }
    }
    
    func panGestureYPosition(float: CGFloat, for position: RepresentativeView.Position) {
        
    }
    
    
}

