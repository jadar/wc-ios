//
//  BannerLoginViewController.h
//  Wheaton App
//
//  Created by Chris Anderson on 2/19/14.
//
//

#import <UIKit/UIKit.h>

@interface BannerLoginViewController : UITableViewController <UITextFieldDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *storecreds;
@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) UIBarButtonItem *loginButton;
@property (nonatomic, retain) NSString *myCookie;
@property (nonatomic, retain) NSMutableArray *chapelSkips;

-(void)attemptLogin;
-(void)obtainChapelSkips;

@end
