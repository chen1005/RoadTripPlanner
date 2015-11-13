//
//  UIColorModel.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/6.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

class UIColorModel: NSObject
{
    var colors = Array<UIColor>()
    
    override init()
    {
        colors.append(UIColor.brownColor())
        colors.append(UIColor.purpleColor())
        colors.append(UIColor.orangeColor())
        colors.append(UIColor.magentaColor())
        colors.append(UIColor.yellowColor())
        colors.append(UIColor.cyanColor())
        colors.append(UIColor.blueColor())
        colors.append(UIColor.greenColor())
        colors.append(UIColor.redColor())
    }
}
