//
//  ViewController.swift
//  vidur
//
//  Created by Neal Malhotra on 6/12/20.
//  Copyright © 2020 Neal Malhotra. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    //@IBOutlet var mapView: MKMapView!
    
    @IBOutlet weak var textField: UILabel!
    
    let manager = CLLocationManager()
    
    var counterSoNoChangingHomeLocation = 1
    
    let defaults = UserDefaults.standard
    
    func counter() {
        if counterSoNoChangingHomeLocation == 1 {
            counterSoNoChangingHomeLocation += 1
            defaults.set(counterSoNoChangingHomeLocation, forKey: "counter")
        }
        else {
            //break the function
        }
    }
    
    var lat: CLLocationDegrees = 0.00
    var long: CLLocationDegrees = 0.00

    
    func render(_ location:CLLocation){
                let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        lat = CLLocationDegrees(location.coordinate.latitude)
        long = CLLocationDegrees(location.coordinate.longitude)
        print(coordinate)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region: MKCoordinateRegion? = MKCoordinateRegion(center: coordinate, span: span)
            
            
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            
        
    }
    
    func latLongAdder() {
        if counterSoNoChangingHomeLocation == 2 {
            defaults.set(lat, forKey: "latitude")
            defaults.set(long, forKey: "longitude")
        }
        else {
            // break the function
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.distanceFilter = 100
        
        
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake (43.61871, -116.214607) , radius: 0.1, identifier: "Home")
        //43.61871,-116.214607
        
        geoFenceRegion.notifyOnEntry = true
        geoFenceRegion.notifyOnExit = true
        manager.startMonitoring(for: geoFenceRegion)
        
         
        locationManager(manager, didEnterRegion: geoFenceRegion)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
/*
    for currentlocation in locations{
            print("\(index): \(currentlocation)")
 */
        if let location = locations.first {
            manager.stopUpdatingLocation()
            
            render(location)
        }
        for currentLocation in locations {
            print("\(index)\(currentLocation)")
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        /*
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            let content = UNMutableNotificationContent()
            content.title = "Rember Safety Things!"
            content.body = "Get ur stuff"
            content.subtitle = "SUBTITLE"
            content.badge = 1
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            textField.text = " "
            textField.text = "did enter region"
 */
        print("Entered: \(region.identifier)")
        postLocalNotifications(eventTitle: "Entered: \(region.identifier)")
        }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        /* if let region = region as? CLCircularRegion {
                   let identifier = region.identifier
                   let content = UNMutableNotificationContent()
                   content.title = "Rember Safety Things!"
                   content.body = "DISINFECT UR STUFF"
                   content.subtitle = "SUBTITLE"
                   content.badge = 1
                   content.sound = UNNotificationSound.default
                   
                   let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                   
                   let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                   
                   UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            textField.text = " "
            textField.text = "did exit region "
 */
        print("Exited: \(region.identifier)")
        postLocalNotifications(eventTitle: "Exited: \(region.identifier)")
                   
               }
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }


    func postLocalNotifications(eventTitle:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "You've entered a new region"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
}
    

       
        

    
    



