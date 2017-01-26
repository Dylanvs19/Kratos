//
//  NotificationsRegistrationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class NotificationsRegistrationViewController: UIViewController {

    @IBOutlet weak var registerForNotificationsButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerForNotificationsButtonPressed(_ sender: Any) {
        UIApplication.shared.registerForRemoteNotifications()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
    }
}
