//
//  UIImage+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/12/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIImageView {
    
    class func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .ScaleAspectFit) -> UIImageView? {
        let imageView = UIImageView()
        guard let url = NSURL(string: link) else { return nil}
        imageView.contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) {
                imageView.image = image
            }
            }.resume()
        return imageView
    }}