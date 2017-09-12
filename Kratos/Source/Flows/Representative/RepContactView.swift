//
//  RepContactView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

func ==(lhs: RepContactView.ContactMethod, rhs: RepContactView.ContactMethod) -> Bool {
    switch (lhs, rhs) {
    case (.phone, .phone),
         (.twitter, .twitter),
         (.office, .office),
         (.website, .website):
        return true
    default:
        return false
    }
}

class RepContactView: UIView {
    
    enum ContactMethod {
        case phone(String)
        case website(String)
        case twitter(String)
        case office(String)
        
        var image: UIImage {
            switch self {
            case .phone:
                return #imageLiteral(resourceName: "phoneIcon")
            case .website:
                return #imageLiteral(resourceName: "websiteIcon")
            case .twitter:
                return #imageLiteral(resourceName: "twitterIcon")
            case .office:
                return #imageLiteral(resourceName: "emailIcon")
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            return button
        }
    }

    let stackView = UIStackView()
    let disposeBag = DisposeBag()
    
    let selectedMethod = PublishSubject<ContactMethod>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with contactMethods: [ContactMethod]) {
        stackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        contactMethods.forEach { method in
            method.button.rx.controlEvent([.touchUpInside])
                .asObservable()
                .map { _ in method }
                .bind(to: selectedMethod)
                .disposed(by: self.disposeBag)
            stackView.addArrangedSubview(method.button)
        }
    }
}

extension RepContactView: ViewBuilder {
    func addSubviews() {
        addSubview(stackView)
    }
    
    func constrainViews() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func styleViews() {
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
    }
}

extension Reactive where Base: RepContactView {
    var contactMethods: UIBindingObserver<Base, [RepContactView.ContactMethod]> {
        return UIBindingObserver(UIElement: self.base, binding: {(view, contactMethods) in
            view.update(with: contactMethods)
        })
    }
}
