//
//  YourVotesViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/8/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class YourVotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let interactor = Interactor()

    
    var userVotes: [LightTally]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        loadData()
        setupTableView()
        configureGestureRecognizer()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: String(describing: YourVoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: YourVoteTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadData() {
//        APIManager.getUserVotingRecord(success: { (tallies) in
//            self.userVotes = tallies
//        }) { (error) in
//            self.showError(error: error)
//        }
    }
    
    
    func configureGestureRecognizer() {
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePan(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func presentMenuVC() {
        let vc: MenuViewController = MenuViewController.instantiate()
        vc.transitioningDelegate = self
        vc.interactor = interactor
        self.present(vc, animated: true, completion: nil)
    }
    
    func handleScreenEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor) {
                self.presentMenuVC()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userVotes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vote = userVotes?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: YourVoteTableViewCell.self), for: indexPath) as? YourVoteTableViewCell else { return UITableViewCell() }
        cell.configure(with: vote)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        presentMenuVC()
    }
}

extension YourVotesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
           return DismissMenuAnimator()

    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
