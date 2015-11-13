//
//  TripPlannerController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/11/6.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

class TripPlannerController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var items: [String] = []
    var itemsColors = Array<UIColor>()
    var uiColorIndex = 0;
    let uiColors = UIColorModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func mapViewTap(sender: AnyObject)
    {
        RouteInterestPointsModel.interestPoints = items
        RouteInterestPointsModel.colors = itemsColors
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func addInterestPoint(sender: AnyObject)
    {
        let addAlert = UIAlertController(title: "Add Interest Point", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        addAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Enter Interest Point"
        }
        
        let createRouteAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let newItem = (addAlert.textFields![0] as UITextField).text! as String
            self.items.append(newItem)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.items.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addAlert.addAction(createRouteAction)
        addAlert.addAction(closeAction)
        
        presentViewController(addAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
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
        cell.backgroundColor = uiColors.colors[uiColorIndex]
        self.itemsColors.append(uiColors.colors[uiColorIndex])
        uiColorIndex++
        
        if (uiColorIndex == uiColors.colors.count)
        {
            uiColorIndex = 0
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            itemsColors.removeAtIndex(indexPath.row)
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
