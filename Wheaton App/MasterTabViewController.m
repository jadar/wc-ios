//
//  MasterTabViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/7/13.
//
//

#import "MasterTabViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


NSString * const c_MapLocations = @"https://s3.amazonaws.com/wcstatic/location.json";
NSString * const c_Chapel = @"https://s3.amazonaws.com/wcstatic/chapel.json";
NSString * const c_Menu = @"http://wheatonorientation.herokuapp.com/menu";
NSString * const c_Whoswho = @"http://23.21.107.65/people?contentType=json&limit=20&name=";
NSString * const c_Sports = @"http://23.21.107.65/events/type/sport?contentType=json";
NSString * const c_Academic = @"http://25livepub.collegenet.com/calendars/event-collections-general_calendar_wp.rss";
NSString * const c_Banners = @"https://s3.amazonaws.com/wcstatic/banners.json";
NSString * const c_Events = @"http://25livepub.collegenet.com/calendars/intra-campus-calendar.rss";

@interface MasterTabViewController ()

@end

@implementation MasterTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UITabBar appearance] setTintColor:UIColorFromRGB(0xe36f1e)];
    self.delegate = self;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
