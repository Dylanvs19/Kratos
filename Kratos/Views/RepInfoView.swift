//
//  RepInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepInfoViewPresentable: class {
    var repInfoView: RepInfoView? { get set }
    func presentRepInfoView(with initalViewPosition: CGRect, personImage: UIImage, initialImageViewPosition: CGRect, personID: Int)
}

extension RepInfoViewPresentable where Self: UIViewController {
    
    func presentRepInfoView(with initalViewPosition: CGRect, personImage: UIImage, initialImageViewPosition: CGRect, personID: Int) {
        repInfoView = RepInfoView()
        guard let repInfoView = repInfoView else { return }
        repInfoView.configure(with: initalViewPosition, personImage: personImage, initialImageViewPosition: initialImageViewPosition, personID: personID)
        view.addSubview(repInfoView)
        repInfoView.exitPressed = dismissRepInfoView
        repInfoView.tallySelected = tallySelected
        repInfoView.billSelected = billSelected
        repInfoView.repContactView.configureActionBlocks(presentTwitter: self.presentTwitter, presentHome: self.presentHomeAddress)
    }
    
    func tallySelected(with lightTally: LightTally) {
        guard let id = lightTally.billID else {
            let vc: TallyViewController = TallyViewController.instantiate()
            vc.representative = repInfoView?.person
            vc.lightTally = lightTally
            navigationController?.exclusivePush(viewController: vc)
            return
        }
        let vc: BillViewController = BillViewController.instantiate()
        vc.billID = id
        navigationController?.exclusivePush(viewController: vc)
    }
    
    func billSelected(with billID: Int) {
        let vc: BillViewController = BillViewController.instantiate()
        vc.billID = billID
        navigationController?.exclusivePush(viewController: vc)
    }
    
    func dismissRepInfoView() {
        guard let repInfoView = repInfoView else { return }
        repInfoView.animateOut(onCompletion: { [weak self] in
            guard let s = self else { fatalError("deallocated self before attempt to access it") }
            repInfoView.removeFromSuperview()
            s.repInfoView = nil
        })
    }
}

class RepInfoView: UIView, Loadable, RepInfoManagerDelegate {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var repImageView: RepImageView!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repType: UILabel!
    @IBOutlet weak var repState: UILabel!
    @IBOutlet weak var repParty: UILabel!
    @IBOutlet weak var kratosLabel: UILabel!
    @IBOutlet weak var repStateView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var repContactView: RepContactView!
    @IBOutlet weak var repInfoManagerView: RepInfoManagerView!
    @IBOutlet weak var repInfoBackgroundView: UIView!
    @IBOutlet weak var repInfoTopView: UIView!
    
    @IBOutlet weak var repImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var repImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var repImageViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewButtonToBottomConstraint: NSLayoutConstraint!
    
    var viewHeightConstraint: NSLayoutConstraint?
    var viewWidthConstraint: NSLayoutConstraint?
    var viewTopConstraint: NSLayoutConstraint?
    var viewLeadingConstraint: NSLayoutConstraint?
    
    var exitPressed: (() -> ())?
    var tallySelected: ((LightTally) -> ())?
    var billSelected: ((Int) -> ())?
    
    ///Size and position of the expanded ImageView.
    var expandedImageViewPosition: CGRect = CGRect(x: 10, y: 30, width: 90, height: 90)
    
    ///The initial position of the view relative to the UIViewControllers self.view.bounds property. This CGRect should match up with the
    var initalViewPosition: CGRect?
    
    ///Size and position of the full repInfoView. This will be set to the repInfoView superview's self.bounds property.
    fileprivate var expandedViewPosition: CGRect?
    
    ///Inital position of the image view with relation to its superview, not the visible CGRect on the screen.
    var initialImageViewPosition: CGRect?
    
