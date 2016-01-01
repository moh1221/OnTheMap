//
//  sharedView.swift
//  OnTheMap
//
//  Created by Moh abu on 12/31/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class sharedView: NSObject {
    
    // New Update Location
    func updateStudentLoc(viewControl: AnyObject){
        ParseClient.sharedInstance().queryStudentLocation() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.overwriteAlert(viewControl)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentInfoPostingView(viewControl)
                })
            }
        }
    }
    
    // Alert message
    func AlertMessage(message: String, viewControl: AnyObject){
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(dismissAction)
        viewControl.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func overwriteAlert(viewControl: AnyObject){
        let msg = "User \"\(UdacityClient.sharedInstance().First_Name!) \(UdacityClient.sharedInstance().Last_Name!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { alert -> Void in
            UdacityClient.sharedInstance().updateInfo = true
            self.presentInfoPostingView(viewControl)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        viewControl.navigationController!!.presentViewController(alert, animated: true,completion:nil)
    }
    
    func presentInfoPostingView(viewControl: AnyObject){
        dispatch_async(dispatch_get_main_queue(), {
            let controller = viewControl.storyboard!!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            viewControl.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    
    // Logout
    func fbLogout(){
        if(FBSDKAccessToken.currentAccessToken() != nil){
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
        }
    }
    
    func udacityLogout(viewControl: AnyObject){
        UdacityClient.sharedInstance().logoutUdacity() { (success, errorString) in
            if success {
                self.completeLogout(viewControl)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let error: String = errorString!.localizedDescription {
                        self.AlertMessage(error, viewControl: viewControl)
                    }
                })
            }
        }
    }
    
    func completeLogout(viewControl: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            viewControl.navigationController?!.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    class func sharedInstance() -> sharedView {
        
        struct Singleton {
            static var sharedInstance = sharedView()
        }
        
        return Singleton.sharedInstance
    }
}
