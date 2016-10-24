//
//  UIImage+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/12/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func downloadedFrom(_ link: String, onCompletion: @escaping (UIImage?)-> (Void)) {
        var image = UIImage()
        guard let url = URL(string: link) else {
            onCompletion(nil)
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let data = data , error == nil,
                let returnImage = UIImage(data: data)
                else {
                    onCompletion(nil)
                    return
            }
            DispatchQueue.main.async {
                image = returnImage
                onCompletion(image)
            }
            }).resume()
        onCompletion(nil)
    }
    
    class func imageForState(_ state: String) -> UIImage? {
        guard let stateName = Constants.statePictureDict[state] else { return nil }
            return UIImage(named: stateName)
    }
}
