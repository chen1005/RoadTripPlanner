//
//  WeatherController.swift
//  RoadTripPlanner
//
//  Created by John Phineas Shetler on 10/8/15.
//  Copyright (c) 2015 Rick Chen. All rights reserved.
//
//  OpenWeatherMap API Key: e0f310752151ec1bb8269d3d8233019a
//

import Foundation

class WeatherController: NSObject{
    
    //Constant strings for building api query
    let baseURL: String = "api.openweathermap.org/data/2.5/"
    let curWeather: String = "weather?q="
    let apiKey: String = "&APPID=e0f310752151ec1bb8269d3d8233019a"
    
    
    //Make a GET request to the OpenWeatherMap API and return a Weather Model object with the
    //retrieved data
    //Queries in the form of:
    //City ID:      "id=223465234"
    //City Name:    "London" or "London,uk"
    //Coordinates:  "lat=34&lon=122"
    //Zipcode:      "zip=47906"
    func getCurrentWeather(query: String)-> WeatherModel{
        //Initialize instance of WeatherModel
        let weatherData = WeatherModel()
        //build the URL
        let queryURL = "\(baseURL)\(curWeather)\(query)\(apiKey)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: queryURL)
        request.HTTPMethod = "GET"
        //make the URL connection
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            //serialize json response object as NSDictionary
            let jsonResponse = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            if(jsonResponse != nil){
                //set weatherData values
                weatherData.setLat((jsonResponse!["coord"] as! NSDictionary)["lat"]! as! Double)
                weatherData.setLon((jsonResponse!["coord"] as! NSDictionary)["lon"]! as! Double)
                weatherData.setWCode((jsonResponse!["weather"] as! NSDictionary)["id"]! as! String)
                weatherData.setICode((jsonResponse!["weather"] as! NSDictionary)["icon"]! as! String)
                weatherData.setWeight()
            }
        })
        //return WeatherModel object
        return weatherData
    }
    
    
}
