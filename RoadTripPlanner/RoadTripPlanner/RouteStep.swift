//
//  RouteStep.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/12/9.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit

class RouteStep: NSObject
{
    var distance:Int! // meter
    var duration:Int! // second
    var startLocation:CLLocationCoordinate2D!
    var endLocation:CLLocationCoordinate2D!
    var instructions:String!
}
