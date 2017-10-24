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
    
    static func getDateStartDt(_ format:String, date:Date = Date(), locale:Locale = Locale.current)->Date? {
        return date.toString(format, locale: locale).toDate(format, locale: locale)
    }
    
    static func getDayStartDt(_ date:Date = Date() ,locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy-MM-dd", date:date, locale: locale)!
    }
    
    static func getMonthStartDt(_ date:Date = Date(), locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy-MM", date:date, locale: locale)!
    }
    
    static func getYearStartDt(_ date:Date = Date(), locale:Locale = Locale.current)->Date {
        return Utill.getDateStartDt("yyyy", date:date, locale: locale)!
    }

    
    static var startDay:Date {
        if let date = (UserDefaults.standard.value(forKey: "startDate") as? String)?.toDate() {
            return date
        }
        return Utill.getMonthStartDt()
    }
    
    static var endDay:Date {
        if let date = (UserDefaults.standard.value(forKey: "endDate") as? String)?.toDate() {
            return date
        }
        return Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 60 * 60 * 24)
    }
    
    static var isDayFilterEnable:Bool {
        return UserDefaults.standard.bool(forKey: "isDayFilterEnable")
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


extension UIToolbar {
    
    func toolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
