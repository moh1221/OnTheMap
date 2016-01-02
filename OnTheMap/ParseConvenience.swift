//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Moh abu on 12/12/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation

extension ParseClient{
    
    // Getting Student Info
    func getStudentInfo(completionHandler: (success: Bool, studentInfo: [StudentInfo]?, errorString: NSError?) -> Void){
        
        let parameters = [ ParseClient.ParameterKeys.Order : "-updatedAt"]
        
        taskForGETMethod(Methods.StudentLocations, parameters: parameters) {
            JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, studentInfo: nil, errorString: error)
            } else {
                //Convert json
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    let studentInfo = StudentInfo.studentLocationsFromResults(results)
                    studentLoc.locArray = studentInfo
                    completionHandler(success: true, studentInfo: studentInfo, errorString: nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve results"]
                    completionHandler(success: false, studentInfo: nil, errorString: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                }
            }
        }
    }
    
    func queryStudentLocation(completionHandler: (success: Bool, errorString: NSError?) -> Void){
        
        let parameters = [ParameterKeys.Where : "{\"uniqueKey\":\"\(UdacityClient.sharedInstance().uniqueKey!)\"}"]
        
        taskForGETMethod(Methods.StudentLocations, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(success: false,  errorString: error)
            } else {
                
                //Convert json
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    if results.isEmpty {
                        completionHandler(success: false, errorString: nil)
                    } else {
                        let res = results[0]
                        UdacityClient.sharedInstance().objectid = res[ParseClient.JSONResponseKeys.objectId]! as? String
                        completionHandler(success: true, errorString: nil)
                    }
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve results"]
                    completionHandler(success: false, errorString: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                }
            }
        }
    }
    
    func postStudentInfo(userLocation: [String:AnyObject], completionHandler: (success: Bool, errorstring: NSError?) -> Void) {
        taskForPOSTMethod(Methods.StudentLocations, jsonBody: userLocation){ JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorstring: error)
            } else {
                let CheckVal: String?
                if UdacityClient.sharedInstance().updateInfo {
                    CheckVal = ParseClient.JSONResponseKeys.updatedAt
                } else {
                    CheckVal = ParseClient.JSONResponseKeys.objectId
                }
                
                if ((JSONResult.valueForKey(CheckVal!) as? String) != nil) {
                    completionHandler(success: true, errorstring: nil)
                } else {
                    completionHandler(success: false, errorstring: nil)
                }
                
            }
            
        }
        
    }

    
}