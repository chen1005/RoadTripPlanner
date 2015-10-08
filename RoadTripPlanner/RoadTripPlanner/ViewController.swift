//
//  ViewController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/10/7.
//  Copyright (c) 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    // Initialize location to Purdue Univerisity - Zhuo Chen
    var currentLocation = CLLocation(latitude: 40.423705, longitude: -86.921195)
    // Initialize search radius - Zhuo Chen
    var searchRadius:CLLocationDistance = 5000
    // Create location manager - Zhuo Chen
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }*/

        mapView.mapType = .Standard
        mapView.frame = view.frame
        mapView.delegate = self
        view.addSubview(mapView)
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject])
    {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        // Create a region - Zhuo Chen
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, searchRadius, searchRadius)
        // Set map view - Zhuo Chen
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true;
        
        // Stop updating location - Zhuo Chen
        locationManager.stopUpdatingLocation()
    }
    
    func addLocation(title:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees)
    {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = SearchAnnotation(coordinate: location, title: title)
        mapView.addAnnotation(annotation)
    }
    
    func searchMap(place:String)
    {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = place
        
        // Search current region - Zhuo Chen
        //let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = mapView.region
        // Start searching - Zhuo Chen
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) -> Void in
            for item in response.mapItems as! [MKMapItem] {
                println("Name = \(item.name)")
                println("Phone = \(item.phoneNumber)")
                self.addLocation(item.name, latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude)
            }
        }
    }
}

