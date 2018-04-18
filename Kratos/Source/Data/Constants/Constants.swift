//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    case accountDetailsAddressExplanationText
    
    //KratosTextFields
    case textFieldEmailTitle
    case textFieldEmailTitleInvalid
    case textFieldPasswordTitle
    case textFieldPasswordTitleInvalid
    case textFieldFirstTitle
    case textFieldFirstTitleInvalid
    case textFieldLastTitle
    case textFieldLastTitleInvalid
    case textFieldBirthdayTitle
    case textFieldBirthdayTitleInvalid
    case textFieldPartyTitle
    case textFieldPartyTitleInvalid
    case textFieldAddressTitle
    case textFieldAddressTitleInvalid
    case textFieldCityTitle
    case textFieldCityTitleInvalid
    case textFieldStateTitle
    case textFieldStateTitleInvalid
    case textFieldZipcodeTitle
    case textFieldZipcodeTitleInvalid
    case textFieldConfirmationTitle
    case textFieldConfirmationTitleInvalid
    case textFieldSearchTitle
    
    //ConfirmationVC
    case confirmationTitle
    case confirmationResendConfirmationButtonTitle
    case confirmationExplainationText
    case confirmationSubmitButtonTitle
    
    // NotificatinVC
    case notificationTitle
    case notificationSkipButtonTitle
    case notificationExplanationText
    case notificationRegisterButtonTitle
    
    // ExploreVC
    case exploreTitle
    case exploreSenateButtonTitle
    case exploreHouseButtonTitle
    case exploreTrendingButtonTitle
    case exploreRecessLabelTitle
    case exploreSenateEmptyLabel
    case exploreHouseEmptyLabel
    case exploreTrendingEmptyLabel
    
    //UserVC
    case userTitle
    case userBillsSubjectEmptyStateMessage
    case userBillsNoSubjectSelectedEmptyStateMessage
    case userBillsNoTrackedSubjectsOrBillsEmptyStateMessage
    
    // User Rep VC
    case districtSelectionSubmitButtonTitle
    case districtSelectionReturnHomeButtonTitle
    case districtSelectionSearchInfoLabel
    case districtSelectionTitle
    
    //BillVC
    case billTrackButtonTrackedTitle
    case billTrackButtonUntrackedTitle
    
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
    case billInfoViewVotesEmptyTitle
    case billInfoViewEmptyVotes

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
        case .loginContinueButtonTitle: return "C R E A T E"
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
        case .accountDetailsAddressExplanationText: return "Your address is used to locate your congressional district."
            
        //KratosTextFields
        case .textFieldEmailTitle: return "E M A I L"
        case .textFieldEmailTitleInvalid: return "Please enter a valid email address."
        case .textFieldPasswordTitle: return "P A S S W O R D"
        case .textFieldPasswordTitleInvalid: return "Your password must be longer than 6 characters."
        case .textFieldFirstTitle: return "F I R S T"
        case .textFieldFirstTitleInvalid: return "Your first name must be longer than 3 characters."
        case .textFieldLastTitle: return "L A S T"
        case .textFieldLastTitleInvalid: return"Your last name must be longer than 3 characters."
        case .textFieldBirthdayTitle: return "B I R T H D A T E"
        case .textFieldBirthdayTitleInvalid: return "B I R T H D A T E"
        case .textFieldPartyTitle: return "P A R T Y"
        case .textFieldPartyTitleInvalid: return "P A R T Y"
        case .textFieldAddressTitle: return "A D D R E S S"
        case .textFieldAddressTitleInvalid: return "Please enter a valid street address."
        case .textFieldCityTitle: return "C I T Y"
        case .textFieldCityTitleInvalid: return "Please enter a valid city name."
        case .textFieldStateTitle: return "S T A T E"
        case .textFieldStateTitleInvalid: return "Please enter a valid state."
        case .textFieldZipcodeTitle: return "Z I P C O D E"
        case .textFieldZipcodeTitleInvalid: return "Please enter a valid zip code"
        case .textFieldConfirmationTitle: return "C O N F I R M A T I O N"
        case .textFieldConfirmationTitleInvalid: return "Please enter a valid confirmation number."
        case .textFieldSearchTitle: return "S E A R C H"
            
        //ConfirmationVC
        case .confirmationTitle: return "Confirmation"
        case .confirmationResendConfirmationButtonTitle: return "RESEND CONFIRMATION"
        case .confirmationExplainationText: return "A confirmation code has just been sent to your email address. Enter it here:"
        case .confirmationSubmitButtonTitle: return "S U B M I T"
            
        // NotificationVC
        case .notificationTitle: return "Notifications"
        case .notificationSkipButtonTitle: return "S K I P"
        case .notificationExplanationText: return "We use notifications to inform you when your representatives are voting on things that you care about. We do not spam you with news about every breath they take, we focus on the important stuff."
        case .notificationRegisterButtonTitle: return "R E G I S T E R"
            
        //ExploreVC
        case .exploreTitle: return "On The Floor"
        case .exploreSenateButtonTitle: return "SENATE"
        case .exploreHouseButtonTitle: return "HOUSE"
        case .exploreTrendingButtonTitle: return "TRENDING"
        case .exploreRecessLabelTitle: return "Congress is currently in recess. Check out your representatives' websites for events."
        case .exploreSenateEmptyLabel: return  "The Senate currently has no bills to consider in the upcoming days."
        case .exploreHouseEmptyLabel: return  "The House currently has no bills to consider in the upcoming days."
        case .exploreTrendingEmptyLabel: return  "There are no bills trending in Congress."
            
        //UserVC
        case .userTitle: return "My Bills"
        case .userBillsSubjectEmptyStateMessage: return "There are no bills whose top term is this subject."
        case .userBillsNoSubjectSelectedEmptyStateMessage: return "Select a subject."
        case .userBillsNoTrackedSubjectsOrBillsEmptyStateMessage: return "You have no tracked bills or tracked subjects."
            
        // User Rep VC
        case .districtSelectionSubmitButtonTitle: return "S U B M I T"
        case .districtSelectionReturnHomeButtonTitle: return "Return Home"
        case .districtSelectionSearchInfoLabel: return "Enter an address and sumbit to see another congressional district."
        case .districtSelectionTitle: return "District Selection"
        
        //BillVC
        case .billTrackButtonTrackedTitle: return "TRACKING"
        case .billTrackButtonUntrackedTitle: return "TRACK"
            
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
        case .billInfoViewVotesEmptyTitle: return "There have been no votes for this bill."
        case .billInfoViewEmptyVotes: return "There have been no votes on this bill."
            
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
