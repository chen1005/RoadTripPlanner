//
//  MapTasks.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/4.
//  Copyright (c) 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit

class MapTasksController: NSObject
{
    // Google Keys
    let apiKey = "AIzaSyAEuoPxT43YjP704p9Tfmhp_1AeZNcMERM"
    let serverKey = "AIzaSyBZHE8rmZS2n9Tke2Eg-Y_etXzYj6g38II"
    
    // Google Geocode Search - Zhuo Chen
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"

    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    // Google Text Search - Zhuo Chen
    let baseURLTextSearch = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
    var textSearchResults: Array<Dictionary<NSObject, AnyObject>>!
    
    // Google Route Calculatation - Zhuo Chen
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var routeDirectionsResults: Array<Dictionary<NSObject, AnyObject>>!
    
    override init()
    {
        super.init()
    }
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void))
    {
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let geocodeURL = NSURL(string: geocodeURLString)
            print(geocodeURL)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                
                let dictionary: Dictionary<NSObject, AnyObject> = (try! NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers)) as! Dictionary<NSObject, AnyObject>
                
                // Get the response status.
                let status = dictionary["status"] as! String
                    
                if status == "OK" {
                    let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                    self.lookupAddressResults = allResults[0]
                        
                    // Keep the most important values.
                    self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                    let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                    self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                    self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                    completionHandler(status: status, success: true)
                }
                else {
                    completionHandler(status: status, success: false)
                }
            })
        }
        else {
            completionHandler(status: "No valid address.", success: false)
        }
    }
    
    func textSearch(query: String!, location: CLLocationCoordinate2D!, radius: Int!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void))
    {
        var textSearchURLString = baseURLTextSearch + "query=" + query + "&location=" + location.latitude.description + "," + location.longitude.description + "&radius=" + radius.description + "&key=" + serverKey
        textSearchURLString = textSearchURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
        let textSearchURL = NSURL(string: textSearchURLString)
            
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let textSearchResultsData = NSData(contentsOfURL: textSearchURL!)
                
            let dictionary: Dictionary<NSObject, AnyObject> = (try! NSJSONSerialization.JSONObjectWithData(textSearchResultsData!, options: NSJSONReadingOptions.MutableContainers)) as! Dictionary<NSObject, AnyObject>
                
            // Get the response status.
            let status = dictionary["status"] as! String
            
            if (status == "OK")
            {
                let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                self.textSearchResults = allResults;
                    
                completionHandler(status: status, success: true)
            }
            else {
                completionHandler(status: status, success: false)
            }
        })
    }
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void))
    {
        if let originLocation = origin {
            if let destinationLocation = destination
            {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + apiKey
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                
                print(directionsURLString)
                
                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    let dictionary: Dictionary<NSObject, AnyObject> = (try! NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers)) as! Dictionary<NSObject, AnyObject>
                    
                    let status = dictionary["status"] as! String
                        
                    if (status == "OK")
                    {
                        self.routeDirectionsResults = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)
                            
                        completionHandler(status: status, success: true)
                    }
                    else {
                        completionHandler(status: status, success: false)
                    }
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
}
