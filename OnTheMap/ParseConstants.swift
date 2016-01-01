//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Moh abu on 12/12/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation

extension ParseClient{
    // Constants
    struct Constants {
        
        // URL
        static let BaseURL = "https://api.parse.com/1/classes/"
        
        static let Application_id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let api_key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    }
    
    // Methods
    struct Methods {
        
        // Parse
        static let StudentLocations = "StudentLocation"
        
    }
    
    // Parameter Keys
    struct ParameterKeys {
        // General
        static let Where = "where"
        static let Order = "order"
        
    }
    
    // JSON Response Keys
    struct JSONResponseKeys {
        
        // Parse
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let Results: String = "results"
        static let Error: String = "error"
    }
    
}