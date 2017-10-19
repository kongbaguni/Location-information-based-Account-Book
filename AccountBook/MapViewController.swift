//
//  MapViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 19..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView:MKMapView!
    let pointer = MKPointAnnotation()
    var isAnimated = false
    
    override func viewDidLoad() {
        mapView.addAnnotation(pointer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let region = MKCoordinateRegionMakeWithDistance(pointer.coordinate, 200, 200)
        mapView.setRegion(region, animated: isAnimated)
    }
}
