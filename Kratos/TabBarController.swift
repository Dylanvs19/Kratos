//
//  TabBarController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let scrollDelegate = ScrollingTabBarControllerDelegate()
    var firstItemImageView: UIImageView?
    var secondItemImageView: UIImageView?
    var thirdItemImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = scrollDelegate
        
        let secondItemView = self.tabBar.subviews[1]
        self.secondItemImageView = secondItemView.subviews.first as? UIImageView
    }
    
    func configure() {
        let mainVC: MainViewController = MainViewController.instantiate()
        let navMainVC = mainVC.embedInNavVC()
        let yourVotesVC: YourVotesViewController = YourVotesViewController.instantiate()
        let navYourVotesVC = yourVotesVC.embedInNavVC()
        let floorVC: UINavigationController = UIViewController().embedInNavVC()
        setViewControllers([navYourVotesVC, navMainVC, floorVC], animated: true)
        
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
            item.imageInsets = UIEdgeInsetsMake(6, 0, -5, 0)
            item.title = nil
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
            self.secondItemImageView?.transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
                let rotation = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                self.secondItemImageView?.transform = rotation
            }, completion: nil)
    }
}
