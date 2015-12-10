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
    let baseURL: String = "http://api.openweathermap.org/data/2.5/"
    let curWeather: String = "weather?"
    let apiKey: String = "&APPID=07d154bfbea534e77404c65ec5838e67"
    
    //Make a GET request to the OpenWeatherMap API and return a Weather Model object with the
    //retrieved data
    //Queries in the form of:
    //City ID:      "id=223465234"
    //City Name:    "q=London" or q=London,uk"
    //Coordinates:  "lat=34&lon=122"
    //Zipcode:      "zip=47906"

    func getCurrentWeather(query: String!, weatherData: WeatherModel, completionHandler: ((status: String, success: Bool)->Void)){
        
        let queryURLString = baseURL + curWeather + query + apiKey
        let queryURL = NSURL(string: queryURLString)
        print(queryURL)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var status: String
            let weatherResultsData = NSData(contentsOfURL: queryURL!)
            
            if (weatherResultsData == nil)
            {
                status = "FAILED"
                
                completionHandler(status: status, success: false)
            }
            
            status = "OK"
            
            let dictionary: Dictionary<NSObject, AnyObject> = ((try! NSJSONSerialization.JSONObjectWithData(weatherResultsData!, options: NSJSONReadingOptions.MutableContainers)) as! Dictionary<NSObject, AnyObject>)
        
            let coord = (dictionary["coord"] as! Dictionary<NSObject, AnyObject>)
            let weather = (dictionary["weather"] as! Array<Dictionary<NSObject, AnyObject>>)
            let main = (dictionary["main"] as! Dictionary<NSObject, AnyObject>)
            let cloud = (dictionary["clouds"] as! Dictionary<NSObject, AnyObject>)
            let wind = (dictionary["wind"] as! Dictionary<NSObject, AnyObject>)
                
            weatherData.setLat(coord["lat"] as! Double)
            weatherData.setLon(coord["lon"] as! Double)
            weatherData.setWCode(weather[0]["id"] as! Int)
            weatherData.setICode(weather[0]["icon"] as! String)
            weatherData.setMain(weather[0]["main"] as! String)
            weatherData.setDes(weather[0]["description"] as! String)
            weatherData.setTemp(main["temp"] as! Double)
            weatherData.setPressure(main["pressure"] as! Int)
            weatherData.setHumidity(main["humidity"] as! Int)
            weatherData.setMaxTemp(main["temp_max"] as! Double)
            weatherData.setMinTemp(main["temp_min"] as! Double)
            weatherData.setClouds(cloud["all"] as! Int)
            weatherData.setWind(wind["speed"] as! Double)
            weatherData.setWeight()
            
            completionHandler(status: status, success: true)
        })
    }


/*    func getCurrentWeather(query: String)-> WeatherModel{
        //Initialize instance of WeatherModel
        let weatherData = WeatherModel()
        //build the URL
        
        var queryURLString = baseURL + curWeather + query + apiKey
        queryURLString = queryURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let queryURL = NSURL(string: queryURLString)
        print(queryURLString)
        
        //make the connection
        let request = NSURLRequest(URL: queryURL!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            //print(data)
            //print(response)
            //print(error)
            //serialize json response object as NSDictionary
            do{
                print("Hi I am here!")
                print(data)
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if(jsonResponse != nil){
                    //set weatherData values
                    weatherData.setLat((jsonResponse!["coord"] as! NSDictionary)["lat"]! as! Double)
                    weatherData.setLon((jsonResponse!["coord"] as! NSDictionary)["lon"]! as! Double)
                    weatherData.setWCode((jsonResponse!["weather"] as! NSDictionary)["id"]! as! String)
                    weatherData.setICode((jsonResponse!["weather"] as! NSDictionary)["icon"]! as! String)
                    weatherData.setWeight()
                }
            }catch{
                
                
            }
        }).resume()
        
        //return WeatherModel object
        return weatherData
    }
*/
}
