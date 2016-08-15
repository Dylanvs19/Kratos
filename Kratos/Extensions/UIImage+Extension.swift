//
//  UIImage+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/12/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func downloadedFrom(link: String, onCompletion: (UIImage?)-> (Void)) {
        var image = UIImage()
        guard let url = NSURL(string: link) else {
            onCompletion(nil)
            return
        }
        NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let data = data where error == nil,
                let returnImage = UIImage(data: data)
                else {
                    onCompletion(nil)
                    return
            }
            dispatch_async(dispatch_get_main_queue()) {
                image = returnImage
                onCompletion(image)
            }
            }.resume()
        onCompletion(nil)
    }
}