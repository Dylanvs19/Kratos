//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RepresentativeTableViewCellDelegate {
    
    @IBOutlet var tableView: UITableView!
    var representatives: [Representative] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentOpenRow = 0 {
        didSet {
            if currentOpenRow != 0 {
                let delayTime = DispatchTime.now() + Double(Int64(0.26 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.tableView.scrollToNearestSelectedRow(at: .top, animated: true)
                    self.tableView.isScrollEnabled = false
                }
            } else {
                tableView.isScrollEnabled = true
            }
        }
    }
    var currentSectionShouldClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true 
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RepresentativeTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.REPRESENATIVE_TABLEVIEWCELL_IDENTIFIER)
        loadData()
        enableSwipeBack()
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
    
    override func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
            //Notification Center to pop in Account View From left.
    }
    
    // MARK: RepViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representatives.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.REPRESENATIVE_TABLEVIEWCELL_IDENTIFIER, for: indexPath) as? RepresentativeTableViewCell else { return UITableViewCell() }
        
        let rep = representatives[(indexPath as NSIndexPath).row]
        cell.delegate = self
        cell.configure(with: rep)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row + 1 == currentOpenRow {
            currentSectionShouldClose = !currentSectionShouldClose
        } else {
            currentOpenRow = (indexPath as NSIndexPath).row + 1
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row + 1 == currentOpenRow {
            if currentSectionShouldClose {
                currentOpenRow = 0
                currentSectionShouldClose = false
                tableView.deselectRow(at: indexPath, animated: true)
                return self.view.frame.size.height/3.1
            }
            return self.view.frame.size.height
        } else {
            return self.view.frame.size.height/3.1
        }
    }
    
    // MARK: Representative TableView Cell Delegate
    
    func didSelectVote(_ vote: Vote) {
        let vc: VoteViewController = VoteViewController.instantiate()
        vc.vote = vote
        vc.representative = representatives[currentOpenRow - 1].toLightRepresentative()
        vc.loadViewIfNeeded()
        navigationController?.pushViewController(vc, animated: true)
    }
}

