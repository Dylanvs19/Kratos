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
    
    //AccountDetailsVC
    case accountDetailsRegisterButtonTitle
    case accountDetailsSaveButtonTitle
    case accountDetailsEditButtonTitle
    case accountDetailsCancelButtonTitle
    case accountDetailsDoneButtonTitle
    case accountDetailsPartyActionSheetTitle
    case accountDetailsPartyActionSheetDescription
    case accountDetailsDemocratButtonTitle
    case accountDetailsDemocratText
    case accountDetailsRepublicanButtonTitle
    case accountDetailsRepublicanText
    case accountDetailsIndependentButtonTitle
    case accountDetailsIndependentText
    
    //KratosTextFields
    case textFieldEmailTitle
    case textFieldPasswordTitle
    case textFieldFirstTitle
    case textFieldLastTitle
    case textFieldBirthdayTitle
    case textFieldPartyTitle
    case textFieldAddressTitle
    case textFieldCityTitle
    case textFieldStateTitle
    case textFieldZipcodeTitle
    
    //ConfirmationVC
    case confirmationTitle
    case confirmationButtonTitle
    case confirmationExplainationText
    
    // ExploreVC
    case exploreTitle
    case exploreSenateButtonTitle
    case exploreHouseButtonTitle
    case exploreExecutiveButtonTitle
    case exploreRecessLabelTitle
    case exploreSenateEmptyLabel
    case exploreHouseEmptyLabel
    case exploreExecutiveEmptyLabel
    
    //UserVC
    case userTitle
    
    //TallyVC
    case tallyVotesTitle
    case tallyDetailsTitle
    
    //SubjectSelectionVC
    case subjectSelectionTitle
    
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

    // MenuVC
    case menuAccountDetailsButtonTitle
    case menuFeedbackButtonTitle
    case menuLogoutButtonTitle
    case menuCloseButtonTitle
    
    //Error
    case errorTitle
    case errorMessage
    
    var string: String {
        switch self {
        //LoginVC
        case .loginLoginButtonTitle: return "L O G I N"
        case .loginContinueButtonTitle: return "C O N T I N U E"
        case .loginSendButtonTitle: return "S E N D"
        case .loginSignUpButtonTitle: return "S I G N  U P"
        case .loginSignInButtonTitle: return "S I G N  I N"
        case .loginForgotPasswordButtonTitle: return "F O R G O T  P A S S W O R D"
            
        //AccountDetailsVC
        case .accountDetailsRegisterButtonTitle: return "R E G I S T E R"
        case .accountDetailsSaveButtonTitle: return "S A V E"
        case .accountDetailsEditButtonTitle: return "E D I T"
        case .accountDetailsCancelButtonTitle: return "C A N C E L"
        case .accountDetailsDoneButtonTitle: return "D O N E"
        case .accountDetailsPartyActionSheetTitle: return "P A R T Y"
        case .accountDetailsPartyActionSheetDescription: return "Choose your party affiliation"
        case .accountDetailsDemocratButtonTitle: return "D E M O C R A T"
        case .accountDetailsDemocratText: return "Democrat"
        case .accountDetailsRepublicanButtonTitle: return "R E P U B L I C A N"
        case .accountDetailsRepublicanText: return "Republican"
        case .accountDetailsIndependentButtonTitle: return "I N D E P E N D E N T"
        case .accountDetailsIndependentText: return "Independent"
        
        //KratosTextFields
        case .textFieldEmailTitle: return "E M A I L"
        case .textFieldPasswordTitle: return "P A S S W O R D"
        case .textFieldFirstTitle: return "F I R S T"
        case .textFieldLastTitle: return "L A S T"
        case .textFieldBirthdayTitle: return "B I R T H D A T E"
        case .textFieldPartyTitle: return "P A R T Y"
        case .textFieldAddressTitle: return "A D D R E S S"
        case .textFieldCityTitle: return "C I T Y"
        case .textFieldStateTitle: return "S T A T E"
        case .textFieldZipcodeTitle: return "Z I P C O D E"
            
        //ConfirmationVC
        case .confirmationTitle: return "Confirmation"
        case .confirmationButtonTitle: return "Link Pressed"
        case .confirmationExplainationText: return "We have just sent an email to your email address you provided to us with a magic link. Once you have activated the link you will be signed in. If you are not automatically signed in after activating the link in the email, press the button below."
            
        //ExploreVC
        case .exploreTitle: return "On The Floor"
        case .exploreSenateButtonTitle: return "SENATE"
        case .exploreHouseButtonTitle: return "HOUSE"
        case .exploreExecutiveButtonTitle: return "EXECUTIVE"
            case .exploreRecessLabelTitle: return "Congress is currently in recess. Check out your representatives' websites for events."
        case .exploreSenateEmptyLabel: return  "The Senate currently has no bills to consider in the upcoming days."
        case .exploreHouseEmptyLabel: return  "The House currently has no bills to consider in the upcoming days."
        case .exploreExecutiveEmptyLabel: return  "There are no bills pending the presidents signature."
            
        //UserVC
        case .userTitle: return "My Bills"
            
        //TallyVC
        case .tallyVotesTitle: return "VOTES"
        case .tallyDetailsTitle: return "DETAILS"
        
        //SubjectSelectionVC
        case .subjectSelectionTitle: return "Select Subjects"
            
        // RepInfoView
        case .repInfoViewBioTitle: return "BIOGRAPHY"
        case .repInfoViewVotesTitle: return "VOTES"
        case .repInfoViewBillsTitle: return "SPONSOR"
        case .repInfoViewTermsSectionTitle: return "Terms"
            
        // BillInfoView
        case .billInfoViewSummaryTitle: return  "SUMMARY"
        case .billInfoViewVotesTitle: return "VOTES"
        case .billInfoViewSponsorsTitle: return "SPONSORS"
        case .billInfoViewDetailsTitle: return "DETAILS"
            
        // MenuVC
        case .menuAccountDetailsButtonTitle: return "Account Details"
        case .menuFeedbackButtonTitle: return "Feedback"
        case .menuLogoutButtonTitle: return "Logout"
        case .menuCloseButtonTitle: return "Close"
            
        //Error
        case .errorTitle: return "Error"
        case .errorMessage: return "Something went wrong on our end. Check back soon."
        }
    }
}

func localize(_ constant: Constant) -> String {
    return constant.string
}
