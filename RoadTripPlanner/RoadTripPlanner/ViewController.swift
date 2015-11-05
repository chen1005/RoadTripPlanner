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
            /* Removed this to test route searching
            self.searchMap(searchText.text, completionHandler:{(success:Bool) -> Void in
                println("value = \(success)")
                self.zoomToFitMapAnnotations()
            })*/
            
            //Nick Houser- testing route search using two points on route - indianapolis and west lafayette
            var currentRoute = [CLLocationCoordinate2D]()
            currentRoute.append(CLLocationCoordinate2D(latitude: 40.423705, longitude: -86.921195)) //purdue
            
            //add some points between purdue and indy - just start and finish is too broad
            currentRoute.append(CLLocationCoordinate2D(latitude: 40.259902, longitude: -86.730316))
            currentRoute.append(CLLocationCoordinate2D(latitude: 40.096098, longitude: -86.539437))
            currentRoute.append(CLLocationCoordinate2D(latitude: 39.932295, longitude: -86.348558))
            
            currentRoute.append(CLLocationCoordinate2D(latitude: 39.768491, longitude: -86.157679)) //indy
            
            searchRoute(searchText.text, points: currentRoute, completionHandler: {(success:Bool)->Void in
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
    
    //John Shetler - function to return estimated time between two points
    //Takes two MKMapItem objects corresponding to the start and end points
    //Can be modified to take points in lat, lon form
    //returns travel time in seconds
    func calculateETA(srcPnt: CLLocationCoordinate2D, dstPnt: CLLocationCoordinate2D) -> NSInteger {
        let request = MKDirectionsRequest()
        let src = MKPlacemark(coordinate: srcPnt, addressDictionary: nil)
        let dst = MKPlacemark(coordinate: dstPnt, addressDictionary: nil)
        request.source = src
        request.destination = dst
        request.requestsAlternateRoutes = false
        request.transportType = MKDirectionsTransportType.Automobile
        var ret: NSInteger
        let directions = MKDirections(request: request)
        
        directions.calculateETAWithCompletionHandler{response, error in
            if error == nil{
                return
            }else{
                if let res = response{
                    ret = NSInteger(res.expectedTravelTime)
                }
            }
            
        }
        
        return ret
    }
    
    //John Shetler - function to return the additional travel time resulting from
    //adding "newPnt" to the route
    //Can be modified to take oints in lat, lon form
    //src and dst should be the stops that precede and follow newPnt respectively
    //If stops are removed or reordered, estimated time needs to be recalculated
    //returns additional travel time in seconds
    func calculateAdditionalTime(srcPnt: CLLocationCoordinate2D, newPnt: CLLocationCoordinate2D, dstPnt: CLLocationCoordinate2D)->NSInteger{
        let originalTime = calculateETA(srcPnt, dstPnt: dstPnt)
        let startToNew = calculateETA(srcPnt, dstPnt: newPnt)
        let newToEnd = calculateETA(newPnt, dstPnt: dstPnt)
        let modifiedTime = startToNew + newToEnd
        return (modifiedTime - originalTime)
    }
    
    //Nick Houser- function for route search
    //takes search string and array of location coordinates (which represent current route)
    //please note that if the points passed to this function are too far apart
    //some waypoints will be missed (not added to the map)
    //this is unavoidable as the MKLocalSearch cannot return more than 10 results
    //the solution is simply to pass this method a list of points close enough together that
    //a local search between any two of the input points does not contain more than 10 waypoints
    func searchRoute(place: String, points: [CLLocationCoordinate2D], completionHandler: (success: Bool) -> Void)
    {
        //to avoid exceptions if array is empty (should never happen)
        if (points.count == 0)
        {
            return
        }
        
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
                    
                    //add a pin
                    self.addLocation(item.name, latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude)
                }
                
                //only resize if this is the last iteration
                if (routePointIndex == points.count - 2)
                {
                    completionHandler(success: true)
                }
            }
        }
    }
}

