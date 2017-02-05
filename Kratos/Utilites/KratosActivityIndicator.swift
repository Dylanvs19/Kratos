//
//  KratosActivityIndicator.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

protocol ActivityIndicatorPresentable: class {
    var activityIndicator: KratosActivityIndicator { get set }
    func setupActivityIndicator()
    func presentActivityIndicator()
    func hideActivityIndicator()
}

extension ActivityIndicatorPresentable where Self: UIViewController {
    
    func setupActivityIndicator() {
        activityIndicator.isHidden = true
    }
    
    func presentActivityIndicator() {
        view.addSubview(activityIndicator)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.bringSubview(toFront: self.activityIndicator)
            self.activityIndicator.isHidden = false
            self.view.layoutIfNeeded()
        }) { (success) in
            self.activityIndicator.startSpin()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator.isHidden = true
                self.view.layoutIfNeeded()
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
        
        if let superview = self.superview {
            
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: superview.frame.size.width,
                                height: superview.frame.size.height)
            vibrancyView.frame = self.bounds
            
            layer.masksToBounds = true
            imageView.frame.size = CGSize(width: 100, height: 100)
            imageView.center = superview.center
        }
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
