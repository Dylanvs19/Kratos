//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import SafariServices

class BillViewController: UIViewController, ActivityIndicatorPresenter, RepInfoViewPresentable, BillInfoViewDelegate, InfoManagerViewDelegate {
    
    enum ViewType: Int, RawRepresentable {
        //ViewType's Int property matches up with index for views
        case summary
        case sponsor
        case vote
        case activity
    }
    
    //Header
    fileprivate var headerViewHeightConstraint = NSLayoutConstraint()
    fileprivate var initialHeaderViewHeight: CGFloat = 0.0
    fileprivate var headerView = BillHeaderView()
    //InfoViewManager
    fileprivate var infoManagerView = InfoManagerView()
    //Info Level
    fileprivate var infoView = UIView()
    fileprivate var infoScrollView = UIScrollView()
    fileprivate var stackView = UIStackView()
    
    //View State
    fileprivate var viewType: ViewType = .summary {
        didSet {
            let width = self.infoView.frame.size.width
            infoScrollView.scrollRectToVisible(CGRect(x: CGFloat(viewType.rawValue) * width, y: 0, width: width, height: 10), animated: true)
        }
    }
    
    //Data
    fileprivate var billID: Int? {
        didSet {
            KratosAnalytics.shared.updateBillAnalyicAction(with: billID)
        }
    }
    fileprivate var bill: Bill? {
        didSet {
            if let bill = bill {
                self.buildAndConfigureViews(with: bill)
            }
        }
    }
    
    //Delegate Properties
    var repInfoView: RepInfoView?
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
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
                self?.bill = bill //build & configures views in didSet
                }, failure: { (error) -> (Void) in
                    self.hideActivityIndicator()
                    self.showError(error)
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    //MARK: Build Views
    fileprivate func buildAndConfigureViews(with bill: Bill) {        
        headerView.pin(to: view, for: [.leading, .trailing, .top])
        setHeaderView(with: bill)
        
        infoManagerView.pin(to: view, for: [.width])
        infoManagerView.configure(with: buildInfoManagerStringArray(from: bill))
        infoManagerView.heightAnchor.constraint(equalToConstant: 40)
        infoManagerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoManagerView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        infoManagerView.delegate = self
        
        view.addSubview(infoView)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        infoView.topAnchor.constraint(equalTo: infoManagerView.bottomAnchor).isActive = true
        
        infoScrollView.pin(to: infoView)
        infoScrollView.alwaysBounceHorizontal = false
        infoScrollView.alwaysBounceVertical = false
        infoScrollView.bounces = false
        infoScrollView.isScrollEnabled = false
        
        stackView.pin(to: infoScrollView)
        stackView.heightAnchor.constraint(equalTo: infoView.heightAnchor).isActive = true 
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        view.layoutSubviews()
        view.layoutIfNeeded()
        
        self.configureInfoViews(with: bill)
       
    }
    
    fileprivate func buildInfoManagerStringArray(from bill: Bill) -> [String] {
        var retVal = [String]()
        if bill.summary != nil || bill.committees != nil {
            retVal.append("Details")
        }
        if bill.sponsor != nil {
            retVal.append("Sponsors")
        }
        if bill.tallies != nil {
            retVal.append("Votes")
        }
        if bill.actions != nil {
            retVal.append("Activity")
        }
        return retVal
    }
    
    //MARK: View configuration and Setup
    
    fileprivate func setHeaderView(with bill: Bill) {
        headerView.configure(with: bill)
        headerView.layoutSubviews()
        view.layoutSubviews()
        view.layoutIfNeeded()
        initialHeaderViewHeight = headerView.frame.size.height
        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: initialHeaderViewHeight)
        headerViewHeightConstraint.isActive = true
    }
    
    public func configure(with billID: Int, tallyID: Int? = nil ) {
        self.billID = billID
    }
    
    fileprivate func configureInfoViews(with bill:Bill) {
        
        //setup summaryView
        let billSummaryView = BillSummaryView()
        stackView.addArrangedSubview(billSummaryView)
        billSummaryView.translatesAutoresizingMaskIntoConstraints = false
        billSummaryView.widthAnchor.constraint(equalTo: infoView.widthAnchor).isActive = true
        billSummaryView.configure(with: bill, width: infoView.frame.width, urlPressed: presentSafariView)
        billSummaryView.billInfoViewDelegate = self
        //setup sponsorsView
        let sponsorsView = BillSponsorsView()
        stackView.addArrangedSubview(sponsorsView)
        sponsorsView.configure(with: bill)
        sponsorsView.billInfoViewDelegate = self 
        //setup VotesView
        
        //setup ActivityView
        
        //must set scrollviewDelegate of each to self.
        stackView.layoutSubviews()
        view.layoutIfNeeded()
        
    }
    
    
    //MARK: InfoView Delegate handling
    func scrollViewDid(translate translation: CGFloat, contentOffsetY: CGFloat) {
        let headerHeight = headerViewHeightConstraint.constant
        if translation > 0 {
            if headerHeight > 40 {
                let constant = headerViewHeightConstraint.constant - translation
                headerViewHeightConstraint.constant = constant < 40 ? 40 : constant
            }
        } else {
            if headerHeight < initialHeaderViewHeight && contentOffsetY <= initialHeaderViewHeight {
                let constant = headerHeight - translation
                headerViewHeightConstraint.constant = constant > initialHeaderViewHeight ? initialHeaderViewHeight : constant
            }
        }
    }
 
    //MARK: InfoManager Delegate Handling
    func didSelect(title: String, at index: Int) {
        viewType = ViewType(rawValue: index) ?? .summary
    }
    
    //MARK: Tally VC Handling.
    fileprivate func pushTallyVC() {
        let vc: TallyViewController = TallyViewController.instantiate()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: nil)
        
        self.present(vc, animated: false, completion: nil)
    }
    
    fileprivate func popTallyVC() {
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
