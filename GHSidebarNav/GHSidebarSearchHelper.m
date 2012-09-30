//
//  GHSidebarSearchViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarSearchHelper.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"


#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHSidebarDefaultSearchDelay = 0.8;


#pragma mark -
#pragma mark Private Interface
@interface GHSidebarSearchHelper ()
@property (nonatomic, strong) NSMutableArray *mutableEntries;
@property (weak, nonatomic) UITableView *searchResultsTableView;
@property (weak, nonatomic) UISearchBar *searchBar;
- (void)performSearch;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHSidebarSearchHelper {
	NSOperationQueue *_searchQueue;
	NSTimer *_timer;
//	UIView *_searchBarSuperview;
//	NSUInteger _searchBarSuperIndex;
}

#pragma mark Properties
@synthesize searchDelegate, searchDelay, sidebarVC;
@synthesize mutableEntries, searchResultsTableView, searchBar;

#pragma mark Memory Management
- (id)init {
	if (self = [super init]){
		_searchQueue = [[NSOperationQueue alloc] init];
		_searchQueue.maxConcurrentOperationCount = 1;
		self.searchDelay = kGHSidebarDefaultSearchDelay;
		self.mutableEntries = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)dealloc {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
}

#pragma mark UIViewController
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
	[controller.searchBar setShowsCancelButton:YES animated:YES];
    
	[self.sidebarVC toggleSearch:YES duration:kGHRevealSidebarDefaultAnimationDuration];
	[controller.searchBar becomeFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[tableView reloadData];
    self.searchResultsTableView = tableView;
    self.searchBar = controller.searchBar;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.sidebarVC toggleSearch:NO duration:kGHRevealSidebarDefaultAnimationDuration completion:^(BOOL finished){
		[controller.searchBar resignFirstResponder];
		controller.searchBar.showsCancelButton = NO;
        self.searchBar = nil;
        self.searchResultsTableView = nil;
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
	_timer = [NSTimer scheduledTimerWithTimeInterval:self.searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

#pragma mark Private Methods
- (void)performSearch {
    [_timer invalidate];
	NSString *text = self.searchBar.text;
	NSString *scope = (self.searchBar.showsScopeBar) 
		? self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex] 
		: nil;
	if ([@"" isEqualToString:text]) {
		[self.mutableEntries removeAllObjects];
		[self.searchResultsTableView reloadData];
	} else {
		if (searchDelegate) {
			__block GHSidebarSearchHelper *selfRef = self;
			__block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
				[selfRef.searchDelegate searchResultsForText:text withScope:scope callback:^(NSArray *results){
					if (![operation isCancelled]) {
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							if (![operation isCancelled]) {
								[selfRef.mutableEntries removeAllObjects];
								[selfRef.mutableEntries addObjectsFromArray:results];
								[selfRef.searchResultsTableView reloadData];
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
