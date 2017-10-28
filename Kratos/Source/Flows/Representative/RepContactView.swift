//
//  RepContactView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/1/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    
    struct Contact {
        let method: ContactMethod
        let value: String
    }
    
    enum ContactMethod: Int {
        case phone = 0
        case website = 1
        case twitter = 2
        case office = 3
        
        var image: UIImage {
            switch self {
            case .phone: return #imageLiteral(resourceName: "phoneIcon")
            case .website: return #imageLiteral(resourceName: "websiteIcon")
            case .twitter: return #imageLiteral(resourceName: "twitterIcon")
            case .office: return #imageLiteral(resourceName: "emailIcon")
            }
        }
        
        var title: String {
            switch self {
            case .phone: return "phone"
            case .website: return "website"
            case .twitter: return "twitter"
            case .office: return "office"
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.tag = self.rawValue
            button.addTarget(self, action: #selector(handleButtonPress(button:)), for: .touchUpInside)
            return button
        }
    }

    let stackView = UIStackView()
    let disposeBag = DisposeBag()
    
    var contactMethods = Variable<[Contact]>([])
    let selectedMethod = PublishSubject<Contact>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with contactMethods: [Contact]) {
        stackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        contactMethods.forEach { stackView.addArrangedSubview($0.method.button) }
    }
    
    func handleButtonPress(button: UIButton) {
        if let method = ContactMethod(rawValue: button.tag),
           let selectedMethod = contactMethods.value.filter({ $0.method == method }).first {
                self.selectedMethod.onNext(selectedMethod)
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

extension RepContactView: RxBinder {
    func bind() {
        contactMethods
            .asObservable()
            .subscribe(
                onNext: { [weak self] methods in
                    self?.update(with: methods)
                }
            )
            .disposed(by: disposeBag)
    }
}
