//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import SafariServices

class BillViewController: UIViewController, ActivityIndicatorPresenter, RepInfoViewPresentable, BillInfoViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    //Header Level
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //Control Level
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var sponsorsButton: UIButton!
    @IBOutlet weak var votesButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideViewWidthConstraint: NSLayoutConstraint!
    
    //Info Level
    @IBOutlet weak var infoScrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!

    enum ViewType: Int {
        //ViewType's Int property matches up with index for views
        case summary
        case sponsor
        case vote
        case activity
    }
    
    fileprivate var viewType: ViewType = .summary {
        didSet {
            let width = self.view.frame.size.width
            infoScrollView.scrollRectToVisible(CGRect(x: CGFloat(viewType.rawValue) * width - CGFloat(viewType.rawValue) * 20, y: 0, width: width - 20, height: 10), animated: true)
            
            UIView.animate(withDuration: 0.2) { 
                // move slideView
                self.slideViewLeadingConstraint.constant = CGFloat(self.viewType.rawValue) * width/4
                // move stackview
                self.view.layoutIfNeeded()
            }
        }
    }
    var repInfoView: RepInfoView?
    var billID: Int? {
        didSet {
            KratosAnalytics.shared.updateBillAnalyicAction(with: billID)
        }
    }
    fileprivate var bill: Bill?
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    var initialHeaderViewHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        enableSwipeBack()
        loadData()
        self.view.layoutIfNeeded()
    }
    
    //MARK: Data Loading
    
    fileprivate func loadData() {
        if let billId = billID {
            presentActivityIndicator()
            APIManager.getBill(for: billId, success: {[weak self] (bill) -> (Void) in
                self?.hideActivityIndicator()
                self?.configureView(with: bill)
                self?.setHeaderView(with: bill)
                self?.bill = bill
                }, failure: { (error) -> (Void) in
                    self.hideActivityIndicator()
                    self.showError(error)
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    //MARK: View configuration and Setup
    
    fileprivate func setupInitialView() {
        
        slideViewWidthConstraint.constant = self.view.frame.size.width/4
        slideViewLeadingConstraint.constant = CGFloat(viewType.rawValue) * self.view.frame.size.width/4
    }
    
    fileprivate func setHeaderView(with bill: Bill) {
        titleLabel.text = bill.title ?? bill.officialTitle
        headerView.layoutIfNeeded()
        initialHeaderViewHeight = headerView.frame.size.height
        headerViewHeightConstraint.constant = initialHeaderViewHeight
        headerViewHeightConstraint.isActive = true
    }
    
    public func configure(with billID: Int, tallyID: Int?) {
        //set bill ID - 
        // configure screen for bill
        // then pop out tallyView
        
//        self.billID = billID
//        if let tallyID = tallyID {
//            // should pop out tallyID
//            
//        }
    }
    
    private func configureView(with bill:Bill) {
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        //setup summaryView
        let billSummaryView = BillSummaryView()
        stackView.addArrangedSubview(billSummaryView)

        billSummaryView.translatesAutoresizingMaskIntoConstraints = false
        billSummaryView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        billSummaryView.configure(with: bill, width: view.frame.size.width - 20, urlPressed: presentSafariView)
        billSummaryView.billInfoViewDelegate = self
        stackView.layoutSubviews()
        //setup sponsorsView
        let sponsorsView = BillSponsorsView()
        stackView.addArrangedSubview(sponsorsView)
        stackView.layoutSubviews()
        sponsorsView.configure(with: bill)
        sponsorsView.billInfoViewDelegate = self 
        //setup VotesView
        
        //setup ActivityView
        
        //must set scrollviewDelegate of each to self.
        print(stackView.subviews)
        
    }
    
    func scrollViewDid(translate translation: CGFloat) {
        print(translation)
        if translation < 0 {
            if headerViewHeightConstraint.constant > 40 {
                headerViewHeightConstraint.constant += translation
            }
        } else if translation > 0 {
            if headerViewHeightConstraint.constant < initialHeaderViewHeight {
                headerViewHeightConstraint.constant += translation
            }
        }
    }
 
    
    //MARK: InfoButton Handling
    
    @IBAction func summaryButtonPressed(_ sender: Any) {
        viewType = .summary
    }
    @IBAction func sponsorButtonPressed(_ sender: Any) {
        viewType = .sponsor
    }
    @IBAction func votesButtonPressed(_ sender: Any) {
        viewType = .vote
    }
    @IBAction func activityButtonPressed(_ sender: Any) {
        viewType = .activity
    }
    
    //MARK: Tally VC Handling.
    private func pushTallyVC() {
        let vc: TallyViewController = TallyViewController.instantiate()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: nil)
        
        self.present(vc, animated: false, completion: nil)
    }
    
    private func popTallyVC() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            //AnimateVC in
        }, completion: nil)
    }
    
    
    //MARK: RepInfo Configuration
    private func configureCosponsorsForRepInfoView(cellRectWithinView: CGRect, image: UIImage, imageRect: CGRect, personID: Int) {
        var repVotesView: RepVotesView?
        for view in stackView.subviews where type(of: view) == RepVotesView.self {
            repVotesView = view as? RepVotesView
        }
        // make sure repVotesView exists
        guard let votesView = repVotesView else { return }
//        
//        //votesView frame with relation to stackView(i.e. content size of scrollview - Content offset of the scrollview = currect Visibile Votes View in scrollView
//        //let visibileTableViewYposition = votesView.frame.origin.y - scrollView.contentOffset.y
//        
//        //votesViewPosition + cellRectWithinView.origin.y = top of cell.
//        let topOfCell = visibileTableViewYposition + cellRectWithinView.origin.y
//        let rect = CGRect(x: 10, y: topOfCell + 10, width: cellRectWithinView.size.width, height: cellRectWithinView.size.height)
//        
//        presentRepInfoView(with: rect, personImage: image, initialImageViewPosition: imageRect, personID: personID)
    }
    
    //MARK: Custom Layout Methods
    private func layoutStackView() {
        self.stackView.layoutSubviews()
        self.stackView.layoutIfNeeded()
    }
    
    private func layoutStackViewWithAnimation() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        })
    }

}
