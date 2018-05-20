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
    func setImage(placeholder: UIImage? = nil) -> Binder<String?> {
        return Binder(self.base) { (imageView, string) in
            guard let string = string,
                let url = URL(string: string) else {
                    imageView.image = placeholder
                    return
            }
            
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
