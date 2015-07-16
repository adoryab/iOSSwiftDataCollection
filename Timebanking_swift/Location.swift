//
//  Location.swift
//  Timebanking_swift
//
//  Created by Ivy Chung on 5/26/15.
//  Copyright (c) 2015 Patrick Chang. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var longitude: String
    @NSManaged var latitude: String
    @NSManaged var timestamp: NSDate

}
