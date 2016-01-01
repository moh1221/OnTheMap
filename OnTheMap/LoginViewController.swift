//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Moh abu on 12/10/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginUdacityBtn: UIButton!
    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    var shared = sharedView.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actIndicator.hidden = true
        
        // txt field padding
        txtFieldUI()
        
        // Load FaceBook login Button
        FBLoadBtn()
    }
    
    //Signup to Udacity
    @IBAction func signUpToUdacity(sender: AnyObject) {
        let url = NSURL(string : UdacityClient.Constants.UdacitySignupURL)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    //Login to Udacity
    @IBAction func LoginToUdacity(sender: AnyObject) {
        if emailTextField.text!.isEmpty {
            shared.AlertMessage("Email Empty.", viewControl: self)
        } else if passwordTextField.text!.isEmpty {
            shared.AlertMessage("Password Empty.", viewControl: self)
        } else {
            self.actIndicator.showIndicator(true)
            
            let userAccess = [
                UdacityClient.ParameterKeys.Username : emailTextField.text!,
                UdacityClient.ParameterKeys.Password : passwordTextField.text!
            ]
            
            UdacityClient.sharedInstance().authenticateWithViewController(userAccess, paramKey: UdacityClient.ParameterKeys.Udacity) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let error: String = errorString!.localizedDescription {
                            self.shared.AlertMessage(error, viewControl: self)
                        }
                    })
                }
                self.actIndicator.showIndicator(false)
            }
        }
    }
    
    // LoginViewController
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    // Txt Field padding
    func txtFieldUI(){
        let paddingViewEmail = UIView(frame: CGRectMake(0, 0, 15, self.emailTextField.frame.height))
        emailTextField.leftView = paddingViewEmail
        emailTextField.leftViewMode = UITextFieldViewMode.Always
        
        let paddingViewPass = UIView(frame: CGRectMake(0, 0, 15, self.passwordTextField.frame.height))
        passwordTextField.leftView = paddingViewPass
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    // FaceBook Login
    func FBLoadBtn(){
        fbLoginBtn.delegate = self
        fbLoginBtn.loginBehavior = FBSDKLoginBehavior.Web
        fbLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            if let err: String = error!.localizedDescription {
                self.shared.AlertMessage(err, viewControl: self)
            }
        }
        
        else if result.isCancelled {
            // Handle cancellations
            self.shared.AlertMessage("Facebook login canceled", viewControl: self)
        }
        else {
            
            if let token = result.token.tokenString {
                
                let userFBAccess = [
                    UdacityClient.ParameterKeys.AccessToken : token
                ]
                
                UdacityClient.sharedInstance().authenticateWithViewController(userFBAccess, paramKey: UdacityClient.ParameterKeys.Facebook) { (success, errorString) in
                    if success {
                        self.completeLogin()
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let error: String = errorString!.localizedDescription {
                                self.shared.AlertMessage(error, viewControl: self)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

