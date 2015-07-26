//
//  WebViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/25/15.
//
//

import Foundation


class SWebViewController: UIViewController, UIWebViewDelegate {
    var url = NSURL(string: "")
    var allowZoom: Bool = false
    var refresh: Bool = false
    var myAct : UIActivityIndicatorView!

    var myWebView: UIWebView! = UIWebView()

    override func viewWillAppear(animated: Bool) {
        myAct = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        myAct.hidesWhenStopped = true
        let barItem : UIBarButtonItem = UIBarButtonItem(customView: myAct)
        self.navigationItem.rightBarButtonItem = barItem
        myWebView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: self.view.frame.size.height)
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
    

    
}