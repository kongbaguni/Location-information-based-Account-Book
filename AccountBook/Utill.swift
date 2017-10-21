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
    static let dateFormatter = DateFormatter()
    
    static func getDateStartDt(_ format:String, locale:Locale = Locale.current)->Date? {
        return Date().toString(format, locale: locale).toDate(format, locale: locale)
    }
    static func getDayStartDt(_ locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy-MM-dd", locale: locale)!
    }
    static func getMonthStartDt(_ locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy-MM", locale: locale)!
    }
    static func getYearStartDt(_ locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy", locale: locale)!
    }

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
    func toString(_ format:String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", locale:Locale = Locale.current)->String
    {
        Utill.dateFormatter.locale = locale
        Utill.dateFormatter.dateFormat = format
        return Utill.dateFormatter.string(from: self)
    }
    
}

extension String {
    /** 언어코드*/
    fileprivate static let Language = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
    /** 국가코드*/
    fileprivate static let Nation = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
    
    /** string 값을 NSDate로 변환.*/
    func toDate(_ format:String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", locale:Locale = Locale.current)->Date?
    {
        Utill.dateFormatter.dateFormat = format
        Utill.dateFormatter.locale = locale
        return Utill.dateFormatter.date(from: self)
        
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
