//
//  ViewController.swift
//  PokeFinder
//
//  Created by Geoffrey on 8/15/17.
//  Copyright © 2017 Geoffrey. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
        
        @IBOutlet weak var mapView : MKMapView!
        
        let locationManager = CLLocationManager()
        var mapHasCenteredOnce = false
        var geoFire : GeoFire!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                mapView.delegate = self
                mapView.userTrackingMode = MKUserTrackingMode.follow

        }

}

