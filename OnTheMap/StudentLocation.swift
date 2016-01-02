//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Moh abu on 1/2/16.
//  Copyright © 2016 Moh. All rights reserved.
//

import Foundation
import UIKit

struct URLUtils {
    // Opens a URL in the browser
    static func openURL(string urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
            return true
        } else {
            return false
        }
    }
}

class StudentLocation: NSObject{
    var locArray = [StudentInfo]()
}

var studentLoc = StudentLocation()