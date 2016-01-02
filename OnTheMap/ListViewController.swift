//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Moh abu on 12/13/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var listIndicator: UIActivityIndicatorView!
    
//    var locations = [StudentInfo]()
    var logoutBtn = UIBarButtonItem()
    var pinBtn = UIBarButtonItem()
    var reloadBtn = UIBarButtonItem()
    var shared = sharedView.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide Indicator
        indicatorView.hidden = true
        listIndicator.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load sudent info
        loadStudentList()
        
        // load navigation items        
        loadNavigationItems()
    }
    
    func loadStudentList() {
        
        // Get data from parse
        if studentLoc.locArray.count > 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.studentTableView.reloadData()
            }
            
        } else {
            self.indicatorView.hidden = false
            self.listIndicator.showIndicator(true)
            
            
            ParseClient.sharedInstance().getStudentInfo() { (success, studentInfo, errorString) in
                if success {
                    if (studentInfo != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.studentTableView.reloadData()
                            self.indicatorView.hidden = true
                            self.listIndicator.showIndicator(false)
                        }
                    }  else {
                        
                        self.shared.AlertMessage("Error: Message didn't unwrap", viewControl: self)
                        self.indicatorView.hidden = true
                        self.listIndicator.showIndicator(false)
                        
                    }
                    
                } else {
                    
                    self.shared.AlertMessage("Error: No Results", viewControl: self)
                    self.indicatorView.hidden = true
                    self.listIndicator.showIndicator(false)
                }
                
            }
            
        }
    }
    
    func reloadBtnTouchUp(){
        dispatch_async(dispatch_get_main_queue(), {
            // remove the current list
            studentLoc.locArray = []
            
            // Reload new list
            self.loadStudentList()
        })
        
    }
    
    // Update Location button
    func newLocationTouchUp(){
        
        shared.updateStudentLoc(self)
        
    }
    
    func logoutBtnTouchUp(){
        
        // if fb token then
        shared.fbLogout()
        
        // logout from Udacity
        shared.udacityLogout(self)
        
    }
    
    // Load Items
    func loadNavigationItems(){
        reloadBtn = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadBtnTouchUp")
        pinBtn = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone:UIImage(named: "pin"), style: .Plain, target: self, action: "newLocationTouchUp")
        logoutBtn = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutBtnTouchUp")
        
        self.parentViewController!.navigationItem.rightBarButtonItems = [reloadBtn, pinBtn]
        self.parentViewController!.navigationItem.leftBarButtonItems = [logoutBtn]
        
        self.parentViewController!.navigationItem.hidesBackButton = true
    }

    
}

extension ListViewController:UITableViewDelegate, UITableViewDataSource {
    
    //What is in the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentity = "studentView"
        let location = studentLoc.locArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentity) as UITableViewCell!
        
        //Fill in the cell defaults
        cell.textLabel!.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        
        return cell
    }
    
    //Row selected. What to do
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        if let mUrl = NSURL(string: studentLoc.locArray[indexPath.row].mediaURL) {
            if app.canOpenURL(mUrl) {
                app.openURL(mUrl)
            } else {
                self.shared.AlertMessage("Invalid Link", viewControl: self)
            }
        }
        
    }
    
    //Number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLoc.locArray.count
    }
    
}
