//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RepViewDelegate {
    
    @IBOutlet var repViewOne: RepresentativeView!
    @IBOutlet var repViewTwo: RepresentativeView!
    @IBOutlet var repViewThree: RepresentativeView!
    
    @IBOutlet var repOneSelectedHeight: NSLayoutConstraint!
    @IBOutlet var repTwoSelectedHeight: NSLayoutConstraint!
    @IBOutlet var repThreeSelectedHeight: NSLayoutConstraint!
    
    @IBOutlet var repOneSelectedYPosition: NSLayoutConstraint!
    @IBOutlet var repTwoSelectedYPosition: NSLayoutConstraint!
    @IBOutlet var repThreeSelectedYPosition: NSLayoutConstraint!
    
    @IBOutlet var repOneWidth: NSLayoutConstraint!
    @IBOutlet var repTwoWidth: NSLayoutConstraint!
    @IBOutlet var repThreeWidth: NSLayoutConstraint!
    
    @IBOutlet var tableViewTopToRepContactView: NSLayoutConstraint!
    @IBOutlet var tableViewBottomToBottom: NSLayoutConstraint!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var repOneToTopContracted: NSLayoutConstraint!
    @IBOutlet var repTwoToRepOneBottomContracted: NSLayoutConstraint!
    @IBOutlet var repThreeToRepTwoBottomContracted: NSLayoutConstraint!
    @IBOutlet var repThreeToBottomContracted: NSLayoutConstraint!
    
    @IBOutlet var repContactView: RepContactView!
    @IBOutlet var tableView: UITableView!
    
    var representatives: [DetailedRepresentative] = []
    var selectedRepresentative: DetailedRepresentative? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "VoteTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER)
        loadData()
        enableSwipeBack()
    }
    
    func loadData() {
        if Datastore.sharedDatastore.representatives != nil {
            Datastore.sharedDatastore.getVotesForRepresentatives({ (success) in
                if success {
                    self.representatives = Datastore.sharedDatastore.representatives!
                    self.configureRepViews()
                    
                }
            })
        }
    }
    
    func configureRepViews() {
        if representatives.count == 0 {
            // Show Error Message
        } else if representatives.count == 1 {
            let rep = representatives[0]
            repViewOne.configure(with: rep)
            repViewTapped(is: true, at: 0)
            repViewOne.isUserInteractionEnabled = false
        } else if representatives.count == 3 {
            let views = [repViewOne, repViewTwo, repViewThree]
            var count = 0
            views.forEach { (repView) in
                let rep = representatives[count]
                repView?.viewPosition = count
                repView?.configure(with: rep)
                count += 1
            }
        }
        repViewOne.repViewDelegate = self
        repViewTwo.repViewDelegate = self
        repViewTwo.layoutIfNeeded()
        repViewThree.repViewDelegate = self
        repViewThree.layoutIfNeeded()
        
        repViewDeselected()
    }
    
    override func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
        //Notification Center to pop in Account View From left.
    }
    
    //MARK: RepViewDelegate Method
    func repViewTapped(is selected: Bool, at position: Int) {
        if selected && position < representatives.count {
            selectedRepresentative = representatives[position]
            switch position {
            case 0:
                self.contractedRepConstraints(active: false)

                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.repViewTwo.alpha = 0
                    self.repViewTwo.isHidden = true
                    
                    self.repViewThree.alpha = 0
                    self.repViewThree.isHidden = true
                    self.repViewOne.reloadInputViews()
                    
                    self.repOneSelectedYPosition.isActive = true
                    self.repOneSelectedHeight.isActive = true
                    self.repOneWidth.constant = 0
                    
                    self.view.layoutIfNeeded()
                })
                
                
                UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
                    self.tableViewTopToRepContactView.constant = 10
                    self.view.layoutIfNeeded()

                }, completion: nil)
                self.repViewOne.layoutSubviews()

                repContactView.animateIn()
                
            case 1:
                UIView.animate(withDuration: 0.25, animations: {
                    self.contractedRepConstraints(active: false)
                    
                    self.repViewOne.alpha = 0
                    self.repViewOne.isHidden = true
                    self.repViewThree.alpha = 0
                    self.repViewThree.isHidden = true
                    
                    self.repTwoSelectedHeight.isActive = true
                    self.repTwoWidth.constant = 0
                    self.repTwoSelectedYPosition.isActive = true
                    self.view.layoutIfNeeded()
                })
                
                UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
                    self.tableViewTopToRepContactView.constant = 10
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                repContactView.animateIn()
                
            case 2:
                UIView.animate(withDuration: 0.25, animations: {
                    self.contractedRepConstraints(active: false)
                    
                    self.repViewOne.alpha = 0
                    self.repViewTwo.isHidden = true
                    
                    self.repViewTwo.alpha = 0
                    self.repViewTwo.isHidden = true
                    
                    self.repThreeSelectedYPosition.isActive = true
                    self.repThreeSelectedHeight.isActive = true
                    self.repThreeWidth.constant = 0
                    
                    self.view.layoutIfNeeded()
                    
                })
                
                UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
                    
                    self.tableViewTopToRepContactView.constant = 10
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                repContactView.animateIn()
                
            default:
                break
            }
        } else {
            repViewDeselected()
            selectedRepresentative = nil
        }
        repViewOne.layoutIfNeeded()
        repViewTwo.layoutIfNeeded()
        repViewThree.layoutIfNeeded()
    }
    
    func repViewDeselected() {
        let views = [repViewOne, repViewTwo, repViewThree]
        
        repContactView.animateOut()
        
        UIView.animate(withDuration: 0.25, animations: {
            views.forEach { (repView) in
                repView?.isHidden = false
                repView?.alpha = 1
            }
            self.repOneSelectedYPosition.isActive = false
            self.repTwoSelectedYPosition.isActive = false
            self.repThreeSelectedYPosition.isActive = false
            
            self.repOneSelectedHeight.isActive = false
            self.repTwoSelectedHeight.isActive = false
            self.repThreeSelectedHeight.isActive = false
            
            self.tableViewBottomToBottom.isActive = false
            self.tableViewHeightConstraint.isActive = true
            self.tableViewTopToRepContactView.constant = 500
            
            self.repOneWidth.constant = -20
            self.repTwoWidth.constant = -20
            self.repThreeWidth.constant = -20
            
            self.view.layoutIfNeeded()
        })
        
        contractedRepConstraints(active: true)
    }
    
    func contractedRepConstraints(active: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.repOneToTopContracted.isActive = active
            self.repTwoToRepOneBottomContracted.isActive = active
            self.repThreeToRepTwoBottomContracted.isActive = active
            self.repThreeToBottomContracted.isActive = active
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: TableViewDelegate & Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRepresentative?.votes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER, for: indexPath) as? VoteTableViewCell else { return UITableViewCell() }
        guard let votesArray = selectedRepresentative?.votes else { return UITableViewCell()}
        let vote = votesArray[(indexPath as IndexPath).row]
        cell.vote = vote
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let votesArray = selectedRepresentative?.votes,
              let rep = selectedRepresentative else { return }
        let vote = votesArray[(indexPath as IndexPath).row]
        let vc: VoteViewController = VoteViewController.instantiate()
        vc.vote = vote
        vc.representative = rep.toLightRepresentative()
        navigationController?.pushViewController(vc, animated: true)
    }
}

