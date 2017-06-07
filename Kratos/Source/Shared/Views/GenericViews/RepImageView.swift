//
//  RepImageView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RepImageView: UIImageView {
    
    var loadStatus = Variable<LoadStatus>(.none)
    var disposeBag = DisposeBag()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.addRepImageViewBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadRepImage(from url: String?, chamber: Chamber?, with client: Client) {
        if let url = url {
        loadStatus.value = .loading
        client.fetchImage(for: url)
            .do(onNext: { [weak self] _ in
                self?.loadStatus.value = .none
            }, onError: { [weak self] _ in
                self?.loadStatus.value = .error(error: KratosError.serverSideError(error: nil))
            })
        .bind(to: rx.image)
        .disposed(by: disposeBag)
        } else {
            loadStatus.value = .none
            image = chamber?.toImage() ?? #imageLiteral(resourceName: "CongressLogo")
        }
    }
}

extension Reactive where Base: RepImageView {
    func path(with client: Client) -> UIBindingObserver<Base, (Chamber?, String?)> {
        return UIBindingObserver(UIElement: base, binding: { (imageView, imageDetails) in
            let (chamber, url) = imageDetails
            imageView.loadRepImage(from: url, chamber: chamber, with: client)
        })
    }
}


