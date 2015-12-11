//
//  RouteModel.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/5.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit

class RouteModel: NSObject
{
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    var totalDistanceInMeters = 0
    var totalDistance: String!
    var totalDurationInSeconds = 0
    var adjustedDurationInSeconds = 0
    var totalRadiusInMeters = 0.0
    var adjustedRadiusInMeters = 0.0
    var totalDuration: String!
    var partitionPoints = Array<RoutePartitionPoint>()
    var steps = Array<RouteStep>()
    var legs = Array<RouteLegs>()
    
    override init()
    {
    }
}
