//
//  WebViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 12/6/13.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.activityView.hidesWhenStopped = YES;

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    if (self.allowZoom == YES) {
        [self.webView setScalesPageToFit:YES];
    }
    
    [self.webView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    if (webview.isLoading)
        return;
    [self.activityView stopAnimating];
    /*
    if(self.url)
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened Menu" properties:@{}];
     */
}

- (void)viewDidLayoutSubviews
{
    if (self.allowResize != NO) {
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
