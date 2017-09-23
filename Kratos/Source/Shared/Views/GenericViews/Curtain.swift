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
    
    // MARK: - Variables -
    let loadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()
    
    var view: UIImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))

    convenience init() {
        self.init(effect: UIBlurEffect(style: .extraLight))
        addSubviews()
        constrainViews()
        styleViews()
        bind()
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
            UIView.animate(withDuration: 0.7, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.view.alpha = 1
                self.view.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0.0, 1.0, 0.0)
                self.view.layoutIfNeeded()
            })
            self.layoutIfNeeded()
        }
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.4) {
            self.alpha = 0
            self.view.layer.removeAllAnimations()
            self.layoutIfNeeded()
        }
    }
}

extension Curtain: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(view)
    }
    func constrainViews() {
        view.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(70)
        }
    }
    func styleViews() {}
}

extension Curtain: RxBinder {
    func bind() {
        loadStatus
            .asObservable()
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

