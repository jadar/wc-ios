//
//  HomeViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/11/13.
//
//

#import "HomeViewController.h"
#import "WhosWhoDetailViewController.h"
#import "WhoswhoTableCell.h"
#import "HomePastViewController.h"
#import "Person.h"


@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize switchViewControllers, allViewControllers, currentViewController, viewContainer, searchResults;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.searchDisplayController.searchBar.placeholder = @"Who's Who";
    self.searchDisplayController.searchBar.clipsToBounds = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UITextView *searchTextField = [self.searchDisplayController.searchBar valueForKey:@"_searchField"];
    searchTextField.textColor = [UIColor whiteColor];
    CGRect tmpFrame = self.searchDisplayController.searchResultsTableView.frame;
    self.searchDisplayController.searchResultsTableView.frame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.width, self.view.frame.size.height);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened Home" properties:@{}];
    
    [[MTReachabilityManager sharedManager] reachability].reachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showWhosWho:YES];
        });
    };
    [[MTReachabilityManager sharedManager] reachability].unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showWhosWho:NO];
        });
    };
    
    HomePastViewController *pVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PastHome"];
    
    pVC.view.frame = CGRectMake(0,
                                0,
                                CGRectGetWidth(self.viewContainer.bounds),
                                CGRectGetHeight(self.viewContainer.bounds));
    
    [self addChildViewController:pVC];
    [self.viewContainer addSubview:pVC.view];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self showWhosWho:[MTReachabilityManager isReachableViaWiFi]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}


- (void)showWhosWho:(BOOL)show
{
    if (show) {
        [self.searchDisplayController.searchBar setUserInteractionEnabled:YES];
        [self.searchDisplayController.searchBar setPlaceholder:@"Who's Who"];
    } else {
        [self.searchDisplayController.searchBar setUserInteractionEnabled:NO];
        [self.searchDisplayController.searchBar setPlaceholder:@"Who's Who: Connect to Campus WiFi"];
    }
}


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}




- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [LVDebounce fireAfter:0.5 target:self selector:@selector(performSearch:) userInfo:searchString];
    return NO;
}

- (void)performSearch:(NSTimer *)timer
{
    
    NSLog(@"Perform Search");
    
    //[searchResults removeAllObjects];
    //[self.searchDisplayController.searchResultsTableView reloadData];
    NSString *searchString = [timer userInfo];
    
    if(![searchString isEqualToString:@""]){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *parameters = @{ @"q": searchString, @"page_size":@"20", };
        [manager GET:c_Whoswho parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"RESPONSE: %@",[responseObject objectForKey:@"page"] );
            //if([[responseObject objectForKey:@"page"] isEqualToString:@"0"]){
            NSArray *resultsArray = [responseObject objectForKey:@"search_results"];
            NSArray *sortedArray = [resultsArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 valueForKey:@"FirstName"] compare:[obj2 valueForKey:@"FirstName"]];
            }];
            
            searchResults = [[NSMutableArray alloc] initWithCapacity:sortedArray.count];
            
            for (NSDictionary* dic in sortedArray) {
                //NSDictionary *name = [dic objectForKey:@"name"];
                if([[dic objectForKey:@"Type"] isEqualToString:@"2"]){
                    Person *person = [[Person alloc] init];
                    person.firstName = [dic objectForKey:@"FirstName"];
                    person.prefName = [dic objectForKey:@"PrefFirstName"];
                    person.lastName = [dic objectForKey:@"LastName"];
                    person.email = [dic objectForKey:@"Email"];
                    //person.uid = [dic objectForKey:@"IdCardNum"];
                    
                    person.classification = @"N/A";
                    if (![[dic objectForKey:@"Classification"] isEqual:[NSNull null]]) {
                        person.classification = [dic objectForKey:@"Classification"];
                    }
                    
                    person.cpo = @"N/A";
                    if (![[dic objectForKey:@"CPOBox"] isEqual:[NSNull null]]) {
                        person.cpo = [dic objectForKey:@"CPOBox"];
                    }
                    person.photo =  [dic objectForKey:@"PhotoUrl"];
                    [searchResults addObject:person];
                }
            }
            
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            //}
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
}





- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillHide
{
    CGRect tmpFrame = self.searchDisplayController.searchResultsTableView.frame;
    self.searchDisplayController.searchResultsTableView.frame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.width, self.view.frame.size.height);
    [self.searchDisplayController.searchResultsTableView setShowsVerticalScrollIndicator:NO];

    //[tableView setContentInset:UIEdgeInsetsZero];
    //[tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"WhoswhoTableCell";
    WhoswhoTableCell *cell = (WhoswhoTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Person *person = (Person *)[searchResults objectAtIndex:indexPath.row];
    
    cell.firstName.text = [NSString stringWithFormat:@"%@", [person fullName]];
    
    NSString *imagename = person.photo;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imagename]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    
    [cell.profileImage setImageWithURLRequest:request
                             placeholderImage:[UIImage imageNamed:@"default-image"]
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          cell.profileImage.image = image;
                                      }
                                      failure:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        Person *selectedPerson = (Person *)[self.searchResults objectAtIndex:indexPath.row];
        
        WhosWhoDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"WhosWhoDetail"];

        detail.title = selectedPerson.firstName;

        detail.person = selectedPerson;

        [self.navigationController pushViewController:detail animated:YES];
    }
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
