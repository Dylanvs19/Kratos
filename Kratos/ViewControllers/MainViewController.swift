//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var representatives: [Representative] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentOpenRow = 0 {
        didSet {
            if currentOpenRow != 0 {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.26 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tableView.scrollToNearestSelectedRowAtScrollPosition(.Top, animated: true)
                    self.tableView.scrollEnabled = false
                }
            } else {
                tableView.scrollEnabled = true
            }
        }
    }
    var currentSectionShouldClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        tableView.registerNib(UINib(nibName: "RepresentativeTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.REPRESENATIVE_TABLEVIEWCELL_IDENTIFIER)
        loadData()
    }
    
    func loadData() {
        if Datastore.sharedDatastore.representatives != nil {
            Datastore.sharedDatastore.getVotesForRepresentatives({ (success) in
                if success {
                    self.representatives = Datastore.sharedDatastore.representatives!
                }
            })
        }
    }
    
    // MARK: RepViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representatives.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(Constants.REPRESENATIVE_TABLEVIEWCELL_IDENTIFIER, forIndexPath: indexPath) as? RepresentativeTableViewCell else { return UITableViewCell() }
        
        let rep = representatives[indexPath.row]
        cell.configure(with: rep)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row + 1 == currentOpenRow {
            currentSectionShouldClose = !currentSectionShouldClose
        } else {
            currentOpenRow = indexPath.row + 1
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row + 1 == currentOpenRow {
            if currentSectionShouldClose {
                currentOpenRow = 0
                currentSectionShouldClose = false
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return self.view.frame.size.height/3.1
            }
            return self.view.frame.size.height
        } else {
            return self.view.frame.size.height/3.1
        }
    }
}

