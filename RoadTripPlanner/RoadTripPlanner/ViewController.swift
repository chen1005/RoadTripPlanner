//
//  ViewController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/10/7.
//  Copyright (c) 2015年 Rick Chen. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SphereMenuDelegate, WayPointDelegate {
    
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
    let tripPlannerController = TripPlannerController()
    let navigationStepsController = NavigationStepsController()
    let waypointController = WaypointController()
    
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
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UITextField!
    
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
    
    func launchWaypoints()
    {
        self.presentViewController(waypointController, animated:true, completion:nil)
    }
    
    func launchAddWaypoint()
    {
        if (self.selectedMarker != nil && routeSets.defaultRoute != nil)
        {
            let addressAlert = UIAlertController(title: "Add Waypoint", message: "\"" + self.selectedMarker.title + "\"" + " will be added to the route.\n\n" + "What stop number should this be?", preferredStyle: UIAlertControllerStyle.Alert)
            
            addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                    textField.placeholder = "Enter range between " + "(1, " + (GlobalWaypoints.wayPoints.count + 1).description + ")"
            }
            
            let createRouteAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                let order = (addressAlert.textFields![0] as UITextField).text! as String
                let waypoint = self.selectedMarker.snippet
            
                self.selectedMarker.icon = GMSMarker.markerImageWithColor(UIColor.yellowColor())
                
                GlobalWaypoints.wayPoints.insert(waypoint, atIndex: Int(order)! - 1)
            }
            
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
                
            }
            
            addressAlert.addAction(createRouteAction)
            addressAlert.addAction(closeAction)
            
            presentViewController(addressAlert, animated: true, completion: nil)
        }
        else
        {
            var message = ""
            
            if (self.selectedMarker == nil)
            {
                message = "No waypoint selected"
            }
            else if (self.routeSets.defaultRoute == nil)
            {
                message = "No route created"
            }
            
            showErrorAlert(message)
        }
    }
    
    func launchRoutePlanner()
    {
        self.presentViewController(tripPlannerController, animated:true, completion:nil)
    }
    
    func launchNavigation()
    {
        if (routeSets.defaultRoute != nil)
        {
            if (routeSets.defaultRoute.steps.count > 0)
            {
                self.presentViewController(navigationStepsController, animated:true, completion:nil)
            }
        }
        else
        {
            let message = "No route created"
            showErrorAlert(message)
        }
    }
    
    func launchRouteCalculator()
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
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.searchRoute()
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute(true)
                    self.zoomToFitMapPartition()
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
        
        searchView.layer.masksToBounds = true
        searchView.layer.cornerRadius = 10
        
        let start = UIImage(named: "start")
        let image1 = UIImage(named: "interestPoint")
        let image2 = UIImage(named: "waypoint")
        let image3 = UIImage(named: "addWaypoint")
        let image4 = UIImage(named: "route")
        let image5 = UIImage(named: "navigation")
        let images:[UIImage] = [image1!,image2!,image3!,image4!,image5!]
        let menu = SphereMenu(startPoint: CGPointMake(35, 45), startImage: start!, submenuImages:images, tapToDismiss:true)
        menu.delegate = self
        self.view.addSubview(menu)
        
        waypointController.delegate = self
        mapView.delegate = self
    }
    
    func sphereDidSelected(index: Int) {
        switch index
        {
            case 0:
                self.launchRoutePlanner()
                break
            case 1:
                self.launchWaypoints()
                break
            case 2:
                self.launchAddWaypoint()
                break
            case 3:
                self.launchRouteCalculator()
                break
            case 4:
                self.launchNavigation()
                break
            
            default:
                break
        }
    }
    
    func recalculateTaped()
    {
        self.mapTasks.getDirections(self.routeSets.defaultRoute.originAddress, destination: self.routeSets.defaultRoute.destinationAddress, waypoints: GlobalWaypoints.wayPoints, travelMode: nil, completionHandler: { (status, success) -> Void in
            if success {
                self.searchRoute()
                self.configureMapAndMarkersForRoute()
                self.drawRoute(false)
                self.zoomToFitMapPartition()
            }
            else {
                print(status)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showErrorAlert(message: String)
    {
        let addressAlert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
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
    
    func zoomToFitMapPartition(){
        
        if(routeSets.defaultRoute.partitionPoints.count == 0){
            return
        }
        
        if(routeSets.defaultRoute.partitionPoints.count == 1){
            let location = CLLocationCoordinate2D(latitude: routeSets.defaultRoute.partitionPoints[0].location.latitude, longitude: routeSets.defaultRoute.partitionPoints[0].location.longitude)
            mapView.camera = GMSCameraPosition(target: location, zoom: 17, bearing: 0, viewingAngle: 0)
            return
        }
        
        var northEastCoord = CLLocationCoordinate2D(latitude: 90, longitude: 180)
        var southWestCoord = CLLocationCoordinate2D(latitude: -90, longitude: -180)
        
        for partition in routeSets.defaultRoute.partitionPoints{
            northEastCoord.longitude = fmin(northEastCoord.longitude, partition.location.longitude)
            northEastCoord.latitude = fmin(northEastCoord.latitude, partition.location.latitude)
            
            southWestCoord.longitude = fmax(southWestCoord.longitude, partition.location.longitude)
            southWestCoord.latitude = fmax(southWestCoord.latitude, partition.location.latitude)
            
        }
        let bounds = GMSCoordinateBounds(coordinate: northEastCoord, coordinate: southWestCoord)
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 30.0))
        
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
            newLeg.distance = (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
            newLeg.duration = (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
            route.legs.append(newLeg)
            
            route.totalDistanceInMeters = route.totalDistanceInMeters + newLeg.distance
            route.totalDurationInSeconds = route.totalDurationInSeconds + newLeg.duration
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
        GlobalRouteModel.routeModel = route
    }
    
    //return the distance between two points
    func distBetweenPoints(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Double
    {
        let lat1 = start.latitude
        let lon1 = start.longitude
        let lat2 = end.latitude
        let lon2 = end.longitude
        
        let R = 6378.137; // Radius of earth in KM
        let dLat = (lat2 - lat1) * M_PI / 180;
        let dLon = (lon2 - lon1) * M_PI / 180;
        var a = sin(dLat/2) * sin(dLat/2)
        a += cos(lat1 * M_PI / 180) * cos(lat2 * M_PI / 180) *
            sin(dLon/2) * sin(dLon/2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let d = R * c;
        return d * 1000; // meters
    }
    
    //add a partitionpoint to the route based on a given step
    func addPartitionPointGivenStep(route: RouteModel, processedStep: RouteStep, overflowFactor: Double)
    {
        //find the center
        let centerLong = (processedStep.startLocation.longitude + processedStep.endLocation.longitude) / 2
        let centerLat = (processedStep.startLocation.latitude + processedStep.endLocation.latitude) / 2
        
        //find the radius
        let searchRadius = Int(distBetweenPoints(processedStep.startLocation, end: processedStep.endLocation) * overflowFactor / 2)
        
        //append this data to route.partionPoints
        let partitionPoint = RoutePartitionPoint()
        partitionPoint.radius = searchRadius
        partitionPoint.location = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        route.partitionPoints.append(partitionPoint)
    }
    
    //use the list of steps stored in the route to generate a list of partitionPoints to search
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
                    
                    //add a partitionpoint based on the processed step
                    addPartitionPointGivenStep(route, processedStep: processedStep, overflowFactor: overflowFactor)
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
            
                //add a partitionpoint based on the processed step
                addPartitionPointGivenStep(route, processedStep: processedStep, overflowFactor: overflowFactor)
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
    
    func drawRoute(performTextSearch: Bool)
    {
        let route = routeSets.defaultRoute.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5
        routePolyline.tappable = true
        routePolyline.strokeColor = UIColor.blueColor()
        routePolyline.map = mapView
        
        
        for item in routeSets.defaultRoute.partitionPoints
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
                    gmsMarker.snippet = "Weather: " + weatherData.main + " Description: " + weatherData.des + "\nTemp: " + weatherData.temp.description + " Pressure: " + weatherData.pressure.description + " Humidity: " + weatherData.humidity.description + "\nClouds: " + weatherData.clouds.description + " Wind: " + weatherData.wind.description + " Weight: " + weatherData.weight.description
                    
                    //Sum up
                    self.routeSets.defaultRoute.totalRadiusInMeters += Double(item.radius)
                    self.routeSets.defaultRoute.adjustedRadiusInMeters += (Double(item.radius) / weatherData.weight)
                }
            })
            
            gmsMarker.map = self.mapView
            
            if (performTextSearch)
            {
                if (RouteInterestPointsModel.interestPoints != nil)
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
                }
            }
        }
        
        selectUIColor = nil
    }
}