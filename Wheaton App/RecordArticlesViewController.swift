//
//  RecordArticlesViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/1/15.
//
//

import UIKit


class RecordArticlesViewController: UITableViewController, XMLParserDelegate {
    
    var xmlParser : XMLParser!
    var myAct : UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if(xmlParser == nil){
        let url = NSURL(string: "http://www.wheatonrecord.com/feed/")
        xmlParser = XMLParser()
        xmlParser.delegate = self
        myAct = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        myAct.hidesWhenStopped = true
        let barItem : UIBarButtonItem = UIBarButtonItem(customView: myAct)
        self.navigationItem.rightBarButtonItem = barItem
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            
        Mixpanel.sharedInstance().track("Opened Record Feed")

        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.myAct.startAnimating()
            self.xmlParser.startParsingWithContentsOfURL(url!)
            dispatch_async(dispatch_get_main_queue()) {
                self.myAct.stopAnimating()
                self.parsingWasFinished()
            }
        }
        }
        
    }
    
    
    
    // MARK: XMLParserDelegate method implementation
    
    func parsingWasFinished() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xmlParser.arrParsedData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "record")
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 70)
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
        
        if let currentDictionary = xmlParser.arrParsedData[indexPath.row] as? Dictionary<String, String>{
            cell.textLabel!.text = currentDictionary["title"]
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(!myAct.isAnimating()){
            return "Most Recent"
        }
        else {
            return "Loading articles..."
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(sender)
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict = xmlParser.arrParsedData[indexPath.row] as Dictionary<String, String>
        let loadThis: String = dict["link"]!
        
        let alert = UIAlertController(title: "Open Safari?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Read Article", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                Mixpanel.sharedInstance().track("Opened Record Article", properties:["title":dict["title"]!])
                UIApplication.sharedApplication().openURL(NSURL(string:loadThis)!)
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        /*
        let toPush = SWebViewController()
        self.navigationController?.pushViewController(toPush, animated: true)
        toPush.startLoadWithURLString(loadThis)
*/
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        let label = UILabel(frame:CGRectMake(10,2,200,20))
        label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerView.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 244/255.0, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.backgroundColor = UIColor.clearColor()
        headerView.addSubview(label)
        return headerView
    }
    
}
