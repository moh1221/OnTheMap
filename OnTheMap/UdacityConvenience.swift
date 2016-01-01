//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Moh abu on 12/11/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient{
    
    //Authentication
    func authenticateWithViewController(userAccess: [String: AnyObject], paramKey: String!, completionHandler: (success: Bool, errorString: NSError?) -> Void) {
        
        self.getSession(userAccess, paramKey: paramKey) { (success, result, error) in
            
            if success {
                self.getUserInfo() { success, errorString in
                    if success{
                        completionHandler(success: true, errorString: error)
                    } else {
                        completionHandler(success: false, errorString: error)
                    }
                }
            } else {
                completionHandler(success: success, errorString: error)
            }
        }
    
    }
    
    // get session Info
    func getSession(userAccess: [String: AnyObject], paramKey: String!, completionHandler: (success: Bool, result: AnyObject!, errorString: NSError?) -> Void) {
        
        let jsonBody = [ paramKey: userAccess ]
        let mutableMethod : String = Methods.Session
        /* Make the request */
        taskForPOSTMethod(mutableMethod, jsonBody: jsonBody) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, result: nil, errorString: error)
            } else {
                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.ID) as? String {
                    self.sessionID = results
                    if let key = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account)?.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String{
                        self.uniqueKey = key
                    }
                    completionHandler(success: true, result: results, errorString: nil)
                } else {
                    completionHandler(success: false, result: nil, errorString: error)
                }
            }
        }
        
    }
    
    func getUserInfo(completionHandler: (success: Bool, errorString: NSError?) -> Void) {
        /* Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters:[String:AnyObject] = [String:AnyObject]()
        let method = Methods.UserData + self.uniqueKey!
        /* Make the request */
        taskForGETMethod(method, parameters: parameters) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, errorString: error)
            } else {
                if let lastname = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User)?.valueForKey(UdacityClient.JSONResponseKeys.last_name) as? String {
                    self.Last_Name = lastname
                    if let firstname = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User)?.valueForKey(UdacityClient.JSONResponseKeys.first_name) as? String {
                            self.First_Name = firstname
                    }
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: nil)
                }
            }
        }

    }
    
    
    func logoutUdacity(completionHandler: (success: Bool, errorString: NSError?) -> Void) {
        
        taskForDELETEMethod(Methods.Session){ JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorString: error)
                
            } else {
                UdacityClient.sharedInstance().First_Name = nil
                UdacityClient.sharedInstance().Last_Name = nil
                UdacityClient.sharedInstance().uniqueKey = nil
                completionHandler(success: true, errorString: nil)
                
            }
            
        }
        
    }
}
