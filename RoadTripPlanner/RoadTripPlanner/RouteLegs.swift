//
//  RouteStops.swift
//  RoadTripPlanner
//
//  Created by John Phineas Shetler on 12/10/15.
//  Copyright (c) 2015 Rick Chen. All rights reserved.
//

import UIKit
import MapKit

class RouteLegs: NSObject{
    
    var startLocation: CLLocationCoordinate2D!
    var endLocation: CLLocationCoordinate2D!
    var startName: String!
    var endName: String!
    var distance: UInt!
    var duration: UInt!
}