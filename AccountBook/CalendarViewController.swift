//
//  CalendarViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 21..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import RealmSwift

class CalendarViewController: UIViewController {
    var selectedDate:Date? = nil
    @IBOutlet weak var calendarView:FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.dataSource = self
        calendarView.delegate = self
        title = calendarView.currentPage.toString("yyyy-MM")
        if let date = self.selectedDate {
            calendarView.setCurrentPage(date, animated: false)
            calendarView.select(date)
        }
    }
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let d1 = Utill.getDayStartDt(date)
        let d2 = Date(timeIntervalSince1970: d1.timeIntervalSince1970 + (60*60*24))
        let count = try! Realm().objects(PaymentModel.self).filter("%@ <= datetime && %@ > datetime", d1, d2).count
        print("\(d1) \(d2) \(count)")
        return count
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        title = calendarView.currentPage.toString("yyyy-MM")

    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let list = navigationController?.viewControllers {
            if let vc = list[list.count - 2] as? ViewController {
                vc.selectedDate = date
                vc.title = date.toString("yyyy-MM-dd")
                navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
