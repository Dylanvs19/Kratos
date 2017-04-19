//
//  MainViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import SafariServices

class MainViewController: UIViewController, RepViewDelegate, RepInfoViewPresentable, ActivityIndicatorPresenter {
    
    @IBOutlet var repViewOne: RepresentativeView!
    @IBOutlet var repViewTwo: RepresentativeView!
    @IBOutlet var repViewThree: RepresentativeView!
    
    var repViews: [RepresentativeView] {
        return [repViewOne, repViewTwo, repViewThree]
    }
    
    @IBOutlet weak var kratosImageView: UIImageView!
    @IBOutlet var stateImageView: UIImageView!
    
    @IBOutlet weak var kratosImageViewToTop: NSLayoutConstraint!
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var districtLabel: UILabel!
    
    @IBOutlet var menuBarContainerView: UIView!
    @IBOutlet var menuBarTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainViewScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var repInfoView: RepInfoView?
    var shadeView: UIView = UIView()
    
    var menuViewController: MenuViewController?
    var disableSwipe = false
    
    var representatives: [Person]? {
        get {
            return Datastore.shared.representatives
        }
    }
    
    var tapView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        configureStateImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        reloadInputViews()
    }
    
    func loadData() {
        presentActivityIndicator()
        APIManager.getRepresentatives({ [weak self] (success) in
            self?.hideActivityIndicator()
            if success {
                self?.configureRepViews()
            } else {
                self?.presentMessageAlert(title: "Error", message: "Could not load your representatives", buttonOneTitle: "OK")
            }
        }, failure: { (error) in
            self.showError(error: error)
        })
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
            repViewOne.isUserInteractionEnabled = false
        } else if representatives.count == 3 {
            
            var count = 0
            repViews.forEach { (repView) in
                let rep = representatives[count]
                repView.viewPosition = count
                repView.configure(with: rep)
                count += 1
            }
        }
        
        repViewOne.repViewDelegate = self
        repViewTwo.repViewDelegate = self
        repViewThree.repViewDelegate = self
    }
    
    fileprivate func configureStateImage() {
        if let state =  Datastore.shared.user?.address?.state {
            stateImageView.image = UIImage.imageForState(state.uppercased())
            stateLabel.text = state.uppercased().fullStateName()
            if let district = Datastore.shared.user?.district {
                districtLabel.text = "District \(district)"
            }
        }
    }
    
    //MARK: RepView UI & Delegate Methods
    ///  Repview Delegate Method - fires when repView has been selected via tapGesture
    func repViewTapped(at position: Int, personID: Int, image: UIImage, initialImageViewPosition: CGRect) {
        let view = repViews[position]
        presentRepInfoView(with: view.frame, personImage: image, initialImageViewPosition: initialImageViewPosition, personID: personID)
    }
}

