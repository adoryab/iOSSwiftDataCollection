//
//  Activity.swift
//  Timebanking_swift
//
//  Created by Ivy Chung on 5/22/15.
//  Copyright (c) 2015 Patrick Chang. All rights reserved.
//

import Foundation
import CoreData

class Activity: NSManagedObject {

    @NSManaged var activityType: String
    @NSManaged var activityList: String
    @NSManaged var timestamp: NSDate
    @NSManaged var confidence: String

}
