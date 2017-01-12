//
//  RecordArticlesViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/1/15.
//
//

import UIKit


class RecordArticlesViewController: UITableViewController, WheatonXMLParserDelegate {
    var xmlParser : WheatonXMLParser!
    var myAct : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Mixpanel.sharedInstance().track("Opened Record Feed")
        
        // Don't set up the XML parser if it's not necessary. (How can viewDidLoad be called multiple times anyways?)
        if let _ = xmlParser {
            return
        }
        
        myAct = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        myAct.hidesWhenStopped = true
        let barItem : UIBarButtonItem = UIBarButtonItem(customView: myAct)
        self.navigationItem.rightBarButtonItem = barItem
        
        xmlParser = WheatonXMLParser()
        xmlParser.delegate = self
        
        let url = URL(string: "http://www.wheatonrecord.com/feed/")!
        DispatchQueue.global(qos: .userInitiated).async {
            self.myAct.startAnimating()
            self.xmlParser.startParsingWithContentsOfURL(url)
            DispatchQueue.main.async {
                self.myAct.stopAnimating()
                self.parsingWasFinished()
            }
        }
    }
    
    // MARK: XMLParserDelegate method implementation
    
    func parsingWasFinished() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xmlParser.arrParsedData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "record")
        cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10)
        
        if let currentDictionary = xmlParser.arrParsedData[indexPath.row] as? Dictionary<String, String>{
            cell.textLabel!.text = currentDictionary["title"]
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(!myAct.isAnimating){
            return "Most Recent"
        }
        else {
            return "Loading articles..."
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = xmlParser.arrParsedData[indexPath.row] as Dictionary<String, String>
        let loadThis: String = dict["link"]!
        
        let alert = UIAlertController(title: "Open Safari?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Read Article", style: .default, handler: { action in
            switch action.style{
            case .default:
                Mixpanel.sharedInstance().track("Opened Record Article", properties:["title":dict["title"]!])
                UIApplication.shared.openURL(URL(string:loadThis)!)
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        let label = UILabel(frame:CGRect(x: 10,y: 2,width: 200,height: 20))
        label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerView.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 244/255.0, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.backgroundColor = UIColor.clear
        headerView.addSubview(label)
        return headerView
    }
}
