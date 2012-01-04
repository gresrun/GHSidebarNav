//
//  GHSidebarSearchViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarSearchViewController.h"
#import "GHRevealViewController.h"
#import "GHMenuCell.h"


#pragma mark -
#pragma mark Constants
const CGFloat kSearchDelay = 0.8f;


#pragma mark -
#pragma mark Private Interface
@interface GHSidebarSearchViewController ()
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray *entries;
- (void)performSearch;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHSidebarSearchViewController

#pragma mark Properties
@synthesize searchDelegate;
@synthesize entries;
@synthesize searchDisplayController;

- (UISearchBar *)searchBar {
	return searchDisplayController.searchBar;
}

#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC {
	if (self = [super initWithNibName:nil bundle:nil]){
		_sidebarVC = sidebarVC;
		_searchQueue = [[NSOperationQueue alloc] init];
		_searchQueue.maxConcurrentOperationCount = 1;
		
		self.entries = [[NSMutableArray alloc] initWithCapacity:3];
		
		self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[[UISearchBar alloc] init] contentsController:self];
		searchDisplayController.delegate = self;
		searchDisplayController.searchResultsDataSource = self;
		searchDisplayController.searchResultsDelegate = self;
		
		self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
		self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		self.searchBar.backgroundImage = [UIImage imageNamed:@"SearchBarBG.png"];
		self.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
		self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		for (UIView *subview in self.searchBar.subviews) {
			if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *searchTextField = (UITextField *) subview;
				searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
			}
		}
	}
	return self;
}

#pragma mark UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		case UIInterfaceOrientationPortraitUpsideDown:
			return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	}
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Do something with selected row here
	NSLog(@"Search Results - selected: %@", [entries objectAtIndex:indexPath.row]);
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"GHSearchMenuCell";
	GHMenuCell *cell = (GHMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.text = [entries objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageNamed:@"user.png"];
	return cell;
}

#pragma mark UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	_searchBarSuperview = self.searchBar.superview;
	_searchBarSuperIndex = [_searchBarSuperview.subviews indexOfObject:self.searchBar];
	
	[self.searchBar removeFromSuperview];
	[self.view addSubview:self.searchBar];
	[self.searchBar sizeToFit];
	self.searchBar.showsCancelButton = YES;
	
	[_sidebarVC toggleSearch:YES withSearchView:self.view animated:YES];
	[self.searchBar becomeFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:searchDisplayController.searchResultsTableView];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[_sidebarVC toggleSearch:NO withSearchView:self.view animated:YES completion:^(BOOL finished){
		[self.searchBar removeFromSuperview];
		self.searchBar.showsCancelButton = NO;
		[_searchBarSuperview insertSubview:self.searchBar atIndex:_searchBarSuperIndex];
		[self.searchBar sizeToFit];
		
		[entries removeAllObjects];
		[searchDisplayController.searchResultsTableView reloadData];
		
		_searchBarSuperview = nil;
	}];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[self.searchBar resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[_timer invalidate];
	_timer = [NSTimer scheduledTimerWithTimeInterval:kSearchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[_timer invalidate];
	_timer = [NSTimer scheduledTimerWithTimeInterval:kSearchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

#pragma mark Private Methods
- (void)performSearch {
	NSString *text = self.searchBar.text;
	NSString *scope = (self.searchBar.showsScopeBar) 
		? [self.searchBar.scopeButtonTitles objectAtIndex:self.searchBar.selectedScopeButtonIndex] 
		: nil;
	if ([@"" isEqualToString:text]) {
		[entries removeAllObjects];
		[searchDisplayController.searchResultsTableView reloadData];
	} else {
		if (searchDelegate) {
			__block GHSidebarSearchViewController *selfRef = self;
			[_searchQueue addOperationWithBlock:^{
				NSArray *tmp = [selfRef.searchDelegate searchResultsForText:text withScope:scope];
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					[selfRef.entries removeAllObjects];
					[selfRef.entries addObjectsFromArray:tmp];
					[selfRef.searchDisplayController.searchResultsTableView reloadData];
				}];
			}];
		}
	}
}

@end
