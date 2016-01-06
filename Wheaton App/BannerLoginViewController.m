//
//  BannerLoginViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 2/19/14.
//
//

#import "BannerLoginViewController.h"
#import "GSKeychain.h"

@interface BannerLoginViewController ()

@end

@implementation BannerLoginViewController

@synthesize email, password, storecreds, myCookie, chapelSkips, activity, loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void) barButtonTapped
{
    if (email.text.length <= 0 && password.text.length <= 0) {
        return;
    }
    
    else {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.hidesWhenStopped = true;
        [activity startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
        
        [[GSKeychain systemKeychain] setSecret:email.text forKey:@"myUsername"];
        [[GSKeychain systemKeychain] setSecret:password.text forKey:@"myPassword"];
        [self setEditing:NO animated:YES];
        [self attemptLogin];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"storeCredentials"]){
        [storecreds setOn:YES];
        email.text =[[GSKeychain systemKeychain] secretForKey:@"myUsername"];
        password.text = [[GSKeychain systemKeychain] secretForKey:@"myPassword"];
        [loginButton setEnabled:TRUE];
    }
    else {
        [storecreds setOn:NO];
    }
}

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(barButtonTapped)];
    [loginButton setEnabled:false];
    
    self.navigationItem.rightBarButtonItem = loginButton;
    [password addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [email addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}


-(void) textFieldDidChange:(UITextField *)pwField
{
    if(email.text.length > 0 && password.text.length > 0){
        [loginButton setEnabled:TRUE];
    }
    else {
        [loginButton setEnabled:FALSE];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0){
    return 2;
    }
    return 1;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (email.text.length <= 0 && password.text.length <= 0) {
        return NO;
    }
    
    else {
        [textField resignFirstResponder];
        return YES;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"2");

    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    myCookie = [fields valueForKey:@"Set-Cookie"];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"1");

    NSString *theResp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([theResp containsString:@"This system requires the use of HTTP cookies"]){
        NSLog(@"Cookies");
        //NSLog(@"\n\n\nW000T %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self attemptLogin];
    }
    else if([theResp containsString:@"<meta http-equiv="]){
        NSLog(@"First login");
        //NSLog(@"\n\n\nFIRST LOGIN: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self obtainChapelSkips];
    }
    else if([theResp containsString:@"Invalid login information"]){
        NSLog(@"Bad login");
        //NSLog(@"Bad login: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        chapelSkips = [[NSMutableArray alloc] init];
        [chapelSkips addObject:@"Check username and password"];
        [[GSKeychain systemKeychain] removeSecretForKey:@"myUsername"];
        [[GSKeychain systemKeychain] removeSecretForKey:@"myPassword"];
        
        NSString *theskips = [chapelSkips componentsJoinedByString:@"\n"];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Unable to log in"
                                                          message:theskips
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    else {
        NSLog(@"\n\n\nSKIPS: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        chapelSkips = [[NSMutableArray alloc] init];

        NSString *firstString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRange   firstRange = NSMakeRange(0, [firstString length]);
        NSString *firstpattern = @"<TH CLASS=\"ddheader\" scope=\"col\" >Current Seat:</TH>((.|\n)+?)</TR>";
        NSError  *error = nil;
        
        NSRegularExpression* firstregex = [NSRegularExpression regularExpressionWithPattern: firstpattern options:0 error:&error];
        NSArray* firstmatches = [firstregex matchesInString:firstString options:0 range: firstRange];
        for (NSTextCheckingResult* match in firstmatches) {
            NSString* matchText = [firstString substringWithRange:[match range]];
            NSLog(@"match: %@", matchText);
            matchText = [matchText stringByReplacingOccurrencesOfString:@"<TH CLASS=\"ddheader\" scope=\"col\" >Current Seat:</TH>" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"<TD CLASS=\"dddead\">&nbsp;" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"<TD CLASS=\"dddefault\">" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"</TD>" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"</TR>" withString:@""];

            [chapelSkips addObject:[NSString stringWithFormat:@"Seat: %@", [matchText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]]];
        }
        
        
        //chapel skips
        NSString *searchedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"<TD CLASS=\"dddefault\">(.+?)-(.+?)-(.+?)</TD>";
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        //chapelSkips = [[NSMutableArray alloc] init];
        [chapelSkips addObject:@"Recorded chapel skips:"];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            NSLog(@"match: %@", matchText);
            matchText = [matchText stringByReplacingOccurrencesOfString:@"<TD CLASS=\"dddefault\">" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"</TD>" withString:@""];
            [chapelSkips addObject:matchText];
        }
        
        
        //update user defaults with switch state
        [[NSUserDefaults standardUserDefaults] setBool:[storecreds isOn] forKey:@"storeCredentials"];
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"storeCredentials"]){
            //don't store credentials if the switch isn't on
            [[GSKeychain systemKeychain] removeSecretForKey:@"myUsername"];
            [[GSKeychain systemKeychain] removeSecretForKey:@"myPassword"];
        }

        NSString *theskips = [chapelSkips componentsJoinedByString:@"\n"];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Successful Login"
                                                          message:theskips
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Successful Banner Login" properties:@{}];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}



- (void) obtainChapelSkips
{
    NSURL *URL = [NSURL URLWithString:@"https://bannerweb.wheaton.edu/db1/wcskchpl.P_WCViewChapl"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"term=201601"];
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    [request addValue:myCookie forHTTPHeaderField:@"Cookie"];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLConnection *c = [NSURLConnection connectionWithRequest:request delegate:self];
        [c start];
    //});
}




- (void) attemptLogin
{
    [activity startAnimating];
    
    NSDictionary *user = @{
                           @"username": [[GSKeychain systemKeychain] secretForKey:@"myUsername"],
                           @"password": [[GSKeychain systemKeychain] secretForKey:@"myPassword"],
                           @"uuid": [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"],
                           @"token": [[NSUserDefaults standardUserDefaults] objectForKey:@"token"] };
    
    NSURL *URL = [NSURL URLWithString:@"https://bannerweb.wheaton.edu/db1/twbkwbis.P_ValLogin"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"sid=%@&PIN=%@", [user objectForKey:@"username"],[user objectForKey:@"password"]];
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    [request addValue:myCookie forHTTPHeaderField:@"Cookie"];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLConnection *c = [NSURLConnection connectionWithRequest:request delegate:self];
        [c start];
    //});
}



@end
