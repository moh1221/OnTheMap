//
//  Student.swift
//  OnTheMap
//
//  Created by Moh abu on 12/15/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation

struct StudentInfo {
    var objectId:String
    var uniqueKey:String
    var firstName:String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longtitude: Double
    var updatedAt: String
    
    
    init(dictionary: [String : AnyObject]) {
        
        objectId = dictionary[ParseClient.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.uniqueKey] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.lastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.mediaURL] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.latitude] as! Double
        longtitude = dictionary[ParseClient.JSONResponseKeys.longitude] as! Double
        updatedAt = dictionary[ParseClient.JSONResponseKeys.updatedAt] as! String
        
    }
    
    static func studentLocationsFromResults(results: [[String:AnyObject]]) -> [StudentInfo] {
        
        var locations = [StudentInfo]()
        
        for result in results {
            
            locations.append(StudentInfo(dictionary: result))
            
        }
        
        return locations
    }
}
