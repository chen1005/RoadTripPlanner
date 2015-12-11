//
//  WaypointController.swift
//  RoadTripPlanner
//
//  Created by Rick Chen on 15/12/10.
//  Copyright © 2015年 Rick Chen. All rights reserved.
//

import UIKit

protocol WayPointDelegate{
    func recalculateTaped()
}

class WaypointController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var delegate:WayPointDelegate?
    var items: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func mapViewTap(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func recalculateTap(sender: AnyObject)
    {
        self.delegate?.recalculateTaped()
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.registerNib(UINib(nibName:"CustomTableViewCell", bundle:nil), forCellReuseIdentifier:"CustomTableViewCell")
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        while (items.count > 0)
        {
            self.items.removeAtIndex(0)
            self.tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
        
        for item in GlobalWaypoints.wayPoints
        {
            self.items.append(item)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.items.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell{
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell") as! CustomTableViewCell
        cell.textCell.text = self.items[indexPath.row]
        cell.viewCell.backgroundColor = UIColor.yellowColor()
        
        return cell
    }
    
    func tableView(tableView:UITableView,   heightForRowAtIndexPath indexPath:NSIndexPath) ->CGFloat{
        return 70
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
