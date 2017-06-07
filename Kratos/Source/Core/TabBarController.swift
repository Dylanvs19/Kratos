//
//  TabBarController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    let scrollDelegate = ScrollingTabBarControllerDelegate()
    var firstItemImageView: UIImageView?
    var secondItemImageView: UIImageView?
    var thirdItemImageView: UIImageView?
    
    init(client: Client) {
        super.init(nibName: nil, bundle: nil)
        configure(with: client)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = scrollDelegate
        
    }
    
    func configure(with client: Client) {
        let navUserRepsVC = UserRepsViewController(client: client).embedInNavVC()
//        let navUserRepsVC = UserRepsViewController(client: client).embedInNavVC()
//        let navUserRepsVC = UserRepsViewController(client: client).embedInNavVC()
        setViewControllers([navUserRepsVC, navUserRepsVC, navUserRepsVC], animated: true)
        
        for (idx, item) in tabBar.items!.enumerated() where tabBar.items != nil {
            switch idx {
            case 0:
                item.image = #imageLiteral(resourceName: "accountIcon").withRenderingMode(.alwaysOriginal)
            case 1:
                item.image = #imageLiteral(resourceName: "kratosIcon").withRenderingMode(.alwaysOriginal)
            case 2:
                item.image = #imageLiteral(resourceName: "floorIcon").withRenderingMode(.alwaysOriginal)
            default:
                break
            }
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            item.title = nil
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items else { return }
        var imageView: UIImageView?
        for (i, tabItem) in items.enumerated() where item == tabItem {
            imageView = tabBar.subviews[i + 1].subviews.first as? UIImageView
        }

        guard let tabImageView = imageView else { return }
        tabImageView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: { () -> Void in
            tabImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: { () -> Void in
            tabImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        }, completion: nil)
    }
}
