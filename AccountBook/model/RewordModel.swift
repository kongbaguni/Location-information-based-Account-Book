//
//  RewordModel.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 11. 18..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RewordModel: Object {
    @objc dynamic var datetime:Date?
    @objc dynamic var amount:Int = 0
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    @objc dynamic var type:String = ""
    var coordinate2D:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
