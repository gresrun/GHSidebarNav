//
//  GHSidebarSearchViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarSearchViewController.h"
#import "GHRevealViewController.h"


#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHSidebarDefaultSearchDelay = 0.8;


#pragma mark -
#pragma mark Private Interface
@interface GHSidebarSearchViewController ()
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray *mutableEntries;
- (void)performSearch;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHSidebarSearchViewController

#pragma mark Properties
@synthesize searchDelegate, searchDelay;
@synthesize searchDisplayController, mutableEntries;

- (UISearchBar *)searchBar {
	return searchDisplayController.searchBar;
}

- (NSArray *)entries {
	return mutableEntries;
}

#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC {
	if (self = [super initWithNibName:nil bundle:nil]){
		_sidebarVC = sidebarVC;
		_searchQueue = [[NSOperationQueue alloc] init];
		_searchQueue.maxConcurrentOperationCount = 1;
		
		self.searchDelay = kGHSidebarDefaultSearchDelay;
		self.mutableEntries = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[[UISearchBar alloc] init] contentsController:self];
		searchDisplayController.delegate = self;
		searchDisplayController.searchResultsDataSource = self;
		searchDisplayController.searchResultsDelegate = self;
	}
	return self;
}

- (void)dealloc {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
}

#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (searchDelegate) {
		[searchDelegate searchResult:mutableEntries[indexPath.row] selectedAtIndexPath:indexPath];
	}
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mutableEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (searchDelegate) {
		id entry = mutableEntries[indexPath.row];
		cell = [searchDelegate searchResultCellForEntry:entry atIndexPath:indexPath inTableView:tableView];
	}
	return cell;
}

#pragma mark UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	_searchBarSuperview = self.searchBar.superview;
	_searchBarSuperIndex = [_searchBarSuperview.subviews indexOfObject:self.searchBar];
	
	[self.searchBar removeFromSuperview];
	[self.view addSubview:self.searchBar];
	[self.searchBar sizeToFit];
	[self.searchBar setShowsCancelButton:YES animated:YES];
	
	[_sidebarVC toggleSearch:YES withSearchView:self.view duration:kGHRevealSidebarDefaultAnimationDuration];
	[self.searchBar becomeFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:searchDisplayController.searchResultsTableView];
	[searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[_sidebarVC toggleSearch:NO withSearchView:self.view duration:kGHRevealSidebarDefaultAnimationDuration completion:^(BOOL finished){
		[self.searchBar resignFirstResponder];
		[self.searchBar removeFromSuperview];
		self.searchBar.showsCancelButton = NO;
		[_searchBarSuperview insertSubview:self.searchBar atIndex:_searchBarSuperIndex];
		_searchBarSuperview = nil;
	}];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
	_timer = [NSTimer scheduledTimerWithTimeInterval:searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
	_timer = [NSTimer scheduledTimerWithTimeInterval:searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

#pragma mark Private Methods
- (void)performSearch {
	NSString *text = self.searchBar.text;
	NSString *scope = (self.searchBar.showsScopeBar) 
		? self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex] 
		: nil;
	if ([@"" isEqualToString:text]) {
		[mutableEntries removeAllObjects];
		[searchDisplayController.searchResultsTableView reloadData];
	} else {
		if (searchDelegate) {
			__block GHSidebarSearchViewController *selfRef = self;
			__block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
				[selfRef.searchDelegate searchResultsForText:text withScope:scope callback:^(NSArray *results){
					if (![operation isCancelled]) {
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							if (![operation isCancelled]) {
								[selfRef.mutableEntries removeAllObjects];
								[selfRef.mutableEntries addObjectsFromArray:results];
								[selfRef.searchDisplayController.searchResultsTableView reloadData];
							}
						}];
					}
				}];
			}];
			[_searchQueue addOperation:operation];
		}
	}
}

@end
