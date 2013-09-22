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
@implementation GHSidebarSearchViewController {
@private
	GHRevealViewController *_sidebarVC;
	NSOperationQueue *_searchQueue;
	NSTimer *_timer;
	UIView *_searchBarSuperview;
	NSUInteger _searchBarSuperIndex;
}

#pragma mark Properties
@synthesize searchDisplayController;

- (UISearchBar *)searchBar {
	return searchDisplayController.searchBar;
}

- (NSArray *)entries {
	return _mutableEntries;
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

- (void)viewDidLayoutSubviews {
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        CGRect viewBounds = self.view.frame;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset,
                                     viewBounds.size.width, viewBounds.size.height);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_searchDelegate) {
		[_searchDelegate searchResult:_mutableEntries[indexPath.row] selectedAtIndexPath:indexPath];
	}
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mutableEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (_searchDelegate) {
		id entry = _mutableEntries[indexPath.row];
		cell = [_searchDelegate searchResultCellForEntry:entry atIndexPath:indexPath inTableView:tableView];
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
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    controller.searchResultsTableView.alpha = 0.0;
    [_sidebarVC toggleSearch:NO withSearchView:self.view duration:kGHRevealSidebarDefaultAnimationDuration completion:^(BOOL finished){
		[self.searchBar resignFirstResponder];
		[self.searchBar removeFromSuperview];
		self.searchBar.showsCancelButton = NO;
		[_searchBarSuperview insertSubview:self.searchBar atIndex:_searchBarSuperIndex];
		_searchBarSuperview = nil;
	}];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
	_timer = [NSTimer scheduledTimerWithTimeInterval:_searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[_timer invalidate];
	[_searchQueue cancelAllOperations];
	_timer = [NSTimer scheduledTimerWithTimeInterval:_searchDelay target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
	return NO;
}

#pragma mark Private Methods
- (void)performSearch {
	NSString *text = self.searchBar.text;
	NSString *scope = (self.searchBar.showsScopeBar) 
		? self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex] 
		: nil;
	if ([@"" isEqualToString:text]) {
		[_mutableEntries removeAllObjects];
		[searchDisplayController.searchResultsTableView reloadData];
	} else {
		if (_searchDelegate) {
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
