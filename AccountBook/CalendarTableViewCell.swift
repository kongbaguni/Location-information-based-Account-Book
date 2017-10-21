//
//  CalendarTableViewCell.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 21..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import FSCalendar
import UIKit
import MapKit

class CalendarTableViewCell: UITableViewCell {
    @IBOutlet weak var calendar:FSCalendar!
    @IBOutlet weak var mapView: MKMapView!
}
