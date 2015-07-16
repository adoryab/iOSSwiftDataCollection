//
//  ViewController.swift
//  Timebanking_swift
//
//  Created by Ivy Chung on 5/22/15.
//  Copyright (c) 2015 Patrick Chang. All rights reserved.
//

import UIKit


public class ViewController: UIViewController {
    
    var locationLatitude = ""
    var locationLongitude = ""
    var activityConfidence = ""
    var activityType = ""
    
    
    //var appDelegate = AppDelegate()
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var activity: UILabel!
    @IBOutlet weak var confidence: UILabel!
    var updateUIInitializer = NSTimer()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        println(latitude.text!)
        println(longitude.text!)
        println(activity.text!)
        println(confidence.text!)
*/
        updateUI(locationLatitude, longitudeString: locationLongitude, activityString: activityType, confidenceString: activityConfidence)
        //println(longitude.text)

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateHelper() {
        updateUI(locationLatitude,
            longitudeString: locationLongitude,
            activityString: activityType,
            confidenceString: activityConfidence)
    }
    
    func updateUI(latitudeString: String, longitudeString :String, activityString :String, confidenceString: String) {
        
        latitude.text = latitudeString
        longitude.text = longitudeString
        activity.text = activityString
        confidence.text = confidenceString
        /*
        updateUIInitializer = NSTimer.scheduledTimerWithTimeInterval(5,
            target: self,
            selector: "updateHelper",
            userInfo: nil,
            repeats: false)
*/
        
    }

 
}

