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
    
    class func imageFor(vote: VoteValue) -> UIImage {
        switch vote {
        case .yea:
            return #imageLiteral(resourceName: "Yes")
        case .nay:
            return #imageLiteral(resourceName: "No")
        case .abstain:
            return #imageLiteral(resourceName: "Abstain")
        }
    }
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
