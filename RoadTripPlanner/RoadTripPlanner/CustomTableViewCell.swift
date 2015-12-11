//
//  CustomTableViewCell.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/12/10.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var textCell: UITextField!
    @IBOutlet weak var viewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewCell.layer.masksToBounds = true
        viewCell.layer.cornerRadius = 10
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        self.viewCell.addGestureRecognizer(swipeGesture)
        
        //左划
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left //不设置是右
        self.viewCell.addGestureRecognizer(swipeLeftGesture)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        //划动的方向
        let direction = sender.direction
        //判断是上下左右
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            print("Left")
            break
        case UISwipeGestureRecognizerDirection.Right:
            viewCell.backgroundColor = UIColor.grayColor()
            print("Right")
            break
        case UISwipeGestureRecognizerDirection.Up:
            print("Up")
            break
        case UISwipeGestureRecognizerDirection.Down:
            print("Down")
            break
        default:
            break;
        }
    }
}
