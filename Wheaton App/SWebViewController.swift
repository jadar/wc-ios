//
//  WebViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/25/15.
//
//

import Foundation


class SWebViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate {
    var url = URL(string: "")
    var allowZoom: Bool = false
    var refresh: Bool = false
    var myAct : UIActivityIndicatorView!
    var urlToLaunch = URL(string:"")

    var myWebView: UIWebView! = UIWebView()

    override func viewWillAppear(_ animated: Bool) {
        myAct = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        myAct.hidesWhenStopped = true
        let barItem : UIBarButtonItem = UIBarButtonItem(customView: myAct)
        self.navigationItem.rightBarButtonItem = barItem
        myWebView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: self.view.bounds.size.height - 113)
        myWebView.delegate = self
        self.view.addSubview(myWebView)
    }
    
    func startLoadWithURLString(_ aurlString: String){
        url = URL(string: aurlString)
        DispatchQueue.global(qos: .userInitiated).async {
            self.myWebView.loadRequest(URLRequest(url: self.url!))
        }
    }
    
    func startLoadWithHTMLString(_ ahtmlString: String){
        DispatchQueue.global(qos: .userInitiated).async {
            self.myWebView.loadHTMLString(ahtmlString, baseURL: nil)
        }
    }
    
    func startLoad() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.myWebView.loadRequest(URLRequest(url: self.url!))
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        myAct.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myAct.stopAnimating()
    }
    

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.linkClicked){
            urlToLaunch = request.url
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = "Leave Wheaton App?"
            alert.message = "Open link in Safari?"
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Okay")
            alert.show()
            return false
        }
        return true
    }
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.shared.openURL(urlToLaunch!)
        }
    }
}
