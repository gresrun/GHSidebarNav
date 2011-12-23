//
//  GHSidebarSearchViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarSearchViewController.h"
#import "GHSidebarViewController.h"
#import "GHSidebarMenuCell.h"


#pragma mark Constants
const CGFloat kSearchDelay = 0.8f;


#pragma mark Private Interface
@interface GHSidebarSearchViewController ()
@property(nonatomic, readwrite, strong) UISearchDisplayController *searchDisplayController;
@property(nonatomic, strong) NSMutableArray *entries;
- (void)performSearch;
@end


#pragma mark Implementation
@implementation GHSidebarSearchViewController

#pragma mark -
#pragma mark Properties
@synthesize entries;
@synthesize searchDisplayController;

- (UISearchBar *)searchBar {
	return self.searchDisplayController.searchBar;
}

#pragma mark -
#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHSidebarViewController *)sidebarVC {
	if (self = [super initWithNibName:nil bundle:nil]){
		_sidebarVC = sidebarVC;
		_searchQueue = [[NSOperationQueue alloc] init];
		_searchQueue.maxConcurrentOperationCount = 1;
		self.entries = [[NSMutableArray alloc] initWithCapacity:3];
		self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[[UISearchBar alloc] init] contentsController:self];
		self.searchDisplayController.delegate = self;
		self.searchDisplayController.searchResultsDataSource = self;
		self.searchDisplayController.searchResultsDelegate = self;
		self.searchDisplayController.searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
		self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		self.searchBar.backgroundImage = [UIImage imageNamed:@"SearchBarBG.png"];
		self.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
		for (UIView *subview in self.searchBar.subviews) {
			if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *searchTextField = (UITextField *) subview;
				searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
			}
		}
	}
	return self;
}

#pragma mark -
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

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Do something with selected row here
	NSLog(@"Search Results - selected %@", [self.entries objectAtIndex:indexPath.row]);
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"GHSidebarSearchMenuCell";
	GHSidebarMenuCell *cell = (GHSidebarMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHSidebarMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.text = [self.entries objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageNamed:@"user.png"];
	return cell;
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
	[_sidebarVC toggleSearch:YES withSearchTable:nil animated:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
	[_sidebarVC toggleSearch:YES withSearchTable:tableView animated:NO];
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[_sidebarVC toggleSearch:NO withSearchTable:searchDisplayController.searchResultsTableView animated:YES];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[self.entries removeAllObjects];
	[self.searchDisplayController.searchResultsTableView reloadData];
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

#pragma mark -
#pragma mark Private Methods
- (void)performSearch {
	NSString *searchString = searchDisplayController.searchBar.text;
	if ([@"" isEqualToString:searchString]) {
		[self.entries removeAllObjects];
		[self.searchDisplayController.searchResultsTableView reloadData];
	} else {
		__block GHSidebarSearchViewController *selfRef = self;
		[_searchQueue addOperationWithBlock:^{ // Simulate loading data from web service
			NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:3];
			[tmp addObject:@"Foo"];
			[tmp addObject:@"Bar"];
			[tmp addObject:@"Baz"];
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[selfRef.entries removeAllObjects];
				[selfRef.entries addObjectsFromArray:tmp];
				[selfRef.searchDisplayController.searchResultsTableView reloadData];
			}];
		}];
	}
}

@end
