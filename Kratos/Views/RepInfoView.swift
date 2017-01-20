//
//  RepInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepInfoViewPresentable: class {
    var repInfoView: RepInfoView! { get set }
    func presentRepInfoView(with person: Person)
    func presentRepInfoView(with person: LightPerson)
}

extension RepInfoViewPresentable where Self: UIViewController {
    func presentRepInfoView(with person: Person) {
        //repInfoView.animateIn()
        repInfoView.configure(with: person)
        repInfoView.repContactView.configure(with: person)
        repInfoView.repContactView.configureActionBlocks(presentTwitter: self.presentTwitter, presentHome: self.presentHomeAddress)
        repInfoView.layoutSubviews()
        FirebaseAnalytics.FlowAnalytic.selectedRepresentative(representativeID: person.id).fireEvent()
    }
    
    func presentRepInfoView(with person: LightPerson) {
        
        //TODO: Need an endpoint that will take a Person ID & return a person. 
//        repInfoView?.configure(with: person, exitActionBlock: repInfoViewExitPressed)
//        repInfoView?.repContactView.configureActionBlocks(presentTwitter: self.presentTwitter, presentHome: self.presentHomeAddress)
//        repInfoView?.layoutSubviews()
    }
}

class RepInfoView: UIView, Loadable {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var repImageView: RepImageView!
//    @IBOutlet weak var repName: UILabel!
//    @IBOutlet weak var repType: UILabel!
//    @IBOutlet weak var repState: UILabel!
    @IBOutlet weak var repStateView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var repContactView: RepContactView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
        backgroundColor = UIColor.clear
        alphaOut()
    }
    
    func configure(with person: Person) {
        addBlurEffect(front: false)
        guard let firstName = person.firstName,
            let lastName = person.lastName else { return }
//        repName.text = "\(firstName) \(lastName)"
//        repType.text = person.roles?.first?.representativeType?.rawValue
        repImageView.setRepresentative(person: person, repInfoViewActionBlock: nil)
        repImageView.isUserInteractionEnabled = false
        if let state =  person.currentState {
            repStateView.image = UIImage.imageForState(state)
        }
        alphaOut()
        animateIn()
    }

    func animateIn() {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.alpha = 1
            self.repImageView.alpha = 1
//            self.repName.alpha = 1
//            self.repType.alpha = 1
//            self.repState.alpha = 1
            self.repStateView.alpha = 1
            self.exitButton.alpha = 1
            self.repContactView.alpha = 1
            self.layoutIfNeeded()
        }) { (success) in
            self.repContactView.animateIn()
        }
    }
    
    func alphaOut() {
        alpha = 0
        repImageView.alpha = 0
//        repName.alpha = 0
//        repType.alpha = 0
//        repState.alpha = 0
        repStateView.alpha = 0
        exitButton.alpha = 0
        repContactView.alpha = 0
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.alphaOut()
            self.repContactView.animateOut()
            self.layoutIfNeeded()
        }
    }
}
