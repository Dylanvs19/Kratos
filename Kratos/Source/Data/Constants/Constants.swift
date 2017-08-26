//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum Constant {
    
    //LoginVC
    case loginLoginButtonTitle
    case loginContinueButtonTitle
    case loginSendButtonTitle
    case loginSignUpButtonTitle
    case loginSignInButtonTitle
    case loginForgotPasswordButtonTitle
    
    //ConfirmationVC
    case confirmationTitle
    case confirmationButtonTitle
    case confirmationExplainationText
    
    // ExploreVC
    case exploreTitle
    case exploreSenateButtonTitle
    case exploreHouseButtonTitle
    case exploreRecessLabelTitle
    
    //InfoView
    case infoViewVotesTitle
    
    // RepInfoView
    case repInfoViewBioTitle
    case repInfoViewVotesTitle
    case repInfoViewBillsTitle
    case repInfoViewTermsSectionTitle
    
    // BillInfoView
    case billInfoViewSummaryTitle
    case billInfoViewVotesTitle
    case billInfoViewSponsorsTitle
    case billInfoViewDetailsTitle
    
    // ExpandableTextFieldView
    case expandableTextFieldViewExpandedButtonTitle
    case expandableTextFieldViewContractedButtonTitle
    
    // MenuVC
    case menuAccountDetailsButtonTitle
    case menuFeedbackButtonTitle
    case menuLogoutButtonTitle
    case menuCloseButtonTitle
    
    var string: String {
        switch self {
        //LoginVC
        case .loginLoginButtonTitle: return "L O G I N"
        case .loginContinueButtonTitle: return "C O N T I N U E"
        case .loginSendButtonTitle: return "S E N D"
        case .loginSignUpButtonTitle: return "S I G N  U P"
        case .loginSignInButtonTitle: return "S I G N  I N"
        case .loginForgotPasswordButtonTitle: return "F O R G O T  P A S S W O R D"
            
        //ConfirmationVC
        case .confirmationTitle: return "Confirmation"
        case .confirmationButtonTitle: return "Link Pressed"
        case .confirmationExplainationText: return "We have just sent an email to your email address you provided to us with a magic link. Once you have activated the link you will be signed in. If you are not automatically signed in after activating the link in the email, press the button below."
            
        //ExploreVC
        case .exploreTitle: return  "On The Floor"
        case .exploreSenateButtonTitle: return "Senate"
        case .exploreHouseButtonTitle: return "House"
        case .exploreRecessLabelTitle: return "Congress is currently in recess. Check out your representatives' websites for events."
            
        //InfoView
        case .infoViewVotesTitle: return "Votes"
            
        // RepInfoView
        case .repInfoViewBioTitle: return "Biography"
        case .repInfoViewVotesTitle: return "Votes"
        case .repInfoViewBillsTitle: return "Sponsored Bills"
        case .repInfoViewTermsSectionTitle: return "Terms"
            
        // BillInfoView
        case .billInfoViewSummaryTitle: return  "Summary"
        case .billInfoViewVotesTitle: return "Votes"
        case .billInfoViewSponsorsTitle: return "Sponsors"
        case .billInfoViewDetailsTitle: return "Details"
            
        // ExpandableTextFieldView
        case .expandableTextFieldViewExpandedButtonTitle: return "Show Less"
        case .expandableTextFieldViewContractedButtonTitle: return "Show More"
            
        // MenuVC
        case .menuAccountDetailsButtonTitle: return "Account Details"
        case .menuFeedbackButtonTitle: return "Feedback"
        case .menuLogoutButtonTitle: return "Logout"
        case .menuCloseButtonTitle: return "Close"
            
        }
    }
}

func localize(_ constant: Constant) -> String {
    return constant.string
}
