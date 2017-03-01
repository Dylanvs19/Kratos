//
//  KratosActivityIndicator.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

/// Protcol that provides an API to configure, present, and hide a Kratos activity indicator
protocol ActivityIndicatorPresentable: class {
    var activityIndicator: KratosActivityIndicator? { get set }
    func presentActivityIndicator()
    func hideActivityIndicator()
}

extension ActivityIndicatorPresentable where Self: UIViewController {
    
    func presentActivityIndicator() {
        activityIndicator = KratosActivityIndicator()
        guard let activityIndicator = activityIndicator else {return}
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        UIView.animate(withDuration: 0.1, animations: {
            self.view.bringSubview(toFront:activityIndicator)
            activityIndicator.isHidden = false
            self.view.layoutIfNeeded()
        }) { (success) in
            activityIndicator.startSpin()
        }
    }
    
    func hideActivityIndicator() {
        guard let activityIndicator = activityIndicator else {return}
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                activityIndicator.isHidden = true
                self.view.layoutIfNeeded()
            }, completion: { [weak self] (success) in
                self?.activityIndicator = nil
            })
        }
    }
}

class KratosActivityIndicator: UIVisualEffectView {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    let blurEffect = UIBlurEffect(style: .extraLight)
    let vibrancyView: UIVisualEffectView
    
    init() {
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(imageView)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = self.superview else { return }
            
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: superview.frame.size.width,
                                height: superview.frame.size.height)
        
            vibrancyView.frame = self.bounds
            layer.masksToBounds = true
            imageView.frame.size = CGSize(width: 100, height: 100)
            imageView.center = superview.center
    }
    
    func startSpin() {
        UIView.animate(withDuration: 0.7, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.imageView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)
            self.imageView.layoutIfNeeded()
        })
    }
    
    func stopSpin() {
        imageView.layer.removeAllAnimations()
        layoutIfNeeded()
    }
}
