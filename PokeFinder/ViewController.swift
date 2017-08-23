//
//  ViewController.swift
//  PokeFinder
//
//  Created by Geoffrey on 8/15/17.
//  Copyright © 2017 Geoffrey. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
        
        @IBOutlet weak var mapView : MKMapView!
        
        let locationManager = CLLocationManager()
        var mapHasCenteredOnce = false
        var geoFire : GeoFire!
        var geoFireRef : DatabaseReference!
        
        override func viewDidLoad() {
                
                super.viewDidLoad()
                
                mapView.delegate = self
                mapView.userTrackingMode = MKUserTrackingMode.follow
                
                geoFireRef = Database.database().reference()
                geoFire = GeoFire(firebaseRef : geoFireRef)
        }
        
        override func viewDidAppear(_ animated: Bool) {
                
                locationAuthStatus()
        }
        
        func locationAuthStatus() {
                
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        mapView.showsUserLocation = true
                } else {
                        locationManager.requestWhenInUseAuthorization()
                }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                
                if status == CLAuthorizationStatus.authorizedWhenInUse {
                        
                        mapView.showsUserLocation = true
                }
        }
        
        func ceneterMapOnLocation(location : CLLocation) {
                
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
                mapView.setRegion(coordinateRegion, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
                
                if let location = userLocation.location {
                        
                        if !mapHasCenteredOnce {
                                ceneterMapOnLocation(location: location)
                                mapHasCenteredOnce = true
                        }
                }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                
                let annoIdentifier = "Pokemon"
                var annotationView : MKAnnotationView?
                
                if annotation.isKind(of: MKUserLocation.self) {
                        
                        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
                        annotationView?.image = UIImage(named: "Ash")
                } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
                        
                        annotationView = deqAnno
                        annotationView?.annotation = annotation
                } else {
                        
                        let av = MKAnnotationView(annotation : annotation, reuseIdentifier : annoIdentifier)
                        av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                        annotationView?.annotation = annotation
                }
                
                if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
                        
                        annotationView.canShowCallout = true
                        annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
                        
                        let btn = UIButton()
                        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                        btn.setImage(UIImage(named : "map"), for: .normal)
                        
                        annotationView.rightCalloutAccessoryView = btn
                }
                
                return annotationView
        }
        
        func createSighting(forLocation location : CLLocation, withPokemon pokeId : Int) {
                
                geoFire.setLocation(location, forKey : "\(pokeId)")
        }
        
        func showSightingOnMap(location : CLLocation) {
                
                let circleQuery = geoFire!.query(at : location, withRadius : 2.5)
                
                _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
                        
                        if let key = key, let location = location {
                                
                                let ano = PokeAnnotation(coordinate : location.coordinate, pokemonNumber : Int(key)!)
                                self.mapView.addAnnotation(ano)
                        }
                })
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
                
                let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
                
                showSightingOnMap(location: loc)
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
                
                if let anno = view.annotation as? PokeAnnotation {
                        
                        let place = MKPlacemark(coordinate: anno.coordinate)
                        let destination = MKMapItem(placemark: place)
                        destination.name = "Pokemon Sighting"
                        let regionDistance : CLLocationDistance = 1000
                        let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
                        
                        let options = [MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate : regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeTransit] as [String : Any]
                        
                        MKMapItem.openMaps(with: [destination], launchOptions: options)
                        
                }
        }
        
        @IBAction func spotRandomPokemon(_ sender: Any) {
                
                let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
                
                let rand = arc4random_uniform(151) + 1
                createSighting(forLocation: location, withPokemon: Int(rand))
        }
        

}







