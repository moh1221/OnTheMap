//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Moh abu on 12/12/15.
//  Copyright © 2015 Moh. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    var logoutBtn = UIBarButtonItem()
    var pinBtn = UIBarButtonItem()
    var reloadBtn = UIBarButtonItem()
    var shared = sharedView.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityInd.hidden = true
        
        // Load Navigation Items
        loadNavigationItems()
        
        // Load Student Location Info
        loadStudentLocations()
    }
    
    func loadStudentLocations(){
        // Remove existing pins
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        if studentLoc.locArray.count > 0 {
            
            self.addPinToMap(studentLoc.locArray)
            
        } else {
            
        self.activityInd.showIndicator(true)
            
        ParseClient.sharedInstance().getStudentInfo() { (success, StudentInfo, errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.addPinToMap(StudentInfo)
                
                    self.activityInd.showIndicator(false)
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let error: String = errorString!.localizedDescription {
                        self.shared.AlertMessage(error, viewControl: self)
                    }
                
                    self.activityInd.showIndicator(false)
                })
            }
            
        }
        }
        
    }
    
    func addPinToMap(studentInfo:[StudentInfo]?) {
        
        var annotations = [MKPointAnnotation]()
        
        if let locations = studentInfo {
            
            for info in locations {
                
                // GEO related items
                let lat = CLLocationDegrees(info.latitude)
                let long = CLLocationDegrees(info.longtitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //User info
                let first = info.firstName
                let last = info.lastName
                let mediaURL = info.mediaURL
                
                //Create our annotation with everything
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL as String
                
                annotations.append(annotation)
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotations(annotations)
            }
            
        } else {
            
            self.shared.AlertMessage("Unable to process student Info", viewControl: self)
        
        }
        
    }
    
    // Update Location button
    func reloadBtnTouchUp(){
        dispatch_async(dispatch_get_main_queue(), {
            // remove the current list
            studentLoc.locArray = []
            
            // Reload new list
            self.loadStudentLocations()
        })
    }
    
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

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            //pinView!.pinColor = .Green
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //Respond to taps
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            
            let app = UIApplication.sharedApplication()
            
            if let mUrl = NSURL(string: annotationView.annotation!.subtitle!!) {
                if app.canOpenURL(mUrl) {
                    app.openURL(mUrl)
                } else {
                    self.shared.AlertMessage("Invalid Link", viewControl: self)
                }
            }
            
        }
    }
}