    var person: Person?
    var personID: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview,
            let initalViewPosition = initalViewPosition,
            let initialImageViewPosition = initialImageViewPosition else { return }
        expandedViewPosition = CGRect(x: 0,
                                      y: 0,
                                      width: superview.frame.size.width,
                                      height: superview.frame.size.height)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        viewTopConstraint = self.topAnchor.constraint(equalTo: superview.topAnchor, constant: initalViewPosition.origin.y)
        viewLeadingConstraint = self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: initalViewPosition.origin.x)
        viewHeightConstraint = self.heightAnchor.constraint(equalToConstant: initalViewPosition.size.height)
        viewWidthConstraint = self.widthAnchor.constraint(equalToConstant: initalViewPosition.size.width)
        
        viewTopConstraint?.isActive = true
        viewLeadingConstraint?.isActive = true
        viewHeightConstraint?.isActive = true
        viewWidthConstraint?.isActive = true
        
        repImageViewToTopConstraint.constant = initialImageViewPosition.origin.y
        repImageViewLeadingConstraint.constant = initialImageViewPosition.origin.x
        repImageViewWidthConstraint.constant = initialImageViewPosition.size.width
        
        repInfoBackgroundView.addShadow()
        //        repInfoManagerView.addShadow()
        
        layoutIfNeeded()
        
        repInfoManagerView.delegate = self
        
        alpha = 0
        
        if let personID = personID {
            APIManager.getPerson(for: personID, success: { [weak self] (person) in
                self?.person = person
                self?.repInfoTopView.backgroundColor = person.currentParty?.color()
                UIView.animate(withDuration: 0.1, animations: {
                    self?.alpha = 1
                    self?.layoutIfNeeded()
                }) { (success) in
                    self?.animateIn()
                }
            }) { (error) in
                print(error)
            }
        }
        //self.layoutIfNeeded()
    }
    
    func setConstraints(basedOn cgRect: CGRect) {
        viewTopConstraint?.constant = cgRect.origin.y
        viewLeadingConstraint?.constant = cgRect.origin.x
        viewHeightConstraint?.constant = cgRect.size.height
        viewWidthConstraint?.constant = cgRect.size.width
    }
    
    func configure(with initalViewPosition: CGRect, personImage: UIImage, initialImageViewPosition: CGRect, personID: Int) {
        alpha(shouldShow: false)
        hide(shouldHide: true)
        repInfoBackgroundView.backgroundColor = UIColor.white
        self.repImageView.set(image: personImage)
        self.initalViewPosition = initalViewPosition
        self.initialImageViewPosition = initialImageViewPosition
        self.personID = personID
    }
    
    func configure(with person: Person) {
        guard let firstName = person.firstName,
            let lastName = person.lastName else { return }
        self.repName.text = "\(firstName) \(lastName)"
        self.repType.text = person.currentChamber?.toRepresentativeType().rawValue
        self.repState.text = person.currentState?.fullStateName()
        self.repParty.text = person.currentParty?.capitalLetter()
        self.repParty.textColor = person.currentParty?.color()
        self.repImageView.isUserInteractionEnabled = false
        if let state =  person.currentState {
            self.repStateView.image = UIImage.imageForState(state)
        }
    }
    
    func animateIn() {
        guard let expandedViewPosition = expandedViewPosition else { return }
        // Animate everything except Image view & repInfoManager view
        UIView.animate(withDuration: 0.7, delay: 0.1, options: [], animations: {
            self.setConstraints(basedOn: expandedViewPosition)
            self.repImageViewToTopConstraint.constant = self.expandedImageViewPosition.origin.y
            self.repImageViewLeadingConstraint.constant = self.expandedImageViewPosition.origin.x
            self.repImageViewWidthConstraint.constant = self.expandedImageViewPosition.size.width
            self.tableViewButtonToBottomConstraint.isActive = true
            self.superview?.layoutSubviews()
            self.layoutIfNeeded()
        }) { (success) in
            if let person = self.person {
                self.configure(with: person)
                self.repContactView.configure(with: person)
                self.repInfoManagerView.configure(with: person)
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.hide(shouldHide: false)
                self.alpha(shouldShow: true)
                self.contentView.backgroundColor = UIColor.kratosLightGray
                self.layoutIfNeeded()
            })
            self.repContactView.animateIn()
        }
    }
    
    func animateOut(onCompletion: (() -> ())? = nil) {
        
        tableViewButtonToBottomConstraint.isActive = false
        guard let initalViewPosition = initalViewPosition,
              let initialImageViewPosition = initialImageViewPosition else { return }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha(shouldShow: false)
            self.setConstraints(basedOn: initalViewPosition)
            self.repImageViewToTopConstraint.constant = initialImageViewPosition.origin.y
            self.repImageViewLeadingConstraint.constant = initialImageViewPosition.origin.x
            self.repImageViewWidthConstraint.constant = initialImageViewPosition.size.width
            self.repContactView.animateOut()
            self.contentView.backgroundColor = UIColor.white
            self.layoutIfNeeded()
        }) { (success) in
            onCompletion?()
        }
    }
    
    func alpha(shouldShow: Bool) {
        let alpha: CGFloat = shouldShow ? 1 : 0
        repName.alpha = alpha
        repType.alpha = alpha
        repState.alpha = alpha
        repParty.alpha = alpha
        repStateView.alpha = alpha
        exitButton.alpha = alpha
        repContactView.alpha = alpha
        repInfoManagerView.alpha = alpha
        exitButton.alpha = alpha
        repInfoBackgroundView.alpha = alpha
        kratosLabel.alpha = alpha
    }
    
    func hide(shouldHide: Bool) {
        repName.isHidden = shouldHide
        repType.isHidden = shouldHide
        repState.isHidden = shouldHide
        repParty.isHidden = shouldHide
        repStateView.isHidden = shouldHide
        exitButton.isHidden = shouldHide
        repContactView.isHidden = shouldHide
        repInfoManagerView.isHidden = shouldHide
        exitButton.isHidden = shouldHide
        kratosLabel.isHidden = shouldHide
        repInfoBackgroundView.isHidden = shouldHide
        tableViewButtonToBottomConstraint.isActive = !shouldHide
        
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        exitPressed?()
    }
    
    //MARK: RepInfoManagerDelegate Methods
    func tallySelected(with lightTally: LightTally) {
        self.tallySelected?(lightTally)
    }
    
    func billSelect(with billID: Int) {
        self.billSelected?(billID)
    }
    
}
