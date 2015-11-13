//
//  RouteSets.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/5.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

class RouteSets: NSObject
{
    var defaultRoute: RouteModel!
    var alternativeRoutes = Array<RouteModel>()
    
    override init()
    {
    }
}
