//
//  FirebaseAnalyicAction.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import Firebase

enum FirebaseAnalytics {
    
    case signUp // kFIREventSignUp
    case login //kFIREventLogin
    case selectedContent(content: String, id: Int?) //kFIREventSelectContent
    case viewItem(id: Int, name: String?, category: String?) //kFIREventViewItem
    
    func fireEvent() {
        switch self {
        case .signUp:
            FIRAnalytics.logEvent(withName: kFIREventSignUp, parameters: nil)
        case .login:
            FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
        case .selectedContent(let content, let id):
            var params = [kFIRParameterContentType: content as NSObject]
            if let id = id {
                params[kFIRParameterItemID] = String(id) as NSObject
            }
            FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: params)
        case .viewItem(let id, let name, let category):
            var params = [kFIRParameterContentType: String(id) as NSObject]
            if let name = name {
                params[kFIRParameterItemName] = name as NSObject
            }
            if let category = category {
                params[kFIRParameterItemCategory] = category as NSObject
            }
            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: params)
        }
    }
}

enum ModelType: String {
    case person
    case tally
    case bill
    case userVote
}

enum ModelViewType: String{
    case accountDetails
    case yourVotes
    case feedback
    case repListView
    case committeeView
    case actionsView
    case repInfoView
    case leadSponsor
    case coSponsor
    case billText
    case summary
    case userVoteView
}

enum ActionType: String {
    case submitTapped
    case loginTapped
    case forgotPasswordTapped
}
