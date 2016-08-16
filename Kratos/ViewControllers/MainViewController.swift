//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RepViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var representatives: [Representative] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }
    
    func loadData() {
        if let reps = Datastore.sharedDatastore.representatives {
            representatives = reps
        }
    }
    
    // MARK: RepViewDelegate Methods
    func shouldExpand(shouldExpand: Bool, for position: RepresentativeView.Position) {
            switch position {
            case .top:
                break
            case .middle:
                break
            case .bottom:
                break
            }
    }
    
    func panGestureYPosition(float: CGFloat, for position: RepresentativeView.Position) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representatives.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

