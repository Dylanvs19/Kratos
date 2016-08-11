//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController {
    
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
        let views = [
            oneRepView,
            twoRepView,
            threeRepView
        ]
        
        if representatives.count == 3 {
            let array = zip(views, representatives)
            for repTuple in array {
                repTuple.0.configure(with: repTuple.1)
            }
            
        }
    }
    
}

