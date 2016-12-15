//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit

class MainViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, RepViewDelegate, PagingView, PagingDataSource, PagingTableViewDelegate {
    /// The variable that contains the data for the Datasource. `Pager` will sync this value
    /// when it receives data.
    /// - When `data` gets new Data, `cellMap` should be set via
    /// `data`'s `didSet` method using the Array's `groupedBySection` or `asSingleSection`
    /// methods.
    /// - After cellMap is set within `didSet` append(data: [Data], to oldData: [Data]) should be called to append new cells to the UICollectionView or UITableView.
    
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet var repViewOne: RepresentativeView!
    @IBOutlet var repViewTwo: RepresentativeView!
    @IBOutlet var repViewThree: RepresentativeView!
    
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var districtLabel: UILabel!
    
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
    
    @IBOutlet var menuBarContainerView: UIView!
    @IBOutlet var menuBarTrailingConstraint: NSLayoutConstraint!
    
    var menuViewController: MenuViewController?
    var disableSwipe = false
    
    var representatives: [DetailedRepresentative]? {
        get {
            return Datastore.sharedDatastore.representatives
        }
    }
    var selectedRepresentative: DetailedRepresentative? {
        didSet {
            if let selectedRepresentative = selectedRepresentative {
                repContactView.configure(with: selectedRepresentative)
            }
        }
    }
    var selectedRepIndex: Int? {
        didSet {
            if selectedRepIndex != nil {
                tableView.reloadData()
            }
        }
    }
    
    var tapView: UIView?
    
    //MARK: Pager Variables
    var repOneVotes: [Vote] = [] {
        didSet {
            format(votes: repOneVotes, with: oldValue)
        }
    }
    var repTwoVotes: [Vote] = [] {
        didSet {
            format(votes: repTwoVotes, with: oldValue)
        }
    }
    var repThreeVotes: [Vote] = [] {
        didSet {
            format(votes: repThreeVotes, with: oldValue)
        }
    }
    
