//
//  compassGraphic.swift
//  integratedPrototype
//
//  Created by xclusiveSoft on 6/1/15.
//  Copyright (c) 2015 Xclusive Solutions. All rights reserved.
//

import UIKit
import CoreLocation

class compassGraphic: UIViewController, CLLocationManagerDelegate {
    
    var Heading = 0.0
    var oldHeading = 0.0
    @IBOutlet weak var compArrow: UIImageView!
    let locationManager : CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        oldHeading = Heading
        Heading = newHeading.trueHeading
        Heading += brng
        var diff = Heading - oldHeading
        oldHeading *= M_PI/180
        Heading *= M_PI/180
        var duration = CFTimeInterval(abs(diff * 0.01))
        if diff > 180 {
            duration = CFTimeInterval(abs(diff * 0.005))
        }
        var radToRot = (self.Heading - self.oldHeading)*(-1)
        
        UIView.animateWithDuration(duration, animations: {
            self.compArrow.center = CGPoint(x: 0,y: 0)
            self.compArrow.transform = CGAffineTransformMakeRotation(CGFloat(radToRot))
        })
    }
    
}
