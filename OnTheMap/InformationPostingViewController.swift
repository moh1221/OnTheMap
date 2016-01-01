//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Moh abu on 12/13/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    var address: String!
    var lat: Double!
    var long: Double!
    var shared = sharedView.sharedInstance()
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var InfoTextLable: UILabel!
    @IBOutlet weak var urlLinkTextView: UITextView!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var findOnMapBtn: UIButton!
    @IBOutlet weak var MapView: UIView!
    @IBOutlet weak var userLocationView: MKMapView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        urlLinkTextView.delegate = self
        actIndicator.hidden = true
        
        // Background and color
        loadTxtUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Add tap recognizer to dismiss keyboard */
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    // Keyboard Fixes
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Cancel button
    @IBAction func cancelBtnTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Find location
    @IBAction func FindUserLocation(sender: AnyObject) {
        
        if locationTextView.hasText() && locationTextView.text != "Enter Your Location Here" {
            findOnMap()
        } else {
            shared.AlertMessage("Must Enter a Location", viewControl: self)
        }
    
    }
    
    // Submit request
    @IBAction func submitUserLocation(sender: AnyObject) {
        
        if urlLinkTextView.hasText() && urlLinkTextView.text != "Enter a Link to Share Here" {
            
            let userLocation: [String:AnyObject] = [
                ParseClient.JSONResponseKeys.uniqueKey : UdacityClient.sharedInstance().uniqueKey!,
                ParseClient.JSONResponseKeys.firstName : UdacityClient.sharedInstance().First_Name!,
                ParseClient.JSONResponseKeys.lastName : UdacityClient.sharedInstance().Last_Name!,
                ParseClient.JSONResponseKeys.mapString : self.address,
                ParseClient.JSONResponseKeys.mediaURL : urlLinkTextView.text!,
                ParseClient.JSONResponseKeys.latitude : self.lat,
                ParseClient.JSONResponseKeys.longitude : self.long
            ]
            
            ParseClient.sharedInstance().postStudentInfo(userLocation) {
                (success, errorString) in
                
                if success {
                    ParseClient.sharedInstance().studentInfo = nil
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    
                    self.shared.AlertMessage("Unable to post location", viewControl: self)
                }
            }
        } else {
            
            self.shared.AlertMessage("Must Enter a Link", viewControl: self)
        }
    }
    
    func loadTxtUI(){
        
        TopView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        findOnMapBtn.layer.cornerRadius = 8
        submitBtn.layer.cornerRadius = 8
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
}

extension InformationPostingViewController: MKMapViewDelegate {
    
    func findOnMap(){
        // Start Indicator
        self.actIndicator.showIndicator(true)
        
        //Initialize geocoder
        let geocoder = CLGeocoder()
        address = locationTextView.text
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if let placemark = placemarks![0] as CLPlacemark?{
                
                self.lat = CLLocationDegrees(placemark.location!.coordinate.latitude)
                self.long = CLLocationDegrees(placemark.location!.coordinate.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                //Set a region
                let span = MKCoordinateSpanMake(0.0025, 0.0025)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.lat, longitude: self.long), span: span)
                self.userLocationView.setRegion(region, animated: true)
                
                // Disable Zoom, scroll and user interaction.
                self.userLocationView.zoomEnabled = false
                self.userLocationView.scrollEnabled = false
                self.userLocationView.userInteractionEnabled = false
                
                //Add pin
                self.userLocationView.addAnnotation(annotation)
                
                
                self.locationTextView.hidden = true
                self.InfoTextLable.hidden = true
                self.findOnMapBtn.hidden = true
                self.urlLinkTextView.hidden = false
                self.BottomView.alpha = 0.8
                self.TopView.backgroundColor = UIColor(red: 0.409277, green: 0.639619, blue: 0.944372, alpha:1.0)
                self.cancelBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                
                
                // Stop Indicator
                self.actIndicator.showIndicator(false)
                
            } else {
                self.shared.AlertMessage("Unable to find Address", viewControl: self)
                // Stop Indicator
                self.actIndicator.showIndicator(false)
            }
            
        })
    }
    
}

extension InformationPostingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Clear Location text view
        if textView.text == "Enter Your Location Here"{
            locationTextView.text = ""
            locationTextView.textAlignment = .Left
        }
        
        // Clear url text view
        if textView.text == "Enter a Link to Share Here"{
            urlLinkTextView.text = ""
            urlLinkTextView.textAlignment = .Left
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        // Center and validate location text
        locationTextView.textAlignment = .Center
        if locationTextView.text == "" {
            locationTextView.text = "Enter Your Location Here"
        }
        
        // Center and validate url text
        urlLinkTextView.textAlignment = .Center
        if urlLinkTextView.text == "" {
            urlLinkTextView.text = "Enter a Link to Share Here"
        }
    }
    
}