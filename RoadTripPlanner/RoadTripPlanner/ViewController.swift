//
//  ViewController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/10/7.
//  Copyright (c) 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    /*override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        gpaViewController.placeDelegate = self
        
        presentViewController(gpaViewController, animated: true, completion: nil)
    }*/
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchText: UITextField!
    
    @IBAction func addWayPointsClick(sender: AnyObject)
    {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.text = "Current Location"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            if (self.selectedMarker != nil)
            {
                textField.text = self.selectedMarker.title
            }
            else
            {
                textField.placeholder = "Destination?"
            }
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            var origin = (addressAlert.textFields![0] as UITextField).text! as String
            var destination = (addressAlert.textFields![1] as UITextField).text! as String
            
            if (origin == "Current Location")
            {
                origin = self.currentLocation.coordinate.latitude.description + "," + self.currentLocation.coordinate.longitude.description;
            }
            
            for item in self.markerSets.markers
            {
                if (self.selectedMarker.position.latitude == item.latitude && self.selectedMarker.position.longitude == item.longitude)
                {
                    destination = "place_id:" + item.placeId
                }
            }
            //Update to use waypoints
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.searchRoute()
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                }
                else {
                    print(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    @IBAction func routePlannerClick(sender: AnyObject)
    {
        self.presentViewController(tripPlannerController, animated:true, completion:nil)
    }
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
        
        if (!searchText.text!.isEmpty)
        {
            let query = searchText.text! as String
            self.mapTasks.textSearch(query, location: currentLocation.coordinate, radius: searchRadius, withCompletionHandler: { (status, success) -> Void in
                if (!success)
                {
                    print(status)
                    
                    if status == "ZERO_RESULTS" {
                        print("The location could not be found.")
                    }
                }
                else
                {
                    self.mapView.clear()
                    self.markerSets.markers.removeAll()
                    self.selectedMarker = nil
                    self.searchMarker()
                    self.zoomToFitMapMarkers()
                }
            })
        }
    }
    
    @IBAction func routeCalculator(sender: AnyObject)
    {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.text = "Current Location"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            if (self.selectedMarker != nil)
            {
                textField.text = self.selectedMarker.title
            }
            else
            {
                textField.placeholder = "Destination?"
            }
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            var origin = (addressAlert.textFields![0] as UITextField).text! as String
            var destination = (addressAlert.textFields![1] as UITextField).text! as String
            
            if (origin == "Current Location")
            {
                origin = self.currentLocation.coordinate.latitude.description + "," + self.currentLocation.coordinate.longitude.description;
            }
            
            for item in self.markerSets.markers
            {
                if (self.selectedMarker.position.latitude == item.latitude && self.selectedMarker.position.longitude == item.longitude)
                {
                    destination = "place_id:" + item.placeId
                }
            }
            //Update to use waypoints
            var wayPoints = Array<String>()
            wayPoints.append("Springfield,IL")
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: wayPoints, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.searchRoute()
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                }
                else {
                    print(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    // Initialize location to Purdue Univerisity - Zhuo Chen
    var currentLocation = CLLocation(latitude: 40.423705, longitude: -86.921195)
    // Initialize searching radius - Zhuo Chen
    var searchRadius = 5000
    // Create location manager - Zhuo Chen  
    let locationManager = CLLocationManager()
    // Create Map Tasks controller - Zhuo Chen
    let mapTasks = MapTasksController()
    // Create Weather controller - Zhuo Chen
    let weatherController = WeatherController()
    // Create Google Place Autocomplete controller - Zhuo Chen
    let gpaViewController = GooglePlacesAutocomplete(apiKey: "AIzaSyAEuoPxT43YjP704p9Tfmhp_1AeZNcMERM", placeType: .Address)
    let tripPlannerController = TripPlannerController()
    let navigationStepsController = NavigationStepsController()
    
    // Create MarkerSets Model - Zhuo Chen
    var markerSets = MarkerSets()
    // Create RouteSets Model - Zhuo Chen
    var routeSets = RouteSets()
    // Current Selected Marker - Zhuo Chen
    var selectedMarker: GMSMarker!
    // Current Selected UIColor - Zhuo Chen
    var selectUIColor: UIColor!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool
    {
        if (selectedMarker != nil && selectedMarker == marker)
        {
            selectedMarker = nil;
        }
        else
        {
            selectedMarker = marker;
        }
        
        return false
    }
    
    func zoomToFitMapMarkers()
    {
        if(self.markerSets.markers.count == 0)
        {
            return
        }
        
        if (self.markerSets.markers.count == 1)
        {
            let marker = self.markerSets.markers[0]
            let location = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
            mapView.camera = GMSCameraPosition(target: location, zoom: 17, bearing: 0, viewingAngle: 0)
            return
        }
        
        var northEastCoord = CLLocationCoordinate2D(latitude: 90, longitude: 180)
    
        var southWestCoord = CLLocationCoordinate2D(latitude: -90, longitude: -180)
    
        for marker in self.markerSets.markers
        {
            northEastCoord.longitude = fmin(northEastCoord.longitude, marker.longitude)
            northEastCoord.latitude = fmin(northEastCoord.latitude, marker.latitude)
    
            southWestCoord.longitude = fmax(southWestCoord.longitude, marker.longitude)
            southWestCoord.latitude = fmax(southWestCoord.latitude, marker.latitude)
        }

        let bounds = GMSCoordinateBounds(coordinate: northEastCoord, coordinate: southWestCoord)
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 30.0))
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
        
        mapView.myLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        // Stop updating location - Zhuo Chen
        locationManager.stopUpdatingLocation()
    }
    
    func addMarker(marker: MarkerModel)
    {
        let position = CLLocationCoordinate2DMake(marker.latitude, marker.longitude)
        let gmsMarker = GMSMarker(position: position)
        gmsMarker.title = marker.name
        gmsMarker.snippet = marker.address
        
        if (selectUIColor != nil)
        {
            let color = selectUIColor
            gmsMarker.icon = GMSMarker.markerImageWithColor(color)
        }
        
        gmsMarker.map = self.mapView
    }
    
    func searchMarker()
    {
        for item in mapTasks.textSearchResults
        {
            // Keep the most important values.
            let marker = MarkerModel()
            let geometry = item["geometry"] as! Dictionary<NSObject, AnyObject>
            
            marker.longitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
            marker.latitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
            marker.name = item["name"] as! String
            marker.address = item["formatted_address"] as! String
            marker.id = item["id"] as! String
            marker.placeId = item["place_id"] as! String
            
            markerSets.markers.append(marker)
            
            self.addMarker(marker)
        }
    }
    
    func searchRoute()
    {
        var item = mapTasks.routeDirectionsResults[0]
        
        let route = RouteModel()
        route.overviewPolyline = item["overview_polyline"] as! Dictionary<NSObject, AnyObject>
        
        let legs = item["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
        route.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
        route.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
        
        route.originAddress = legs[0]["start_address"] as! String
        route.destinationAddress = legs[legs.count - 1]["end_address"] as! String
        
        
        for leg in legs{
            let newLeg = RouteLegs()
            let startLocationDictionary = leg["start_location"] as! Dictionary<NSObject, AnyObject>
            let endLocationDictionary = leg["end_location"] as! Dictionary<NSObject, AnyObject>
            newLeg.startLocation = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
            newLeg.endLocation = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
            newLeg.startName = leg["start_address"] as! String
            newLeg.endName = leg["end_address"] as! String
            newLeg.distance = (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            newLeg.duration = (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            route.legs.append(newLeg)
            
            route.totalDistanceInMeters += newLeg.distance
            route.totalDurationInSeconds += newLeg.duration
            let steps = leg["steps"] as! Array<Dictionary<NSObject, AnyObject>>
            for step in steps
            {
                
                let newStep = RouteStep()
                newStep.distance = (step["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
                newStep.duration = (step["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
                let startStepDictionary = step["start_location"] as! Dictionary<NSObject, AnyObject>
                let endStepDictionary = step["end_location"] as! Dictionary<NSObject, AnyObject>
                newStep.startLocation = CLLocationCoordinate2DMake(startStepDictionary["lat"] as! Double, startStepDictionary["lng"] as! Double)
                newStep.endLocation = CLLocationCoordinate2DMake(endStepDictionary["lat"] as! Double, endStepDictionary["lng"] as! Double)
                newStep.instructions = step["html_instructions"] as! String
                
                route.steps.append(newStep)
            }
            
        }
      
        let distanceInKilometers: Double = Double(route.totalDistanceInMeters / 1000)
        route.totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        let mins = route.totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = route.totalDurationInSeconds % 60
        
        route.totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
        
        partitionRoute(route)

        routeSets.defaultRoute = route
        GlobalRouteModel.globalRoute = route
    }
    
    //return the distance between two points
    func distBetweenPoints(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double
    {
        let longdiff = start.longitude - end.longitude
        let latdiff = start.latitude - end.latitude
        return sqrt((longdiff * longdiff) + (latdiff * latdiff))
    }
    
    //add a waypoint to the route based on a given step
    func addWaypointGivenStep(route: RouteModel, processedStep: RouteStep, overflowFactor: Double)
    {
        //find the center
        let centerLong = (processedStep.startLocation.longitude + processedStep.endLocation.longitude) / 2
        let centerLat = (processedStep.startLocation.latitude + processedStep.endLocation.latitude) / 2
        
        //find the radius
        let searchRadius = Int(distBetweenPoints(processedStep.startLocation, end: processedStep.endLocation) * overflowFactor / 2)
        
        //append this data to route.waypoints
        let waypoint = RouteWaypoint()
        waypoint.radius = searchRadius
        waypoint.location = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        route.wayPoints.append(waypoint)
    }
    
    //use the list of steps stored in the route to generate a list of waypoints to search
    func partitionRoute(route: RouteModel)
    {
        //constant representing the overflow area of a search circle
        let overflowFactor = 1.1
        //constant representing the minimum distance required for a step in meters
        let minstep = 10000
        //constant representing the maximum distance for a step in meters
        let maxstep = 100000 / overflowFactor
        
        //for each step along the route
        for (var x = 0; x < route.steps.count; x++)
        {
            var processedStep = route.steps[x]
            
            //process overly long steps
            if (Double(route.steps[x].distance) > maxstep)
            {
                //set up variables
                let numSubSteps = ceil(Double(route.steps[x].distance) / maxstep)
                let delta = 1.0 / numSubSteps
                let stepstartloc = route.steps[x].startLocation
                let stependloc = route.steps[x].endLocation
                let lngDiff = (stependloc.longitude - stepstartloc.longitude) * delta
                let latDiff = (stependloc.latitude - stepstartloc.latitude) * delta
                
                //for each substep
                var y = 0.0
                while (y < numSubSteps)
                {
                    //get the substep start and end location
                    let subStepStartLoc = CLLocationCoordinate2D(latitude: stepstartloc.latitude + (latDiff * y), longitude: stepstartloc.longitude + (lngDiff * y))
                    y = y + 1
                    let subStepEndLoc = CLLocationCoordinate2D(latitude: stepstartloc.latitude + (latDiff * y), longitude: stepstartloc.longitude + (lngDiff * y))
                    
                    //set up a processed step with those locations and the distance between them
                    processedStep = RouteStep()
                    processedStep.startLocation = subStepStartLoc
                    processedStep.endLocation = subStepEndLoc
                    processedStep.distance = Int(ceil(distBetweenPoints(processedStep.startLocation, end: processedStep.endLocation)))
                    
                    //add a waypoint based on the processed step
                    addWaypointGivenStep(route, processedStep: processedStep, overflowFactor: overflowFactor)
                }
            }
            else
            {
                //process overly short steps
                var sumDistance = 0
                var furthestStep = x - 1
                
                //find the furthest step which has less total distance than the minimum step
                while (sumDistance < minstep && furthestStep < route.steps.count - 1)
                {
                    furthestStep = furthestStep + 1
                    sumDistance = sumDistance + route.steps[furthestStep].distance
                }
                
                //if the furthest step is not the current step make a virtual step using a straight line approximation of the intermediate steps
                if (furthestStep != x)
                {
                    processedStep = RouteStep()
                    processedStep.startLocation = route.steps[x].startLocation
                    processedStep.endLocation = route.steps[furthestStep].endLocation
                    processedStep.distance = Int(ceil(distBetweenPoints(processedStep.startLocation, end: processedStep.endLocation)))
                    x = furthestStep
                }
            
                //add a waypoint based on the processed step
                addWaypointGivenStep(route, processedStep: processedStep, overflowFactor: overflowFactor)
            }
        }
    }
    
    func configureMapAndMarkersForRoute()
    {
        mapView.clear()
        markerSets.markers.removeAll()
        
        originMarker = GMSMarker(position: routeSets.defaultRoute.originCoordinate)
        originMarker.map = self.mapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = "Current Location"
        originMarker.snippet = routeSets.defaultRoute.originAddress
        
        destinationMarker = GMSMarker(position: routeSets.defaultRoute.destinationCoordinate)
        destinationMarker.map = self.mapView
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        
        if (self.selectedMarker != nil)
        {
            destinationMarker.title = self.selectedMarker.title
            destinationMarker.snippet = routeSets.defaultRoute.destinationAddress
        }
        else
        {
            destinationMarker.title = routeSets.defaultRoute.destinationAddress
        }
        
        var northEastCoord = CLLocationCoordinate2D(latitude: 90, longitude: 180)
        var southWestCoord = CLLocationCoordinate2D(latitude: -90, longitude: -180)
        
        northEastCoord.longitude = fmax(originMarker.position.longitude, destinationMarker.position.longitude)
        northEastCoord.latitude = fmax(originMarker.position.latitude, destinationMarker.position.latitude)
        
        southWestCoord.longitude = fmin(originMarker.position.longitude, destinationMarker.position.longitude)
        southWestCoord.latitude = fmin(originMarker.position.latitude, destinationMarker.position.latitude)

        
        for marker in self.markerSets.markers
        {
            northEastCoord.longitude = fmin(northEastCoord.longitude, marker.longitude)
            northEastCoord.latitude = fmin(northEastCoord.latitude, marker.latitude)
            
            southWestCoord.longitude = fmax(southWestCoord.longitude, marker.longitude)
            southWestCoord.latitude = fmax(southWestCoord.latitude, marker.latitude)
        }
        
        let bounds = GMSCoordinateBounds(coordinate: northEastCoord, coordinate: southWestCoord)
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 30.0))
    }
    
    func drawRoute()
    {
        let route = routeSets.defaultRoute.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5
        routePolyline.tappable = true
        routePolyline.strokeColor = UIColor.blueColor()
        routePolyline.map = mapView
        
        for item in routeSets.defaultRoute.wayPoints
        {
            let position = CLLocationCoordinate2DMake(item.location.latitude, item.location.longitude)
            let gmsMarker = GMSMarker(position: position)
            gmsMarker.icon = GMSMarker.markerImageWithColor(UIColor.grayColor())
            
            let query = "lat=" + item.location.latitude.description + "&lon=" + item.location.longitude.description
            let weatherData = WeatherModel()
            weatherController.getCurrentWeather(query, weatherData: weatherData, completionHandler: {(status, success)-> Void in
                if (!success)
                {
                    print(status)
                }
                else
                {
                    gmsMarker.title = "Lon: " + weatherData.lon.description + " Lat: " + weatherData.lat.description
                    gmsMarker.snippet = "Weather: " + weatherData.main + " Description: " + weatherData.des + "\nTemp: " + weatherData.temp.description + " Pressure: " + weatherData.pressure.description + " Humidity: " + weatherData.humidity.description + "\nClouds: " + weatherData.clouds.description + " Wind: " + weatherData.wind.description + " Weights: " + weatherData.weight.description
                }
            })
            
            gmsMarker.map = self.mapView
            
            /*if (RouteInterestPointsModel.interestPoints != nil)
            {
                for (var i = 0; i < RouteInterestPointsModel.interestPoints.count; i++)
                {
                    let query = RouteInterestPointsModel.interestPoints[i]
                    selectUIColor = RouteInterestPointsModel.colors[i]
            
                    self.mapTasks.textSearch(query, location: position, radius: searchRadius, withCompletionHandler: { (status, success) -> Void in
                        if (!success)
                        {
                            print(status)
                
                            if status == "ZERO_RESULTS" {
                                print("The location could not be found.")
                            }
                        }
                        else
                        {
                            self.selectedMarker = nil
                            self.searchMarker()
                        }
                    })
                }
            }*/
        }
        
        selectUIColor = nil
    }
    
    //John Shetler - function to return estimated time between two points
    //Takes two MKMapItem objects corresponding to the start and end points
    //Can be modified to take points in lat, lon form
    //returns travel time in seconds
    func calculateETA(srcPnt: CLLocationCoordinate2D, dstPnt: CLLocationCoordinate2D) -> NSInteger {
        let request = MKDirectionsRequest()
        let src = MKMapItem(placemark: MKPlacemark(coordinate: srcPnt, addressDictionary: nil))
        let dst = MKMapItem(placemark: MKPlacemark(coordinate: dstPnt, addressDictionary: nil))
        request.source = src
        request.destination = dst
        request.requestsAlternateRoutes = false
        request.transportType = MKDirectionsTransportType.Automobile
        let ret = NSInteger()
        let directions = MKDirections(request: request)
        
        /*directions.calculateETAWithCompletionHandler{response, error in
            if error == nil{
                return
            }else{
                if let res = response{
                    ret = NSInteger(res.expectedTravelTime)
                    return
                }
            }
        }*/
        
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
    /*func searchRoute(place: String, points: [CLLocationCoordinate2D], completionHandler: (success: Bool) -> Void)
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
    }*/
}

extension ViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        print(place.description)
        
        place.getDetails { details in
            print(details)
        }
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}