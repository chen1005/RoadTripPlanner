//
//  WeatherModel.swift
//  RoadTripPlanner
//
//  Created by John Phineas Shetler on 10/8/15.
//  Copyright (c) 2015 Rick Chen. All rights reserved.
//

import Foundation

class WeatherModel{
    
    var lat: Int
    var lon: Int
    var wcode: String
    var icode: String
    var weight: Double
    var rain: Double
    var clouds: Int
    var wind: Double
    
    init(){
        self.lat = 0
        self.lon = 0
        self.rain = 0.0
        self.clouds = 0
        self.wind = 0.0
        self.wcode = "000"
        self.icode = "000"
        self.weight = 0.0
    }
    
    func setLat(lat: Int){
        self.lat = lat
    }
    func setLon(lon: Int){
        self.lon = lon
    }
    func setWCode(wcode: String){
        self.wcode = wcode
    }
    func setICode(icode: String){
        self.icode = icode
    }
    func setClouds(clouds: Int){
        self.clouds = clouds
    }
    func setRain(rain: Double){
        self.rain = rain
    }
    func setWind(wind: Double){
        self.wind = wind
    }
    func setIcode(icode: String){
        self.icode = icode
    }
    func setWeight(){
        switch self.wcode {
            //000 = error case
        case "000":
            self.weight = 1.0
            //200-232 = thunderstorm cases
        case "200":
            self.weight = 0.9
        case "201":
            self.weight = 0.80
        case "202":
            self.weight = 0.70
        case "210":
            self.weight = 0.9
        case "211":
            self.weight = 0.85
        case "212":
            self.weight = 0.8
        case "221":
            self.weight = 0.9
        case "230":
            self.weight = 0.85
        case "231":
            self.weight = 0.80
        case "232":
            self.weight = 0.75
            //300-321 = drizzle cases
        case "300":
            self.weight = 0.95
        case "301":
            self.weight = 0.90
        case "302":
            self.weight = 0.85
        case "310":
            self.weight = 0.95
        case "311":
            self.weight = 0.90
        case "312":
            self.weight = 0.85
        case "313":
            self.weight = 0.80
        case "314":
            self.weight = 0.75
        case "321":
            self.weight = 0.80
            //500-531 = rain cases
        case "500":
            self.weight = 0.90
        case "501":
            self.weight = 0.85
        case "502":
            self.weight = 0.75
        case "503":
            self.weight = 0.70
        case "504":
            self.weight = 0.65
        case "511":
            self.weight = 0.60
        case "520":
            self.weight = 0.90
        case "521":
            self.weight = 0.85
        case "522":
            self.weight = 0.75
        case "531":
            self.weight = 0.80
            //600-622 = snow cases
        case "600":
            self.weight = 0.90
        case "601":
            self.weight = 0.80
        case "602":
            self.weight = 0.70
        case "611":
            self.weight = 0.65
        case "612":
            self.weight = 0.65
        case "615":
            self.weight = 0.80
        case "616":
            self.weight = 0.70
        case "620":
            self.weight = 0.80
        case "621":
            self.weight = 0.70
        case "622":
            self.weight = 0.60
            //701-781 = fog, smoke, dust, tornado, etc.
        case "701":
            self.weight = 0.90
        case "711":
            self.weight = 0.90
        case "721":
            self.weight = 0.90
        case "731":
            self.weight = 0.70
        case "741":
            self.weight = 0.70
        case "751":
            self.weight = 0.70
        case "761":
            self.weight = 0.85
        case "762":
            self.weight = 0.55
        case "771":
            self.weight = 0.55
        case "781":
            self.weight = 0.55
            //800-804 = cloud cases
        case "800":
            self.weight = 1.0
        case "801":
            self.weight = 1.0
        case "802":
            self.weight = 1.0
        case "803":
            self.weight = 1.0
        case "804":
            self.weight = 1.0
            //900-906 = extreme weather cases
        case "900":
            self.weight = 0.55
        case "901":
            self.weight = 0.55
        case "902":
            self.weight = 0.45
        case "903":
            self.weight = 1.0
        case "904":
            self.weight = 1.0
        case "905":
            self.weight = 0.90
        case "906":
            self.weight = 0.80
            //951-962 = misc. cases
        case "951":
            self.weight = 1.0
        case "952":
            self.weight = 1.0
        case "953":
            self.weight = 1.0
        case "954":
            self.weight = 0.95
        case "955":
            self.weight = 0.95
        case "956":
            self.weight = 0.90
        case "957":
            self.weight = 0.85
        case "958":
            self.weight = 0.80
        case "959":
            self.weight = 0.75
        case "960":
            self.weight = 0.80
        case "961":
            self.weight = 0.70
        case "962":
            self.weight = 0.45
        default:
            self.weight = 1.0
        }
    }
    
    
    
    
}