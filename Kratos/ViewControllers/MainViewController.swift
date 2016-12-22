//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import SafariServices

class MainViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RepViewDelegate, PagingView, PagingDataSource, PagingTableViewDelegate {
    
    @IBOutlet var repViewOne: RepresentativeView!
    @IBOutlet var repViewTwo: RepresentativeView!
    @IBOutlet var repViewThree: RepresentativeView!
    
    @IBOutlet weak var kratosLabel: UILabel!
    @IBOutlet weak var kratosImageView: UIImageView!
    @IBOutlet var stateImageView: UIImageView!
    
    @IBOutlet weak var kratosImageViewToTop: NSLayoutConstraint!
    
    @IBOutlet weak var stateImageViewCenterYToLabelView: NSLayoutConstraint!
    @IBOutlet weak var stateImageViewCenterYToRepViewOne: NSLayoutConstraint!
    @IBOutlet weak var stateImageViewCenterYToRepViewTwo: NSLayoutConstraint!
    @IBOutlet weak var stateImageViewCenterYToRepViewThree: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageViewToTop: NSLayoutConstraint!
    
    @IBOutlet weak var labelView: UIView!
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
    
    @IBOutlet weak var mainViewScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    
    var blurViewEnabled: Bool = false
    
    var menuViewController: MenuViewController?
    var disableSwipe = false
    
    var representatives: [Person]? {
        didSet {
            if representatives != nil {
                configureRepViews()
            }
        }
    }
    var selectedRepresentative: Person? {
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
    var repOneTallies: [LightTally] = [] {
        didSet {
            format(tallies: repOneTallies, with: oldValue)
        }
    }
    var repTwoTallies: [LightTally] = [] {
        didSet {
            format(tallies: repTwoTallies, with: oldValue)
        }
    }
    var repThreeTallies: [LightTally] = [] {
        didSet {
            format(tallies: repThreeTallies, with: oldValue)
        }
    }
    
    var data: [LightTally] {
        get {
            guard let selectedRepIndex = selectedRepIndex else { return repOneTallies }
            switch selectedRepIndex {
            case 1:
                return repTwoTallies
            case 2:
                return repThreeTallies
            default:
                return repOneTallies
            }
        }
        set {
            guard let selectedRepIndex = selectedRepIndex else {
                repOneTallies = newValue
                return
            }
            
            switch selectedRepIndex {
            case 1:
                repTwoTallies = newValue
            case 2:
                repThreeTallies = newValue
            default:
                repOneTallies = newValue
            }
        }
    }
    var cellMap = [Int: [LightTally]]()
    
    // Each flow of data has its own Pager to handle it.
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
        
        representatives = Datastore.sharedDatastore.representatives
        
        configureStateImage()
        
        configureGestureRecognizer()
        
        configureMenuBar()
        
        configureTableView()
        
        configurePagers()
        
        //Set the repContactView's action block to fire method on this VC when certain actions (button presses) taken
        repContactView.shouldPresentTwitter = presentTwitter
        
        mainViewScrollView.delegate = self

    }
    
    //MARK: Configuration Methods
    fileprivate func configureRepViews() {
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
        kratosLabel.alpha = 0
        repViewDeselected()
    }
    
    fileprivate func configureMenuBar() {
        menuBarContainerView.layer.shadowColor = UIColor.black.cgColor
        menuBarContainerView.layer.shadowOffset = CGSize(width: 3, height: 0)
        menuBarContainerView.layer.shadowOpacity = 0.3
        menuBarContainerView.layer.shadowRadius = 1
    }
    
