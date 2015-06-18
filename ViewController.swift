//
//  ViewController.swift
//  NamazTime
//
//  Created by cArnn on 4/24/15.
//  Copyright (c) 2015 cArnn. All rights reserved.
//

import UIKit
import CoreLocation
var brng: Double = 0.0
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var longL: UILabel!
    @IBOutlet weak var latL: UILabel!
    @IBOutlet weak var timeZL: UILabel!
    @IBOutlet weak var fajrL: UILabel!
    @IBOutlet weak var sunRL: UILabel!
    @IBOutlet weak var zuhrL: UILabel!
    @IBOutlet weak var asrL: UILabel!
    @IBOutlet weak var sunSL: UILabel!
    @IBOutlet weak var maghribL: UILabel!
    @IBOutlet weak var ishaL: UILabel!
    @IBOutlet weak var calcML: UILabel!
    @IBOutlet weak var qiblaSL: UILabel!
    @IBOutlet weak var qiblaSTL: UILabel!
    @IBOutlet weak var magHead: UILabel!
    @IBOutlet weak var trueHead: UILabel!
    @IBOutlet weak var headAcc: UILabel!
    
    let date = NSDate()
    let locationManager : CLLocationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var timeZone : Double = 0.0
    let π = M_PI
    var pTimes : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    func updateLabels( var lat : Double, var  long : Double , var  timeZ : Double){
        let days: NSCalendarUnit = NSCalendarUnit.CalendarUnitDay
        let dayComponents = NSCalendar.currentCalendar().components(days, fromDate: date)
        let months: NSCalendarUnit = NSCalendarUnit.CalendarUnitMonth
        let monthComponents = NSCalendar.currentCalendar().components(months, fromDate: date)
        let years: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear
        let yearComponents = NSCalendar.currentCalendar().components(years, fromDate: date)
        
        let year = Int32(yearComponents.year)
        let month = Int32(monthComponents.month)
        let day = Int32(dayComponents.day)
        
        var p = PrayTime()
        
        p.setCalcMethod(Int32(p.Jafari))
        pTimes = p.getDatePrayerTimes(year, andMonth: month, andDay: day, andLatitude: lat, andLongitude: long, andtimeZone: timeZ)
        
        var calcM = p.getCalcMethod()
        var calcMS = ""
        switch(Int(calcM)){
        case p.Jafari:
            calcMS = "Shia Ithna Asheri"
        case p.ISNA:
            calcMS = "Islamic Society of North America"
        case p.Makkah:
            calcMS = "Umm al Qura Uni, Makkah"
        case p.Tehran:
            calcMS = "Institute of Geophysics, Tehran"
        case p.Karachi:
            calcMS = "University of Karachi"
        case p.Egypt:
            calcMS = "Egyptian General Authority of Survey"
        case p.MWL:
            calcMS = "Muslim World League"
        default:
            calcMS = ""
        }
        // using simple bearing calculation method
        
        let π = M_PI
        var latM : Double = 21.4225
        latM *= π/180
        lat *= π/180
        var lonDelta: Double = 0.0
        var x: Double = 0.0
        var lonM : Double = 39.8262
        lonM *= π/180
        long *= π/180
        var y: Double = 0.0
        lonDelta = (lonM - long);
        y = sin(lonDelta) * cos(latM);
        x = cos(lat) * sin(latM) - sin(lat) * cos(latM) * cos(lonDelta);
        brng = atan2(y, x)
        brng *= 180/π
        if(brng < 0){
            brng += 360
        }
        
        // using spherical trignometry method
        var dist: double_t = 0.0
        var distOppAngle = lonM - long
        
        
        // According to cosine law
        var cosDist = ( sin(lat) * sin(latM) ) + ( cos(distOppAngle) * cos(latM) * cos(lat) )
        var distAngle = acos( cosDist )
        
        // now calculating qiblah direction
        // using sin rule
        
        var sinQiblah = sin(distOppAngle) * cos(latM) / sin(distAngle)
        var qiblah = asin(sinQiblah)
        qiblah *= 180/π
        if(qiblah < 0){
            qiblah += 360
        }
        dateL.text = "Date : \(day) / \(month) / \(year)"
        longL.text = "Longitude : \(long*(180/π))°E"
        latL.text = "Latitude : \(lat*(180/π))°N"
        timeZL.text = "Time Zone : \(timeZ)"
        fajrL.text = "Fajr : \(pTimes.objectAtIndex(0))"
        sunRL.text = "Sunrise : \(pTimes.objectAtIndex(1))"
        zuhrL.text = "Zuhr : \(pTimes.objectAtIndex(2))"
        asrL.text = "Asr : \(pTimes.objectAtIndex(3))"
        sunSL.text = "Sunset : \(pTimes.objectAtIndex(4))"
        maghribL.text = "Maghrib : \(pTimes.objectAtIndex(5))"
        ishaL.text = "Isha : \(pTimes.objectAtIndex(6))"
        calcML.text = "Calculation Method : \(calcMS)"
        qiblaSL.text = "Simple Method : \(brng)°"
        qiblaSTL.text = "Spherical Trignometry : \(qiblah)°"
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate
        latitude = Double(locValue.latitude)
        longitude = Double(locValue.longitude)
        timeZone = Double(NSTimeZone.localTimeZone().secondsFromGMT as Int)
        timeZone = timeZone/3600
        updateLabels( latitude , long: longitude , timeZ: timeZone )
    }
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        var Mheading = newHeading.magneticHeading
        var Theading = newHeading.trueHeading
        magHead.text = "Magnetic Heading : \(Mheading)"
        trueHead.text = "True Heading : \(Theading)"
        headAcc.text = "Heading Accuracy : \(newHeading.headingAccuracy)"
    }
    @IBAction func azanAlarm(sender: AnyObject) {
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Sound | .Badge, categories: nil))
        }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        scheduleAzanMakkah( timeH: "17", timeM: "17", day: 17, month: 6, year: 2015, timeZone : NSTimeZone(forSecondsFromGMT: 5*3600))
    }
    func scheduleAzanMakkah( #timeH : String , timeM : String, day : Int , month : Int , year : Int, timeZone : NSTimeZone){
        var calender = NSCalendar(calendarIdentifier: "NSGregorianCalendar")
        var component = NSDateComponents()
        component.year = year
        component.day = day
        component.month = month
        component.hour = timeH.toInt()!
        component.minute = timeM.toInt()!
        component.second = 0
        component.timeZone = timeZone
        var datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        var localNotification = UILocalNotification()
        localNotification.timeZone = timeZone
        localNotification.fireDate = datetime;
        localNotification.soundName = "Makkah1.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 29
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah2.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 47
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah3.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.minute += 1
        component.second = 06
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah4.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 21
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah5.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 39
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah6.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 53
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah7.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.minute += 1
        component.second = 24
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah8.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 38
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah9.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    func scheduleAzanMaghribSiren(){
        
        var timeW = "\(pTimes.objectAtIndex(0))"
        var timeH : String = (timeW as NSString).substringToIndex(2)
        var timeM = (timeW as NSString).substringFromIndex(3)
        timeH = "16"
        timeM = "05"
        println("\(timeH) : \(timeM)")
        var calender = NSCalendar(calendarIdentifier: "NSGregorianCalendar")
        var component = NSDateComponents()
        component.year = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: date).year
        component.day = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: date).day
        component.month = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: date).month
        component.hour = timeH.toInt()!
        component.minute = timeM.toInt()!
        component.second = 0
        component.timeZone = NSTimeZone(forSecondsFromGMT: 5*3600)
        var datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        println("datetime : \(datetime)")
        var localNotification = UILocalNotification()
        localNotification.timeZone = NSTimeZone(forSecondsFromGMT: 5*3600)
        localNotification.fireDate = datetime;
        localNotification.soundName = "Siren.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 08
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah1.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 37
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah2.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 55
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah3.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.minute += 1
        component.second = 14
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah4.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 29
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah5.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 47
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah6.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.minute += 1
        component.second = 01
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah7.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 32
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah8.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        component.second = 46
        datetime = NSCalendar.currentCalendar().dateFromComponents(component)
        localNotification.fireDate = datetime
        localNotification.soundName = "Makkah9.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}