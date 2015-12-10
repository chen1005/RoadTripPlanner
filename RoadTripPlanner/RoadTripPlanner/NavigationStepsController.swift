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
    
    @IBOutlet weak var tableView: UITableView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //add the route steps to the view
        if (GlobalRouteModel.routeModel != nil)
        {
            route = GlobalRouteModel.routeModel
            for step in route.steps
            {
                self.items.append(stripHtml(step.instructions))
            }
        }
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        cell.textLabel?.text = self.items[indexPath.row]
        
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
