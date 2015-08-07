//
//  WebViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/25/15.
//
//

import Foundation


class SWebViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate {
    var url = NSURL(string: "")
    var allowZoom: Bool = false
    var refresh: Bool = false
    var myAct : UIActivityIndicatorView!
    var urlToLaunch = NSURL(string:"")

    var myWebView: UIWebView! = UIWebView()

    override func viewWillAppear(animated: Bool) {
        myAct = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        myAct.hidesWhenStopped = true
        let barItem : UIBarButtonItem = UIBarButtonItem(customView: myAct)
        self.navigationItem.rightBarButtonItem = barItem
        myWebView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: self.view.bounds.size.height - 113)
        myWebView.delegate = self
        self.view.addSubview(myWebView)
    }
    
    
    override func viewDidLoad(){
        
    }
    
    func startLoadWithURLString(aurlString: String){
        url = NSURL(string: aurlString)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.myWebView.loadRequest(NSURLRequest(URL: self.url!))
        }
    }
    
    func startLoad(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.myWebView.loadRequest(NSURLRequest(URL: self.url!))
        }
    }

    
    func webViewDidStartLoad(webView: UIWebView) {
        myAct.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        myAct.stopAnimating()
    }
    

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.LinkClicked){
            urlToLaunch = request.URL
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = "Leave Wheaton App?"
            alert.message = "Open link in Safari?"
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Okay")
            alert.show()
            return false
        }
        return true
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.sharedApplication().openURL(urlToLaunch!)
        }
    }
    
}