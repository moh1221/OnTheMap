//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Moh abu on 12/11/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation
import UIKit


class UdacityClient: NSObject {
    
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    
    /* Authentication state */
    var sessionID : String? = nil
    var uniqueKey: String? = nil
    var userID : Int? = nil
    var First_Name: String?
    var Last_Name: String?
    var objectid: String?
    var updateInfo: Bool = false
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Get Method
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = UdacityClient.Constants.UdacityBaseURL + method
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
 
    // POST
    
    func taskForPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.UdacityBaseURL + method
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            /* Parse the data and use the data (happens in completion handler) */
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var message: String
                if let response = response as? NSHTTPURLResponse {
                    message = "Invalid Email or Password! Status code: \(response.statusCode)!"
                    
                } else if let response = response {
                    message = "Your request returned an invalid response! Response: \(response)!"
                    
                } else {
                    message = "Your request returned an invalid response!"
                }
                
                let userInfo = [NSLocalizedDescriptionKey : NSLocalizedString(message, comment: "")]
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // Delete
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = UdacityClient.Constants.UdacityBaseURL + method
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                completionHandler(result: false, error: error)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helpers

    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
        
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    //Singleton
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
