//
//  TripPlannerController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/6.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

class NavigationStepsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var items: [String] = []
    var itemsColors = Array<UIColor>()
    var uiColorIndex = 0;
    let uiColors = UIColorModel()
    var route : RouteModel!
    
    @IBOutlet weak var textHeader: UILabel!
    
    @IBAction func mapViewTap(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func stripHtml(toEdit: String) -> String
    {
        var processedStepString = ""
        var insideTag = false
        for charac in toEdit.characters
        {
            if (insideTag)
            {
                if (charac == ">")
                {
                    insideTag = false
                }
            }
            else
            {
                if (charac == "<")
                {
                    insideTag = true
                }
                else
                {
                    processedStepString.append(charac)
                }
            }
        }
        return processedStepString
    }
    
    func parseDistance(dist: Int) -> String
    {
        var toRet: String
        
        if (dist >= 1000)
        {
            toRet = String(ceil(Double(dist) / 1000))
            toRet = toRet + " km"
        }
        else
        {
            toRet = String(dist)
            toRet = toRet + " m"
        }
        
        return toRet
    }
    
    func parseDuration(var dur: Int) -> String
    {
        if (dur > 60)
        {
            dur = Int(ceil(Double(dur) / 60.0))
            let hours = Int(floor(Double(dur) / 60.0))
            let minutes = dur % 60
            
            if (hours == 0)
            {
                return minutes.description + " minutes"
            }
            else
            {
                return hours.description + " h, " + minutes.description + " m"
            }
        }
        else
        {
            return "Less than 1 minute"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (GlobalRouteModel.routeModel != nil)
        {
            route = GlobalRouteModel.routeModel
            
            //Adjusted time is proportional to the average weather weight
            route.adjustedDurationInSeconds = Int(round(Double(route.totalDurationInSeconds) * (route.adjustedRadiusInMeters / route.totalRadiusInMeters)))
            
            //add the totals at the top of the view
            textHeader.text = "Total Distance: " + parseDistance(route.totalDistanceInMeters)) + "\n" + "Total Time: " + parseDuration(route.totalDurationInSeconds)) + "\n" + "Total With Weather: " + parseDuration(route.adjustedDurationInSeconds))
            
            //add the route steps to the view
            for step in route.steps
            {
                self.items.append(stripHtml(step.instructions))
                let estimationString = "   " + parseDistance(step.distance) + " - " + parseDuration(step.duration)
                self.items.append(estimationString)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        //NGH - wrap overflowing direction lines
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        //NGH - make the header cells a different color
        //if (self.items[indexPath.row].componentsSeparatedByString(" ")[0] == "Total")
        //{
            //cell.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        //}
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("You selected cell #\(indexPath.row)!")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
