//
//  Indicator.swift
//  OnTheMap
//
//  Created by Moh abu on 12/31/15.
//  Copyright © 2015 Moh. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    func showIndicator(show: Bool){
        if show {
            self.hidden = false
            self.startAnimating()
        } else {
            self.hidden = true
            self.stopAnimating()
        }
    }
}
