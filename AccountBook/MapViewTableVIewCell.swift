//
//  MapViewTableVIewCell.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 21..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import MapKit
import UIKit
class MapViewTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView:MKMapView!
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        mapView.layer.borderWidth = 0.5
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
    }
}
