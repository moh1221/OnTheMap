//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Moh abu on 12/11/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation

extension UdacityClient{
    // Constants
    struct Constants {
        
        // URLs
        static let UdacityBaseURL = "https://www.udacity.com/api/"
        static let UdacitySignupURL = "https://www.udacity.com/account/auth#!/signup"
        
        // Facebook API Key
        static let fbApiKey = "365362206864879"
        
    }
    
    // Methods
    struct Methods {
        
        // Account
        static let Session = "session"
        static let UserData = "users/"
        
    }
    
    // Parameter Keys
    struct ParameterKeys {
        // General
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let Facebook = "facebook_mobile"
        static let AccessToken = "access_token"
        
    }
    
    // JSON Response Keys
    struct JSONResponseKeys {
        
        // General
        static let Session = "session"
        static let ID = "id"
        static let User = "user"
        static let Account = "account"
        static let Key = "key"
        static let first_name = "first_name"
        static let last_name = "last_name"
    }

}