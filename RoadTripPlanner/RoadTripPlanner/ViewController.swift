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
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
        
        mapView.removeAnnotations(mapView.annotations)
        AnnotationSets.annotations.removeAll(keepCapacity: true);
        
        if (!searchText.text.isEmpty)
        {
            self.searchMap(searchText.text, completionHandler:{(success:Bool) -> Void in
                println("value = \(success)")
                self.zoomToFitMapAnnotations()
            })
        }
    }
    
    // Initialize location to Purdue Univerisity - Zhuo Chen
    var currentLocation = CLLocation(latitude: 40.423705, longitude: -86.921195)
    // Initialize search radius - Zhuo Chen
    var searchRadius:CLLocationDistance = 5000
    // Create location manager - Zhuo Chen
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestWhenInUseAuthorization()
        
        /*if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }*/

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation
        userLocation: MKUserLocation!) {
            currentLocation = userLocation.location
    }
    
    func zoomToFitMapAnnotations()
    {
        if(mapView.annotations.count == 0)
        {
            return
        }
        
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
    
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
        for annotation in mapView.annotations as! [MKAnnotation]
        {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
    
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
    
        var regionLat = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        var regionLong = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        var spanLat = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.15
        var spanLong = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.15
        var span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
        var centerLocation = CLLocation(latitude: regionLat, longitude: regionLong)
        var region = MKCoordinateRegion(center: centerLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /*func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject])
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
    }*/
    
    func addLocation(title:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees)
    {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = AnnotationModel(coordinate: location, title: title)
        AnnotationSets.annotations.append(annotation)
        mapView.addAnnotation(annotation)
    }
    
    func searchMap(place:String, completionHandler: (success: Bool) -> Void)
    {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = place
        
        // Search current region - Zhuo Chen
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        // Start searching - Zhuo Chen
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) -> Void in
            for item in response.mapItems as! [MKMapItem] {
                self.addLocation(item.name, latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude)
            }
            
            completionHandler(success: true)
        }
    }
}

