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
    var representatives: [Representative] = []
    let representativeCellIdentifier = "representativeCellIdentifier"
    var currentOpenRow = 0
    var currentSectionShouldClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        tableView.registerNib(UINib(nibName: "RepresentativeTableViewCell", bundle: nil), forCellReuseIdentifier: representativeCellIdentifier)
        loadData()
        
    }
    
    func loadData() {
        if let reps = Datastore.sharedDatastore.representatives {
            representatives = reps
        }
    }
    
    // MARK: RepViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representatives.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(representativeCellIdentifier, forIndexPath: indexPath) as? RepresentativeTableViewCell else { return UITableViewCell() }
        
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
            return self.view.frame.size.height * 0.95
        } else {
            return self.view.frame.size.height/3.1
            
        }
    }
}

