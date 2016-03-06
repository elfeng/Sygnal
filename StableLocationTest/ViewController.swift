//
//  ViewController.swift
//  StableLocationTest
//
//  Created by Mitchell Ang on 2016-03-05.
//  Copyright © 2016 Mitchell Ang. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MessageUI

class ViewController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    var timer = NSTimer()
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        view.backgroundColor = UIColor.grayColor()
    }
    
    @IBAction func getFixPressed(sender: UIButton) {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "timerAction", userInfo: nil, repeats: true)
        sendEmailFeedback(sender)
        /*
        let title = "Confirmation"
        
        let message = "Auto check-in and check-out is enabled for all your classes."
        
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okButton = UIAlertAction(title: okText, style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(okButton)
        
        presentViewController(alert, animated: true, completion: nil)
        */
    }
    
    func timerAction() {
        locationManager.requestLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            updateDistance(beacon.proximity)
        } else {
            updateDistance(.Unknown)
        }
        print(beacons)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func startScanning() {
        let uuid = NSUUID(UUIDString: "2173E519-9155-4862-AB64-7953AB146156")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 5, minor: 142, identifier: "iBeacon")
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func updateDistance(distance: CLProximity) {
        UIView.animateWithDuration(0.8) { [unowned self] in
            dynamic var prevBeacon: CLBeacon?
            
            switch distance {
            case .Unknown:
                self.view.backgroundColor = UIColor.grayColor()
                if (prevBeacon!.proximity == CLProximity.Far) {
                    print("checkedout")
                }
                
            case .Far:
                self.view.backgroundColor = UIColor.blueColor()
                if (prevBeacon!.proximity == CLProximity.Unknown) {
                    print("checkedin")
                }
                
            case .Near:
                self.view.backgroundColor = UIColor.orangeColor()
                
            case .Immediate:
                self.view.backgroundColor = UIColor.redColor()
            }
        }
    }
    
    func sendEmailFeedback(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["phoebeyu7@gmail.com"])
        mailComposerVC.setSubject(UIDevice.currentDevice().identifierForVendor!.UUIDString)
        mailComposerVC.setMessageBody("Message Body", isHTML: false)
        
        return mailComposerVC
    }
    
    //Comment - This function alerts the user with error message
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your signal cannot be detected at the moment. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        }))
        self.presentViewController(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}