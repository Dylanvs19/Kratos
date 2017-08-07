//
//  Curtain.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/2/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol Spinnable {
    func startSpin()
    func stopSpin()
}

extension UIView {
    func startSpin() {
        if let view = self as? UIImageView {
        UIView.animate(withDuration: 0.7, delay: 0, options: [.autoreverse, .repeat], animations: {
            view.alpha = 1
            view.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0.0, 1.0, 0.0)
            view.layoutIfNeeded()
        })
        } else if let view = self as? UIActivityIndicatorView {
            view.alpha = 1
            view.startAnimating()
        }
    }
    
    func stopSpin() {
        if let view = self as? UIImageView {
            view.alpha = 0
            view.layer.removeAllAnimations()
            view.layoutIfNeeded()
        } else if let view = self as? UIActivityIndicatorView {
            view.alpha = 0
            view.stopAnimating()
        }
        
    }
}

protocol CurtainPresenter {
    var curtain: Curtain { get set }
    func addCurtain()
}

extension CurtainPresenter where Self: UIView {
    func addCurtain() {
        addSubview(curtain)
        curtain.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CurtainPresenter where Self: UIViewController {
    func addCurtain() {
        view.addSubview(curtain)
        curtain.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class Curtain: UIVisualEffectView {
    
    enum Style {
        case kratos
        case activityIndicator
    }
    
    // MARK: - Variables -
    let loadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()
    var curtainStyle: Style = .kratos
    
    
    var view: UIView {
        return curtainStyle == .kratos ? UIImageView(image: #imageLiteral(resourceName: "Kratos")) : UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }

    convenience init(with style: Style) {
        self.init(effect: UIBlurEffect(style: .extraLight))
        self.curtainStyle = style
        self.addSubviews()
        self.constrainViews()
        self.styleViews()
    }
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        UIView.animate(withDuration: 0.4) { 
            self.alpha = 1
            self.view.startSpin()
            self.layoutIfNeeded()
        }
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.4) {
            self.alpha = 0
            self.view.stopSpin()
            self.layoutIfNeeded()
        }
    }
}

extension Curtain: ViewBuilder {
    func addSubviews() {
        addSubview(view)
    }
    func constrainViews() {
        view.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            if curtainStyle == .kratos {
                make.height.width.equalTo(50)
            }
        }
    }
    func styleViews() {
        
    }
}

extension Curtain: RxBinder {
    func bind() {
        loadStatus.asObservable()
            .subscribe(onNext: { [weak self] loadStatus in
                switch loadStatus {
                case .loading:
                    self?.startAnimating()
                default:
                    self?.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
}