    var data: [Vote] {
        get {
            guard let selectedRepIndex = selectedRepIndex else { return repOneVotes }
            switch selectedRepIndex {
            case 1:
                return repTwoVotes
            case 2:
                return repThreeVotes
            default:
                return repOneVotes
            }
        }
        set {
            guard let selectedRepIndex = selectedRepIndex else {
                repOneVotes = newValue
                return
            }
            
            switch selectedRepIndex {
            case 1:
                repTwoVotes = newValue
            case 2:
                repThreeVotes = newValue
            default:
                repOneVotes = newValue
            }
        }
    }
    var cellMap = [Int: [Vote]]()
    // Each flow of data needs its own Pager to handle it.
    var repOnePager = Pager<MainViewController, MainViewController, MainViewController>()
    var repTwoPager = Pager<MainViewController, MainViewController, MainViewController>()
    var repThreePager = Pager<MainViewController, MainViewController, MainViewController>()
    var loadMoreSpinnerView: LoadMoreSpinnerView? = LoadMoreSpinnerView()
    var scrollView: UIScrollView {
        get {
            return tableView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
       
        loadData()
        
        configureStateImage()
        
        configureGestureRecognizer()
        
        configureMenuBar()
        
        configureTableView()
        
        configurePagers()
        
        //Set the repContactView's action block to fire on this VC when certain actions (button presses) taken
        repContactView.shouldPresentTwitter = presentTwitter
    }
    
    //MARK: Configuration Methods
    func configureRepViews() {
        guard let representatives = representatives else {
            fatalError("could not load representatives from datastore")
        }
        
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
        repViewThree.repViewDelegate = self
        
        repViewDeselected()
    }
    
    func configureMenuBar() {
        menuBarContainerView.layer.shadowColor = UIColor.black.cgColor
        menuBarContainerView.layer.shadowOffset = CGSize(width: 3, height: 0)
        menuBarContainerView.layer.shadowOpacity = 0.3
        menuBarContainerView.layer.shadowRadius = 1
    }
    
    func configureTableView () {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "VoteTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER)
        tableView.register(UINib(nibName: "VoteDateHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "VoteDateHeaderView")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configurePagers() {
        repOnePager.set(view: self, dataSource: self, delegate: self)
        repTwoPager.set(view: self, dataSource: self, delegate: self)
        repThreePager.set(view: self, dataSource: self, delegate: self)
        repOnePager.addLoadMoreSpinnerView()
        repTwoPager.addLoadMoreSpinnerView()
        repThreePager.addLoadMoreSpinnerView()
    }
    
    func configureStateImage() {
        if let state =  Datastore.sharedDatastore.user?.streetAddress?.state {
            stateImageView.image = UIImage.imageForState(state)
            stateLabel.text = Constants.abbreviationToFullStateNameDict[state] ?? ""
            if let district = Datastore.sharedDatastore.user?.district {
                districtLabel.text = "District \(district)"
            }
        }
    }
    
    func configureGestureRecognizer() {
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRightToMenu(_:)))
        swipeGR.direction = .right
        view.addGestureRecognizer(swipeGR)
    }
    
    //MARK: Load Data and Data Coordination
    func loadData() {
        if Datastore.sharedDatastore.representatives != nil {
            APIManager.getVotesForRepresentatives({ (success) in
                if success {
                    self.configureRepViews()
                    self.loadInitialVoteData()
                }
            })
        }
    }
    
    func setInitial(data: [Vote]) {
        guard let selectedRepIndex = selectedRepIndex else {
            print("setInitial")
            return
        }
        switch selectedRepIndex{
        case 0:
            repOnePager.set(initialData: data)
        case 1:
            repTwoPager.set(initialData: data)
        case 2:
            repThreePager.set(initialData: data)
        default:
            break
        }
    }
    
    func format(votes: [Vote], with oldVotes: [Vote]){
        if !votes.isEmpty {
            cellMap = votes.groupedBySection(groupBy: { (datum) -> (Date) in
                // group votes by day of vote
                return datum.date?.computedDayFromDate ?? Date()
            })
            append(data: votes, to: oldVotes)
        }
    }
    
    func loadInitialVoteData() {
        guard let selectedRepIndex = selectedRepIndex else {
            print("Load Initial Data")
            return }
        Datastore.sharedDatastore.getVotesFor(representative: selectedRepIndex, at: 0, with: 50, onCompletion: { (votes) in
            setInitial(data: votes)
        })
    }
    
    func makeRequestForResults(at offset: UInt, withLimit limit: UInt, onComplete: @escaping (([Vote]?) -> Void)) {
        //guard let selectedRepIndex = selectedRepIndex else {
        //   print("makeRequestForResults")
        //  return
        //}
        onComplete([])
        // Datastore.sharedDatastore.getVotesFor(representative: selectedRepIndex, at: Int(offset), with: Int(repOnePager.pageLimit), onCompletion: { (votes) in
        //        onComplete(votes)
        //    })
    }
    
    //MARK: RepView UI & Delegate Methods
    ///  Repview Delegate Method - fires when repView has been selected via tapGesture
    func repViewTapped(is selected: Bool, at position: Int) {
        guard let representatives = representatives else { return }
        if selected && position < representatives.count {
            selectedRepresentative = representatives[position]
            selectedRepIndex = position
            
            switch position {
            case 1:
                repOnePager.isDisabled = true
                repTwoPager.isDisabled = false
                repThreePager.isDisabled = true
            case 2:
                repOnePager.isDisabled = true
                repTwoPager.isDisabled = true
                repThreePager.isDisabled = false
            default:
                repOnePager.isDisabled = false
                repTwoPager.isDisabled = true
                repThreePager.isDisabled = true
            }
            
            if data.isEmpty {
                loadInitialVoteData()
            } else {
                format(votes: data, with: [])
            }
            
            //Animations
            func animateTableViewUp() {
                UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
                    self.tableViewTopToRepContactView.constant = 10
                    self.tableViewHeightConstraint.isActive = false
                    self.tableViewBottomToBottom.isActive = true
                    self.view.layoutIfNeeded()
                    
                    self.backgroundImageView.alpha = 0
                }, completion: nil)
            }
            
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
                
                animateTableViewUp()
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
                
                animateTableViewUp()
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
                
                animateTableViewUp()
                repContactView.animateIn()
                
            default:
                break
            }
        } else {
            repViewDeselected()
            selectedRepresentative = nil
            selectedRepIndex = nil
            backgroundImageView.alpha = 1
        }
        repViewOne.layoutIfNeeded()
        repViewTwo.layoutIfNeeded()
        repViewThree.layoutIfNeeded()
    }
    
    /// Breaks down all active selected View constraints & brings view back to baseline (3 reps shown)
    func repViewDeselected() {
        let views = [repViewOne, repViewTwo, repViewThree]
        
        repContactView.animateOut()
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
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
            self.tableViewTopToRepContactView.constant = 600
            
            self.repOneWidth.constant = -20
            self.repTwoWidth.constant = -20
            self.repThreeWidth.constant = -20
            
            self.view.layoutIfNeeded()
        })
        
        contractedRepConstraints(active: true)
    }
    
    fileprivate func contractedRepConstraints(active: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.repOneToTopContracted.isActive = active
            self.repTwoToRepOneBottomContracted.isActive = active
            self.repThreeToRepTwoBottomContracted.isActive = active
            self.repThreeToBottomContracted.isActive = active
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Menu Bar UI Methods
    func pushMenuBar() {
        tapView = UIView(frame: view.frame)
        view.addSubview(tapView ?? UIView())
        view.bringSubview(toFront: menuBarContainerView)
        tapView?.backgroundColor = UIColor.black
        tapView?.alpha = 0
        if let menuViewController = menuViewController {
            menuViewController.animateIn()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tapView?.alpha = 0.3
            self.menuBarTrailingConstraint.constant = 150
            self.view.layoutIfNeeded()
        }, completion: { _ in
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTapView(_:)))
            self.tapView?.addGestureRecognizer(tap)
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissTapView(_:)))
            swipe.direction = .left
            self.tapView?.addGestureRecognizer(swipe)
        })
    }
    
    func popMenuBar() {
        if let menuViewController = menuViewController {
            menuViewController.animateOut() 
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.menuBarTrailingConstraint.constant = -3
            self.tapView?.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
           self.tapView?.removeFromSuperview()
           self.tapView = nil
        })
        disableSwipe = false 
    }
    
    func dismissTapView(_ gestureRecognizer: UIGestureRecognizer) {
        popMenuBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        menuViewController = segue.destination as? MenuViewController
    }
    
    // MARK: TableViewDelegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellMap.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = cellMap[section]?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER, for: indexPath) as? VoteTableViewCell else { return UITableViewCell() }
        guard let vote = cellMap[indexPath.section]?[indexPath.row] else { return UITableViewCell()}
        cell.vote = vote
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "VoteDateHeaderView") as? VoteDateHeaderView,
              let date = cellMap[section]?.first?.date else { return nil }
        view.awakeFromNib()
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25)
        view.configure(with: date)
        view.contentView.backgroundColor = UIColor.kratosLightGray
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vote = cellMap[indexPath.section]?[indexPath.row],
              let rep = selectedRepresentative else { return }
        let vc: VoteViewController = VoteViewController.instantiate()
        vc.vote = vote
        vc.representative = rep
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Handle RepContactView Press 
    func presentTwitter(shouldPresent: Bool) {
        if shouldPresent { // should present twitter
            let alertVC = UIAlertController(title: "T W I T T E R", message: "Send User to Twitter", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
            present(alertVC, animated: true, completion: nil)
        } else { // should present office address
            let alertVC = UIAlertController(title: "A D D R E S S", message: "The address goes here", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: Handle SwipeGesture Recognizer
    func handleSwipeRightToMenu(_ gestureRecognizer: UIGestureRecognizer) {
        if !disableSwipe {
            pushMenuBar()
            disableSwipe = true
        }
    }
}