    fileprivate func configureTableView () {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "VoteTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER)
        tableView.register(UINib(nibName: "VoteDateHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "VoteDateHeaderView")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func configurePagers() {
        repOnePager.set(view: self, dataSource: self, delegate: self)
        repTwoPager.set(view: self, dataSource: self, delegate: self)
        repThreePager.set(view: self, dataSource: self, delegate: self)
        repOnePager.addLoadMoreSpinnerView()
        repTwoPager.addLoadMoreSpinnerView()
        repThreePager.addLoadMoreSpinnerView()
    }
    
    fileprivate func configureStateImage() {
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
    
    fileprivate func setInitial(data: [LightTally]) {
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
    
    fileprivate func format(tallies: [LightTally], with oldTallies: [LightTally]){
        if !tallies.isEmpty {
            cellMap = tallies.groupedBySection(groupBy: { (datum) -> (Date) in
                // group votes by day of vote
                return datum.date?.computedDayFromDate ?? Date()
            })
            append(data: tallies, to: oldTallies)
        }
    }
    
    fileprivate func loadInitialVoteData() {
        guard let selectedRepresentative = selectedRepresentative else {
            print("Load Initial Data")
            return
        }
        APIManager.getTallies(for: selectedRepresentative, success: { (lightTallies) in
            self.setInitial(data: lightTallies)
        }, failure: { (error) in
            print(error)
        })
    }
    
    func makeRequestForResults(at offset: UInt, withLimit limit: UInt, onComplete: @escaping (([LightTally]?) -> Void)) {
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
        guard let representatives = representatives else {
            return
        }
        if selected && position < representatives.count {
            selectedRepresentative = representatives[position]
            selectedRepIndex = position
            
            // set pager for proper data stream
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
                format(tallies: data, with: []) // format & reload tableView with new pager data
            }
            
            //Animations
            contractedRepConstraints(active: false)
            
            UIView.animate(withDuration: 0.25, animations: {
                switch position {
                case 1:
                    self.repViewOne.alpha = 0
                    self.repViewThree.alpha = 0
                    self.repTwoSelectedHeight.isActive = true
                    self.repTwoWidth.constant = 0
                    self.repTwoSelectedYPosition.isActive = true
                    self.stateImageViewCenterYToLabelView.isActive = false
                    self.stateImageViewCenterYToRepViewOne.isActive = true
                    self.stateImageViewCenterYToRepViewTwo.isActive = true
                case 2:
                    self.repViewOne.alpha = 0
                    self.repViewTwo.alpha = 0
                    self.repThreeWidth.constant = 0
                    self.repThreeSelectedYPosition.isActive = true
                    self.repThreeSelectedHeight.isActive = true
                    self.stateImageViewCenterYToLabelView.isActive = false
                    self.stateImageViewCenterYToRepViewTwo.isActive = true
                    self.stateImageViewCenterYToRepViewThree.isActive = true
                default:
                    self.repViewTwo.alpha = 0
                    self.repViewThree.alpha = 0
                    self.repOneSelectedYPosition.isActive = true
                    self.repOneSelectedHeight.isActive = true
                    self.repOneWidth.constant = 0
                    self.stateImageViewCenterYToLabelView.isActive = false
                    self.stateImageViewCenterYToRepViewThree.isActive = true
                    self.stateImageViewCenterYToRepViewOne.isActive = true
                }
                self.stateImageViewCenterYToLabelView.isActive = false
                self.backgroundImageViewHeight.constant = 19
                self.backgroundImageView.addBlurEffect()
                self.labelView.alpha = 0
                self.kratosImageView.alpha = 0
                self.kratosLabel.alpha = 1
                self.view.layoutSubviews()
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
                self.tableViewTopToRepContactView.constant = 10
                self.tableViewHeightConstraint.isActive = false
                self.tableViewBottomToBottom.isActive = true
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            repContactView.animateIn()
            
        } else {
            repViewDeselected()
            selectedRepresentative = nil
            selectedRepIndex = nil
        }
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
            
            self.stateImageViewCenterYToRepViewOne.isActive = false
            self.stateImageViewCenterYToRepViewTwo.isActive = false
            self.stateImageViewCenterYToRepViewThree.isActive = false
            self.stateImageViewCenterYToLabelView.isActive = true
            
            self.backgroundImageViewHeight.constant = 190
            self.backgroundImageView.removeBlurEffect()
            self.labelView.alpha = 1
            self.kratosImageView.alpha = 1
            self.kratosLabel.alpha = 0
            
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
        mainView.addSubview(tapView ?? UIView())
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
    
    //MARK: ScrollViewDelegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            kratosImageViewToTop.constant = 5 + scrollView.contentOffset.y
            kratosImageView.transform = .init(rotationAngle: scrollView.contentOffset.y/50)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        kratosImageView.transform = .init(rotationAngle: 0)
        blurViewEnabled = !blurViewEnabled
        self.view.layoutIfNeeded()
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
        guard let tally = cellMap[indexPath.section]?[indexPath.row] else { return UITableViewCell()}
        cell.tally = tally
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
        guard let lightTally = cellMap[indexPath.section]?[indexPath.row],
              let rep = selectedRepresentative else { return }
        let vc: VoteViewController = VoteViewController.instantiate()
        vc.lightTally = lightTally
        vc.representative = rep
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Handle RepContactView Buttons
    func presentTwitter(shouldPresent: Bool) {
        if shouldPresent { // should present twitter
            guard let selectedRepresentative = selectedRepresentative,
                let handle = selectedRepresentative.twitter else {
                    let alertVC = UIAlertController(title: "Error", message: "Representative does not have a twitter account", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
                    present(alertVC, animated: true, completion: nil)
                    return
            }
            
            if let url = URL(string: "twitter://user?screen_name=\(handle)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                if let url = URL(string: "https://twitter.com/\(handle)") {
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true, completion: nil)
                }
            }
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
    
    func presentYourVotesViewController() {
        let viewController:YourVotesViewController = YourVotesViewController.instantiate()
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        present(viewController, animated: false, completion: nil)
    }
}

