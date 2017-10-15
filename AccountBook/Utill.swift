//
//  Utill.swift
//  locationTest
//
//  Created by Seo Changyul on 2017. 10. 15..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Utill {
    static var navigationController: NavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? NavigationController
    }
    
    static let numberFormatter = NumberFormatter()
}

extension Int {
    func toMoneyFormatString(_ locale:Locale)->String? {
        let formatter = Utill.numberFormatter
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: self))
    }
}

extension Date
{
    func toString(_ format:String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", locale:Locale)->String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

