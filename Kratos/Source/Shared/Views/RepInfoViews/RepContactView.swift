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

struct ContactMethod {
    
    var contactType: ContactType
    var associatedValue: String
    var variable: PublishSubject<String>
    
    enum ContactType {
        case phone
        case website
        case twitter
        case office
        
        var image: UIImage {
            switch self {
            case .phone:
                return #imageLiteral(resourceName: "PhoneLogo")
            case .website:
                return #imageLiteral(resourceName: "WebsiteLogo")
            case .twitter:
                return #imageLiteral(resourceName: "TwitterLogo")
            case .office:
                return #imageLiteral(resourceName: "CongressContactLogo")
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            return button
        }
    }
}

func ==(lhs: ContactMethod, rhs: ContactMethod) -> Bool {
    switch (lhs.contactType, rhs.contactType) {
    case (.phone, .phone), (.twitter, .twitter), (.office, .office), (.website, .website):
        return true
    default:
        return false
    }
}

class RepContactView: UIView {

    let stackView = UIStackView()
    let disposeBag = DisposeBag()

    var contactMethods = [ContactMethod]() {
        didSet {
            fillStackView(with: contactMethods)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        constrainViews()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(contactMethods: [ContactMethod]) {
        self.contactMethods = contactMethods
    }
    
    func fillStackView(with contactMethods: [ContactMethod]) {
        contactMethods.forEach { method in
            let button = method.contactType.button
            stackView.addArrangedSubview(button)
            button.rx.controlEvent([.touchUpInside]).asObservable()
                .map { method.associatedValue }
                .bind(to: method.variable)
                .disposed(by: self.disposeBag)
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
    
    func style() {
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
    }
}
