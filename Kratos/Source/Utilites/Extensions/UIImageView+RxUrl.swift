//
//  UIImageView+RxUrl.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/28/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AlamofireImage

extension Reactive where Base: UIImageView {
    func setImage(with placeholder: UIImage? = nil) -> UIBindingObserver<Base, URL?> {
        return UIBindingObserver(UIElement: self.base) { imageView, url in
            if let placeholder = placeholder {
                imageView.image = placeholder
            }
            if let url = url {
                imageView.af_setImage(withURL: url,
                                      placeholderImage: placeholder,
                                      filter: nil,
                                      progress: nil,
                                      progressQueue: DispatchQueue.main,
                                      imageTransition: .crossDissolve(0.3),
                                      runImageTransitionIfCached: true,
                                      completion: nil)
            }
        }
    }
}
