//
//  AppDelegate.swift
//  Timebanking-iOS-swift
//
//  Created by Ivy Chung on 5/15/15.
//  Copyright (c) 2015 Patrick Chang. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CoreLocation

//Class extensions
extension NSDate{
    class func now() -> NSDate{
        return NSDate()
    }
    class func tenSecondsAgo() -> NSDate{
        return NSDate(timeIntervalSinceNow: -(10))
    }
    class func oneDayAgo() -> NSDate {
        return NSDate(timeIntervalSinceNow: -60*60*24)
    }
}

extension NSURLSessionTask{ func start(){
    self.resume() }
}

//misc functions
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //used in predicating batch updates
    let vc = ViewController()
    var lastUpdate = NSDate()
    //update variables
    var counter = 0
    lazy var locationFrequency: NSTimeInterval = 2
    var updateTimerInitializer: NSTimer?
    var updateTimer: NSTimer?
    var window: UIWindow?
    let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    let dataProcessingQueue = NSOperationQueue()
    let activityQueue = NSOperationQueue()
    lazy var pedometer = CMPedometer()
    var locationManager: CLLocationManager = CLLocationManager()
    var lastThreeActivities = [String] (count:3, repeatedValue: "Unknown")
    let quickUpdateFrequency :NSTimeInterval = 2
    let slowUpdateFrequency :NSTimeInterval = 10
    var activityHandler :CMMotionActivityQueryHandler!
    //uploading to the server
    var locationLongitude = ""
    var locationLatitude = ""
    var activityType = ""
    var activityConfidence = ""
    
    //******************
    //BACKGROUND TRACKING
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(0)
        return true;
        
        
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        println("Complete");
        completionHandler(.NewData)
        
        getData();
        
    }
    /*
    func getData() -> Void{
        var timestamp = NSDate()
        self.activityManager.queryActivityStartingFromDate(NSDate.oneDayAgo(), toDate: NSDate(), toQueue: self.activityQueue){
            (activityHandler) in
            for activity in activityHandler {
                println(activity)
            }
                println("currently querying")
                self.lastUpdate=NSDate()
            }
    }
    [cm queryActivityStartingFromDate:lastWeek toDate:today toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
    for(int i=0;i<[activities count]-1;i++) {

*/
    func getData() -> Void{
        var timestamp = NSDate()
        println("Old lastupdate time is \(self.lastUpdate)")
        self.activityManager.queryActivityStartingFromDate(NSDate.oneDayAgo(),
            toDate: NSDate(), toQueue: activityQueue) {
                (activities, error) in
                if error != nil {
                    println("There was an error retrieving the motion results: \(error)")
                }
                /*
                let activitydb = NSEntityDescription.insertNewObjectForEntityForName("Activity", inManagedObjectContext: self.managedObjectContext!) as! Activity
                for activity in activities {
                    activitydb.timestamp = activity.timestamp
                    if activity.confidence == CMMotionActivityConfidence.Low {
                        activitydb.confidence = "low"
                    } else if activity.confidence == CMMotionActivityConfidence.Medium {
                        activitydb.confidence = "medium"
                    } else if activity.confidence == CMMotionActivityConfidence.High {
                        activitydb.confidence = "high"
                    } else {
                        activitydb.confidence = "There was a problem getting confidence"
                    }
                }
*/
                println(activities.count)

        }
        self.lastUpdate = NSDate()
        println("New lastUpdate time is \(self.lastUpdate)")
    }


    func applicationDidBecomeActive(application: UIApplication) {
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //distance updater
        updateTimerInitializer = NSTimer.scheduledTimerWithTimeInterval(5,
            target: self,
            selector: "updater:",
            userInfo: nil,
            repeats: false)
    }
    
    
    func printLastTenUpdates() {
        
        let fetchRequest = NSFetchRequest(entityName: "Activity")
        var requestError: NSError?
        let activities = managedObjectContext!.executeFetchRequest(fetchRequest,error: &requestError) as! [Activity!]
        if activities.count > 0 {
            /*
            for activity in activities {
                println("The confidence level is " + activity.confidence)
                println("The activity type is " + activity.activityType)
                println("The activity list is " + activity.activityList)
                println(activity.timestamp)
                println("\n")

            }
*/
            println("The number of activities stored is: " + (NSString(format: "%i",activities.count) as String) as String)
        }
                /*
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        //2
        let fetchRequest = NSFetchRequest(entityName:"Activity")
        //3
        var error: NSError?
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        println(fetchedResults)
        println("-------------------------------------------------")
*/
        let fetchRequest2 = NSFetchRequest(entityName: "Location")
        var requestError2: NSError?
        let locations = managedObjectContext!.executeFetchRequest(fetchRequest2, error: &requestError2) as! [Location!]
        if locations.count > 0 {
            println("The number of locations stored is: " + (NSString(format: "%i",locations.count) as String) as String)
        }
        println("-------------------------------------------------------------")
        //let predicate = NSPredicate(format: self.lastUpdate >= "%@" , timestamp)
        
    }

        
        
        
    //distance && activity
    func updater(timer:NSTimer) {
        var shortTimer :Bool = Bool()
        let drivingSpeed :NSNumber = 67      //15 mph
        var activityString = "| "
        let activityManager: CMMotionActivityManager = CMMotionActivityManager()
        let dataProcessingQueue = NSOperationQueue()
        
        //location tracking
        locationManager.startUpdatingLocation()
        let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext!) as! Location
        location.timestamp = NSDate()
        //location.longitude = NSString(format: "%.8f", locationManager.location.coordinate.longitude) as String
        //location.latitude = NSString (format: "%.8f", locationManager.location.coordinate.latitude) as String

        println("Your current latitude is " , locationManager.location.coordinate.latitude)
        println("Your current longitude is ", locationManager.location.coordinate.longitude)
        //println("The current time is ", locationManager.location.timestamp)
        self.locationLongitude = NSString(format: "%.8f", locationManager.location.coordinate.longitude) as String
        self.locationLatitude = NSString(format: "%.8f", locationManager.location.coordinate.latitude) as String

        locationManager.stopUpdatingLocation()
        
        //activity tracking
        if CMPedometer.isDistanceAvailable(){
            pedometer.queryPedometerDataFromDate(NSDate.tenSecondsAgo(),
                toDate: NSDate.now(),
                withHandler: {(data: CMPedometerData!, error: NSError!) in
                    //println("Distance travelled since ten seconds ago" +
                    //    "= \(data.distance) meters")
                    var distanceTravelled = data.distance as NSNumber
                    
                    self.activityManager.startActivityUpdatesToQueue(self.dataProcessingQueue) {
                        data in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.lastThreeActivities[2] = self.lastThreeActivities[1]
                            self.lastThreeActivities[1] = self.lastThreeActivities[0]
                            if data.running {
                                //println("the current activity is running")
                                self.lastThreeActivities[0] = "Running"
                                activityString += " running |"
                            }; if data.cycling {
                                //println("the current activity is cycling")
                                self.lastThreeActivities[0] = "Cycling"
                                activityString += " cycling |"
                            };if data.walking {
                                //println("the current activity is walking")
                                self.lastThreeActivities[0] = "Walking"
                                activityString += " walking |"
                            }; if data.automotive  && distanceTravelled.compare(drivingSpeed) == NSComparisonResult.OrderedDescending {
                                //println("the current activity is automotive")
                                self.lastThreeActivities[0] = "Automotive"
                                activityString += " automotive |"
                            }; if data.stationary{
                                //println("the current activity is stationary")
                                self.lastThreeActivities[0] = "Stationary"
                                activityString += " stationary |"
                            }; if data.unknown {
                                //println("the current activity is unknown")
                                self.lastThreeActivities[0] = "Unknown"
                                activityString += " unknown |"
                            }
                            let activity = NSEntityDescription.insertNewObjectForEntityForName("Activity", inManagedObjectContext: self.managedObjectContext!) as! Activity
                            self.activityManager.stopActivityUpdates()
                            activity.timestamp = NSDate()
                            activity.activityType = self.lastThreeActivities[0]
                            activity.activityList = activityString
                            if data.confidence == CMMotionActivityConfidence.Low {
                                activity.confidence = "low"
                            } else if data.confidence == CMMotionActivityConfidence.Medium {
                                activity.confidence = "medium"
                            } else if data.confidence == CMMotionActivityConfidence.High {
                                activity.confidence = "high"
                            } else {
                                activity.confidence = "There was a problem getting confidence"
                            }

                            //println( self.lastThreeActivities)
                            if self.lastThreeActivities[0] != "Stationary" {
                                //println("the most recent activity is different")
                                shortTimer = true
                                
                            } else if self.lastThreeActivities[1] != "Stationary" {
                                shortTimer = true
                                //println("the second most recent activity is different")
                            } else if self.lastThreeActivities[2] != "Stationary" {
                                shortTimer = true
                                //println("the third most recent activity is different")
                            } else {
                                shortTimer = false
                            }
                            self.activityType = self.lastThreeActivities[0]
                            self.activityConfidence = activity.confidence
                            //ViewController().updateHelper()
                            //println(shortTimer)
                            self.counter += 1
                            if self.counter%5 == 0 {
                                self.printLastTenUpdates()
                            }
                            self.sendToServer(self.locationLongitude, latitudeString: self.locationLatitude, activityString: self.activityType, confidenceString: self.activityConfidence)
                            self.updateWithVaryingFrequency(shortTimer)
                            //println(self.locationFrequency)
                            //println("\n")
                            
                        }
                    }

                    
            })
        } else {
            println("A required feature is unavailable. This app will not work")
        }
    }
    
    
    func updateWithVaryingFrequency(boolVar: Bool) {
        //println(boolVar)
        if boolVar == true {
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.quickUpdateFrequency,
                target: self,
                selector: "updater:",
                userInfo: nil,
                repeats: false)
        } else {
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.slowUpdateFrequency,
                target: self,
                selector: "updater:",
                userInfo: nil,
                repeats: false)
        }
        
    }
    
    func sendToServer(longitudeString: String, latitudeString: String, activityString: String, confidenceString: String) {
        let myUrl = NSURL(string: "http://epiwork.hcii.cs.cmu.edu/~afsaneh/script2.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        //modify strings for formatting
        let stringBuffer = ","
        let longitudeString2 = longitudeString + stringBuffer
        let latitudeString2 = latitudeString + stringBuffer
        let activityString2 = activityString + stringBuffer
        let confidenceString2 = confidenceString + stringBuffer
        // Compose a query string
        let postString = "longitude=\(longitudeString2)&latitude=\(latitudeString2)&type=\(activityString2)&confidence=\(confidenceString2)&timestamp=\(NSDate())";
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                println("error=\(error)")
                return
            }
            
            // You can print out response object
            println("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
            
            //Let's convert response sent from a server side script to a NSDictionary object:
            
            var err: NSError?
            var myJSON = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error:&err) as? NSDictionary
            
            if let parseJSON = myJSON {
                // Now we can access value of First Name by its key
                var firstNameValue = parseJSON["Longitude"] as? String
                println("firstNameValue: \(firstNameValue)")
            }
            
        }
        
        task.resume()

    }
    
    func applicationWillResignActive(application: UIApplication) {
        pedometer.stopPedometerUpdates()
    }
    
    
    
    
    /*
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    return true
    }
    */
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "UbiCompLab-CMU.Timebanking_swift" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Timebanking_swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Timebanking_swift.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

