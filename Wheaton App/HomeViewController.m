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
    
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showWhosWho:[MTReachabilityManager isReachableViaWiFi]];

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
    return YES;
}

- (void)performSearch:(NSTimer *)timer
{
    NSString *searchString = [timer userInfo];
    
    //NSLog(@"Perform Search");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{ @"name": searchString, @"limit": @"20" };
    [manager GET:c_Whoswho parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *resultsArray = responseObject;
        searchResults = [[NSMutableArray alloc] init];
        
        for (NSDictionary* dic in resultsArray) {
            NSDictionary *name = [dic objectForKey:@"name"];
            
            Person *person = [[Person alloc] init];
            person.firstName = [name objectForKey:@"first"];
            person.prefName = [name objectForKey:@"preferred"];
            person.lastName = [name objectForKey:@"last"];
            person.email = [dic objectForKey:@"email"];
            person.uid = [dic objectForKey:@"schoolID"];
            
            person.classification = @"N/A";
            if (![[dic objectForKey:@"classification"] isEqual:[NSNull null]]) {
                person.classification = [dic objectForKey:@"classification"];
            }
            
            person.cpo = @"N/A";
            if (![[dic objectForKey:@"address"] isEqual:[NSNull null]]) {
                person.cpo = [dic objectForKey:@"address"];
            }
            person.photo = [[[dic objectForKey:@"image"] objectForKey:@"url"] objectForKey:@"medium"];
            [searchResults addObject:person];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}





- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
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
