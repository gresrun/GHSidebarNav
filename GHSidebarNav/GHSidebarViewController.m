//
//  GHSidebarViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarViewController.h"
#import "GHSidebarMenuCell.h"
#import "GHSidebarSearchViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Constants
NSString const *kSidebarCellTextKey = @"CellText";
NSString const *kSidebarCellImageKey = @"CellImage";
const CGFloat kSidebarAnimationDuration = 0.3f;
const CGFloat kSidebarWidth = 260.0f;


#pragma mark Private Interface
@interface GHSidebarViewController ()
@property(nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property(nonatomic, readwrite, getter = isSearching) BOOL searching;
- (void)hideSidebar;
- (CGRect)calculateSidebarFrame:(BOOL)showingSearch;
- (CGRect)calculateSideTableFrame:(BOOL)showingSearch;
@end


#pragma mark Implementation
@implementation GHSidebarViewController

#pragma mark -
#pragma mark Properties
@synthesize sidebarShowing;
@synthesize searching;

#pragma mark -
#pragma mark Memory Management
- (id)initWithHeaders:(NSArray *)headers withContollers:(NSArray *)controllers withCellInfos:(NSArray *)cellInfos {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.sidebarShowing = NO;
		self.searching = NO;
		_menuHeaders = headers;
		_menuControllers = controllers;
		_menuCellInfos = cellInfos;
		_tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebar)];
		_tapRecog.cancelsTouchesInView = YES;
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSidebarWidth, CGRectGetHeight(self.view.bounds))];
	_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
	_sidebarView.backgroundColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	[self.view addSubview:_sidebarView];
	_contentView = [[UIView alloc] initWithFrame:self.view.bounds];
	_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0.0f);
	_contentView.layer.masksToBounds = NO;
	_contentView.layer.shadowColor = [UIColor blackColor].CGColor;
	_contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	_contentView.layer.shadowOpacity = 1.0f;
	_contentView.layer.shadowRadius = 2.5f;
	_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
	[self.view addSubview:_contentView];
	
	_searchVC = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self];
	[_searchVC willMoveToParentViewController:self];
	[_sidebarView addSubview:_searchVC.searchBar];
	[_searchVC.searchBar sizeToFit];
	[_searchVC didMoveToParentViewController:self];
	
	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSidebarWidth, CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_menuTableView.frame = [self calculateSideTableFrame:NO];
	[_sidebarView addSubview:_menuTableView];
	
	NSIndexPath *initialPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[_menuTableView selectRowAtIndexPath:initialPath animated:NO scrollPosition:UITableViewScrollPositionTop];
	_selectedContentVC = [[_menuControllers objectAtIndex:initialPath.section] objectAtIndex:initialPath.row];
	_selectedContentVC.view.frame = _contentView.bounds;
	[_contentView addSubview:_selectedContentVC.view];
	[self addChildViewController:_selectedContentVC];
	[_selectedContentVC didMoveToParentViewController:self];
	
	self.sidebarShowing = YES;
	self.searching = NO;
	[self toggleSidebar:NO animated:NO];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[_searchVC.view removeFromSuperview];
	[_searchVC removeFromParentViewController];
	_searchVC = nil;
	[_selectedContentVC.view removeFromSuperview];
	[_selectedContentVC removeFromParentViewController];
	_selectedContentVC = nil;
	[_menuTableView removeFromSuperview];
	_menuTableView = nil;
	[_sidebarView removeFromSuperview];
	_sidebarView = nil;
	[_contentView removeFromSuperview];
	_contentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	BOOL doAutorotate = NO;
	switch (orientation) {
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationPortrait:
			doAutorotate = YES;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			doAutorotate = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
			break;
	}
	UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (doAutorotate && self.isSearching &&
		curOrientation != UIDeviceOrientationFaceUp && 
		curOrientation != UIDeviceOrientationFaceDown && 
		curOrientation != UIDeviceOrientationUnknown && 
		curOrientation != orientation) {
		CGRect screenRect = [UIScreen mainScreen].bounds;
		screenRect = UIDeviceOrientationIsPortrait(orientation) 
		? CGRectMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect), 
					 CGRectGetWidth(screenRect), CGRectGetWidth(screenRect))
		: CGRectMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect), 
					 CGRectGetHeight(screenRect), CGRectGetHeight(screenRect));
		_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(screenRect), 0.0f);
		_sidebarView.frame = screenRect;
		[_searchVC.searchBar sizeToFit];
	}
	return doAutorotate;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (self.isSearching) {
		_searchVC.searchDisplayController.searchResultsTableView.frame = [self calculateSideTableFrame:YES];
		CGRect screenRect = [UIScreen mainScreen].bounds;
		screenRect = UIDeviceOrientationIsPortrait(curOrientation) 
		? screenRect
		: CGRectMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect), CGRectGetHeight(screenRect), CGRectGetWidth(screenRect));
		_sidebarView.frame = screenRect;
	}
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_menuHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_menuCellInfos objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHSidebarMenuCell";
    GHSidebarMenuCell *cell = (GHSidebarMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHSidebarMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = [[_menuCellInfos objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.textLabel.text = [info objectForKey:kSidebarCellTextKey];
	cell.imageView.image = [info objectForKey:kSidebarCellImageKey];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSObject *headerText = [_menuHeaders objectAtIndex:section];
	return (headerText == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = [_menuHeaders objectAtIndex:section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = [NSArray arrayWithObjects:
						   (id)[[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f] CGColor], 
						   (id)[[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f] CGColor], 
						   nil];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 0.8f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		textLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(129.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(78.0f/255.0f) green:(86.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(36.0f/255.0f) green:(42.0f/255.0f) blue:(5.0f/255.0f) alpha:1.0f];
		[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *prevContentVC = _selectedContentVC;
	_selectedContentVC = [[_menuControllers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	_selectedContentVC.view.frame = _contentView.bounds;
	if (prevContentVC == nil) { // First time
		[_contentView addSubview:_selectedContentVC.view];
		[self addChildViewController:_selectedContentVC];
		[_selectedContentVC didMoveToParentViewController:self];
	} else if (prevContentVC != _selectedContentVC) { // Transition only if they are not the same
		[prevContentVC willMoveToParentViewController:nil];
		[self addChildViewController:_selectedContentVC];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:prevContentVC 
						  toViewController:_selectedContentVC 
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{} 
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[prevContentVC removeFromParentViewController];
								}
		 ];
		[_selectedContentVC didMoveToParentViewController:self];
	}
	[self toggleSidebar:NO animated:YES];
}

#pragma mark -
#pragma mark Public Methods
- (void)toggleSidebar:(BOOL)show animated:(BOOL)animate {
	if (animate) {
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:kSidebarAnimationDuration];
	}
    if (show) {
        _contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0.0f);
		[_contentView addGestureRecognizer:_tapRecog];
    } else {
		if (self.isSearching) {
			_sidebarView.frame = [self calculateSidebarFrame:NO];
		} else {
			[_contentView removeGestureRecognizer:_tapRecog];
		}
		_contentView.frame = _contentView.bounds;
	}
    self.sidebarShowing = show;
	if (animate) {
		[UIView commitAnimations];
	}
}

- (void)toggleSearch:(BOOL)showSearch withSearchTable:(UITableView *)searchTable animated:(BOOL)animate {
	if (animate) {
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:kSidebarAnimationDuration];
	}
	_sidebarView.frame = [self calculateSidebarFrame:showSearch];
	_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0.0f);
	if (showSearch) {
		[_contentView removeGestureRecognizer:_tapRecog];
		[_menuTableView removeFromSuperview];
		if (searchTable != nil) {
			searchTable.frame = [self calculateSideTableFrame:showSearch];
			[_sidebarView addSubview:searchTable];
		}
	} else {
		[_contentView addGestureRecognizer:_tapRecog];
		_menuTableView.frame = [self calculateSideTableFrame:showSearch];
		[searchTable removeFromSuperview];
		[_sidebarView addSubview:_menuTableView];
	}
    self.sidebarShowing = YES;
	self.searching = showSearch;
	if (animate) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO animated:YES];
}

- (CGRect)calculateSidebarFrame:(BOOL)showingSearch {
	CGRect bounds = self.view.bounds;
	CGFloat frameWidth = (showingSearch) ? CGRectGetWidth(bounds) : kSidebarWidth;
	return CGRectMake(0.0f, 0.0f, frameWidth, CGRectGetHeight(bounds));
}

- (CGRect)calculateSideTableFrame:(BOOL)showingSearch {
	CGRect bounds = self.view.bounds;
	CGFloat searchBarHeight = CGRectGetHeight(_searchVC.searchBar.frame);
	CGFloat frameWidth = (showingSearch) ? CGRectGetWidth(bounds) : kSidebarWidth;
	return CGRectMake(0.0f, searchBarHeight, frameWidth, CGRectGetHeight(bounds) - searchBarHeight);
}

@end
