//
//  SearchAnnotation.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/10/8.
//  Copyright (c) 2015年 Rick Chen. All rights reserved.
//

import UIKit
import MapKit

class AnnotationModel: NSObject, MKAnnotation {
    var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title:String!
    
    init(coordinate:CLLocationCoordinate2D, title:String)
    {
        self.coordinate = coordinate;
        self.title = title;
    }
}
