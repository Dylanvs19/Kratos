//
//  UIImage+Color.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIImage {
    
    public static func from(color: UIColor) -> UIImage {
        let pixel = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        pixel.backgroundColor = color
        return pixel.snapshot()
    }
}
