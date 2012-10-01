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
@property (strong, nonatomic) NSOperationQueue *searchQueue;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UISearchDisplayController *searchController;
- (void)performSearch;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHSidebarSearchHelper

#pragma mark Properties
@synthesize searchDelegate, searchDelay, sidebarVC;
@synthesize mutableEntries, searchResultsTableView, searchBar;

#pragma mark Memory Management
- (id)init {
	if (self = [super init]){
		self.searchQueue = [[NSOperationQueue alloc] init];
		self.searchQueue.maxConcurrentOperationCount = 1;
		self.searchDelay = kGHSidebarDefaultSearchDelay;
		self.mutableEntries = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)dealloc {
	[self.timer invalidate];
	[self.searchQueue cancelAllOperations];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDelegate searchController:self.searchController selectedResult:self.mutableEntries[indexPath.row] atIndexPath:indexPath];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mutableEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id entry = self.mutableEntries[indexPath.row];
	return [self.searchDelegate searchResultCellForEntry:entry atIndexPath:indexPath inTableView:tableView];
}

#pragma mark UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[controller.searchBar setShowsCancelButton:YES animated:YES];
	[controller.searchBar becomeFirstResponder];
    [self.searchDelegate searchBegan];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[tableView reloadData];
    self.searchController = controller;
    self.searchResultsTableView = tableView;
    self.searchBar = controller.searchBar;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.searchDelegate searchEnded];
    [controller.searchBar resignFirstResponder];
    controller.searchBar.showsCancelButton = NO;
    self.searchController = nil;
    self.searchBar = nil;
    self.searchResultsTableView = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self.timer invalidate];
	[self.searchQueue cancelAllOperations];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self.timer invalidate];
	[self.searchQueue cancelAllOperations];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

#pragma mark Private Methods
- (void)performSearch {
    [self.timer invalidate];
	NSString *text = self.searchBar.text;
	NSString *scope = (self.searchBar.showsScopeBar) 
		? self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex] 
		: nil;
	if ([@"" isEqualToString:text]) {
		[self.mutableEntries removeAllObjects];
		[self.searchResultsTableView reloadData];
	} else {
		if (self.searchDelegate) {
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
			[self.searchQueue addOperation:operation];
		}
	}
}

@end
