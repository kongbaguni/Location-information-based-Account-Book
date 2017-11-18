//
//  PaymentModel.swift
//  locationTest
//
//  Created by Seo Changyul on 2017. 10. 15..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class PaymentModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    @objc dynamic var tag:String = ""
    @objc dynamic var money:Int = 0
    @objc dynamic var datetime:Date? = nil
    @objc dynamic var locailIdentifier:String = ""
    @objc dynamic var region:String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var coordinate2D:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var locale:Locale {
        return Locale(identifier: locailIdentifier)
    }    
}
