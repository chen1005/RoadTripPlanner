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
            
            //Nick Houser- testing route search using two points on route - indianapolis and west lafayette
            /*var currentRoute = [CLLocationCoordinate2D]()
            currentRoute.append(CLLocationCoordinate2D(latitude: 40.423705, longitude: -86.921195)) //purdue
            currentRoute.append(CLLocationCoordinate2D(latitude: 39.768491, longitude: -86.157679)) //indy
            //currentRoute.append(CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)) //los angeles
            searchRoute(searchText.text, points: currentRoute, completionHandler: {(success:Bool)->Void in
            self.zoomToFitMapAnnotations()
            })*/
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
    
    //Nick Houser- dispatch variables to synchronize threads
    //var threadcontrol = dispatch_group_create()
    struct waypointOption {
        var mapItem = MKMapItem() as MKMapItem
        var cost = 0.0 as Double
    }
    var bestOptions = [waypointOption]()
    
    //Nick Houser- function for route search
    //takes search string and array of location coordinates (which represent current route)
    //note - we may need to add functionality to trim this if too many results
    func searchRoute(place: String, points: [CLLocationCoordinate2D], completionHandler: (success: Bool) -> Void)
    {
        //to avoid exceptions if array is empty (should never happen)
        if (points.count == 0)
        {
            return
        }
        
        //clear the options array
        bestOptions.removeAll(keepCapacity: false)
        
        //set up variables that don't need recreated in loop; request, searchstring, search radius
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = place
        
        //loop through points
        for routePointIndex in 0...points.count-2
        {
            //determine distance between the points using pythagoras
            let lonOffset = points[routePointIndex].longitude - points[routePointIndex+1].longitude
            let latOffset = points[routePointIndex].latitude - points[routePointIndex+1].latitude
            let abDist = sqrt((lonOffset * lonOffset) + (latOffset * latOffset))
            
            //determine the center point between the points
            let lonCen = (points[routePointIndex].longitude + points[routePointIndex+1].longitude)*0.5
            let latCen = (points[routePointIndex].latitude + points[routePointIndex+1].latitude)*0.5
            let searchCenter = CLLocationCoordinate2D(latitude: latCen, longitude: lonCen)
            
            //create the search and set its center and span
            let searchRangeMultiplier = 1.1 * abDist
            let searchSpan = MKCoordinateSpan(latitudeDelta: searchRangeMultiplier, longitudeDelta: searchRangeMultiplier)
            request.region = MKCoordinateRegionMake(searchCenter, searchSpan)
            let search = MKLocalSearch(request: request)
            
            //start the search
            search.startWithCompletionHandler {
                (response: MKLocalSearchResponse!, error: NSError!) -> Void in
                
                //for each result
                for item in response.mapItems as! [MKMapItem] {
                    
                    
                    self.addIfLessRoadDistBetween2Points(MKMapItem(placemark: MKPlacemark(coordinate: points[routePointIndex], addressDictionary: nil)), destination: item)
                    
                    //add a pin
                    //self.addLocation(item.name, latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude)
                }
                
                
                //TODO: asynchronously add items to array
                //after complete, add pins for each arr item
                //add only if less time cost than whatever other items
                //so keep best 10 options at all times
                //TODO: make it so that it checks total trip distance not just distance from start
                
                //wait for threads to complete
                sleep(10)
                //dispatch_group_wait(self.threadcontrol, DISPATCH_TIME_FOREVER)
                
                //add the best results to the map
                for bestOption in self.bestOptions
                {
                    self.addLocation(bestOption.mapItem.name, latitude: bestOption.mapItem.placemark.location.coordinate.latitude, longitude: bestOption.mapItem.placemark.location.coordinate.longitude)
                }
                
                //only resize if this is the last iteration
                if (routePointIndex == points.count - 2)
                {
                    completionHandler(success: true)
                }
            }
        }
    }
    
    //Nick Houser- function for computing road distance between two points
    func addIfLessRoadDistBetween2Points(source: MKMapItem, destination: MKMapItem)
    {
        //synchronization
        //dispatch_group_enter(threadcontrol)
        
        //turn inputs into map items for passing
        //var source = MKMapItem(placemark: MKPlacemark(coordinate: start, addressDictionary: nil))
        //var destination = MKMapItem(placemark: MKPlacemark(coordinate: finish, addressDictionary: nil))
        
        //set up request and execute it
        var directionsRequest = MKDirectionsRequest()
        directionsRequest.setSource(source)
        directionsRequest.setDestination(destination)
        var directions = MKDirections(request: directionsRequest)
        
        //find the distance from start to finish
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            //set up result structure
            var toAppend = waypointOption()
            toAppend.mapItem = source
            toAppend.cost = response.routes.first!.distance
            
            //dispatch_sync(dispatch_get_main_queue()) {
            if (self.bestOptions.count < 9)
            {
                //if there are not yet 9 pins, insert this
                self.bestOptions.append(toAppend)
            }
            else
            {
                //otherwise, check if it is less than some other pin
                var biggestIndex = 0
                var biggestOption = self.bestOptions[0].cost
                
                //find the pin of greatest cost
                for optionIterator in 0...self.bestOptions.count-1
                {
                    if (self.bestOptions[optionIterator].cost > biggestOption)
                    {
                        biggestIndex = optionIterator
                        biggestOption = self.bestOptions[optionIterator].cost
                    }
                }
                
                //if the greatest cost pin costs more than this, replace it
                if (toAppend.cost < biggestOption)
                {
                    self.bestOptions[biggestIndex] = toAppend
                }
            }
            //}
            
            //release locks
            //dispatch_group_leave(self.threadcontrol)
        }
    }
}

