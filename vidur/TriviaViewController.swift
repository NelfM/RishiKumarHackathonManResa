//
//  TriviaViewController.swift
//  vidur
//
//  Created by Neal Malhotra on 6/13/20.
//  Copyright © 2020 Neal Malhotra. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class TriviaViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var DistanceReader: UILabel!
        
        var locationManager: CLLocationManager?
        let center = UNUserNotificationCenter.current()
        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
            
           

            
            center.requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in
                
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways {
                if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                    if CLLocationManager.isRangingAvailable() {
                        startScanning()
                    }
                }
            }
        }
        
        func startScanning() {
            let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")

            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(in: beaconRegion)
        }
        
        


        func updateDistance(_ distance: CLProximity) {
            UIView.animate(withDuration: 0.8) {
                switch distance {
                
                
                case .near:
                    self.view.backgroundColor = UIColor.orange
                    self.DistanceReader.text = "Near"
                    let content = UNMutableNotificationContent()
                    content.title = "Nearby"
                    content.body = "There is a person nearby"
                    
                    let date = Date().addingTimeInterval(10)
                    
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    
                    self.center.add(request) { (error) in
                        
                    }
                case .immediate:
                    self.view.backgroundColor = UIColor.red
                    self.DistanceReader.text = "Right here"
                    let content = UNMutableNotificationContent()
                    content.title = "RIGHT NEXT TO YOU"
                    content.body = "There is a person right next to you"
                    
                    let date = Date().addingTimeInterval(10)
                    
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    
                    self.center.add(request) { (error) in
                        
                    }
                    
                    
               @unknown default:
                    self.view.backgroundColor = UIColor.gray
                    self.DistanceReader.text = "UNKNOWN"
                }
            }
            
        }
        
        func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
            if let beacon = beacons.first{
                updateDistance(beacon.proximity)
            } else {
                updateDistance(.unknown)
            }
        }
    }


