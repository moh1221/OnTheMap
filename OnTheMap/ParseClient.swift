//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Moh abu on 12/12/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    // Properties
    
    /* Shared session */
    var session: NSURLSession
    
    // Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    func taskForGETMethod(method: String, parameters: [String: AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        /* Build the URL and configure the request */
        var urlString:String
        
        if let mutableParameters = parameters {
            urlString = Constants.BaseURL + method + ParseClient.escapedParameters(mutableParameters)
        } else {
            urlString = Constants.BaseURL + method
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject] {
                    
                    //Check network error.
                    if let status = parsedResult[ParseClient.JSONResponseKeys.Error] as? String  {
                        let userInfo = [NSLocalizedDescriptionKey : status]
                        completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                    } else {
                        completionHandler(result: parsedResult, error: nil)
                    }
                }
            }
        }
        /* Start the request */
        task.resume()
        return task
    }

    
    // MARK: POST
    func taskForPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var urlString = Constants.BaseURL + method
        
        let httpMethod: String?
        
        if UdacityClient.sharedInstance().updateInfo {
            httpMethod = "PUT"
            urlString = urlString + "/\(UdacityClient.sharedInstance().objectid!)"
        } else {
            httpMethod = "POST"
        }
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = httpMethod!
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ParseClient.Constants.Application_id, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.api_key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: response , error: error)
                return
            }
            
            //Serial data
            if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String: AnyObject] {
                //Check status
                if var status: Int = parsedResult["status"] as? Int  {
                    completionHandler(result: parsedResult, error: downloadError)
                } else {
                    completionHandler(result: parsedResult, error: nil)
                    
                }
            }
        }
        
        /* Start the request */
        task.resume()
        return task
    }
    
    // Helpers
    
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
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }

}