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
#define kSidebarAnimationDuration 0.3
#define kSidebarWidth 260.0


#pragma mark Private Interface
@interface GHSidebarViewController ()
- (void)hideSidebar;
- (CGRect)calculateSidebarFrame:(BOOL)searching;
- (CGRect)calculateSideTableFrame:(BOOL)searching;
@end


#pragma mark Implementation
@implementation GHSidebarViewController

#pragma mark -
#pragma mark Properties
@synthesize sidebarShowing = _isSidebarShowing, searching = _isSearching;

#pragma mark -
#pragma mark Memory Management
- (id)initWithHeaders:(NSArray *)headers withContollers:(NSArray *)controllers withCellInfos:(NSArray *)cellInfos {
	if (self = [super initWithNibName:nil bundle:nil]) {
		_menuHeaders = headers;
		_menuControllers = controllers;
		_menuCellInfos = cellInfos;
		_isSidebarShowing = NO;
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
	
	_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSidebarWidth, CGRectGetHeight(self.view.bounds))];
	_sidebarView.backgroundColor = [UIColor colorWithRed:0.196 green:0.224 blue:0.29 alpha:1.0];
	_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
	[self.view addSubview:_sidebarView];
	_contentView = [[UIView alloc] initWithFrame:self.view.bounds];
	_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0);
	[self.view addSubview:_contentView];
	
	_searchVC = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self];
	[_searchVC willMoveToParentViewController:self];
	[_sidebarView addSubview:_searchVC.searchBar];
	[_searchVC.searchBar sizeToFit];
	[_searchVC didMoveToParentViewController:self];
	
	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSidebarWidth, CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
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
	
	_isSidebarShowing = YES;
	_isSearching = NO;
	[self toggleSidebar:NO animated:NO];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	_menuTableView = nil;
	_searchVC = nil;
	_selectedContentVC = nil;
	_sidebarView = nil;
	_contentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		switch (orientation) {
			case UIInterfaceOrientationPortrait:
			case UIInterfaceOrientationLandscapeLeft:
			case UIInterfaceOrientationLandscapeRight:
				return YES;
			default:
				return NO;
		}
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	if (orientation != UIDeviceOrientationFaceUp && 
		orientation != UIDeviceOrientationFaceDown && 
		orientation != UIDeviceOrientationUnknown && 
		fromInterfaceOrientation != orientation) {
		if (_isSearching) {
			CGRect screenRect = [UIScreen mainScreen].bounds;
			screenRect = UIDeviceOrientationIsPortrait(orientation) 
				? screenRect
				: CGRectMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect), 
							 CGRectGetHeight(screenRect), CGRectGetWidth(screenRect));
			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(screenRect), 0);
			_sidebarView.frame = screenRect;
			_searchVC.searchDisplayController.searchResultsTableView.frame = [self calculateSideTableFrame:YES];
			[_searchVC.searchBar sizeToFit];
		}
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
	return (headerText == [NSNull null]) ? 0 : 21;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = [_menuHeaders objectAtIndex:section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 21)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = [NSArray arrayWithObjects:
						   (id)[[UIColor colorWithRed:(67.0/255.0) green:(74.0/255.0) blue:(94.0/255.0) alpha:1.0] CGColor], 
						   (id)[[UIColor colorWithRed:(57.0/255.0) green:(64.0/255.0) blue:(82.0/255.0) alpha:1.0] CGColor], 
						   nil];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12, 5)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 0.8)];
		textLabel.shadowOffset = CGSizeMake(0, 1);
		textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
		textLabel.textColor = [UIColor colorWithRed:(125.0/255.0) green:(129.0/255.0) blue:(146.0/255.0) alpha:1.0];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 1)];
		topLine.backgroundColor = [UIColor colorWithRed:(78.0/255.0) green:(86.0/255.0) blue:(103.0/255.0) alpha:1.0];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 21, [UIScreen mainScreen].bounds.size.height, 1)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(36.0/255.0) green:(42.0/255.0) blue:(5.0/255.0) alpha:1.0];
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
								   options:UIViewAnimationOptionLayoutSubviews
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
        _contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0);
		[_contentView addGestureRecognizer:_tapRecog];
    } else {
		if (_isSearching) {
			_sidebarView.frame = [self calculateSidebarFrame:NO];
		} else {
			[_contentView removeGestureRecognizer:_tapRecog];
		}
		_contentView.frame = _contentView.bounds;
	}
	if (animate) {
		[UIView commitAnimations];
	}
    _isSidebarShowing = show;
}

- (void)toggleSearch:(BOOL)searching withSearchTable:(UITableView *)searchTable animated:(BOOL)animate {
	if (animate) {
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:kSidebarAnimationDuration];
	}
	if (searching) {
		[_contentView removeGestureRecognizer:_tapRecog];
//		CGRect screenRect = [UIScreen mainScreen].bounds;
//		screenRect = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) 
//			? screenRect
//			: CGRectMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect), 
//						 CGRectGetHeight(screenRect), CGRectGetWidth(screenRect));
		CGRect sidebarFrame = [self calculateSidebarFrame:searching];
		_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(sidebarFrame), 0);
		_sidebarView.frame = sidebarFrame;
		[_menuTableView removeFromSuperview];
		if (searchTable != nil) {
			searchTable.frame = [self calculateSideTableFrame:searching];
			[_sidebarView addSubview:searchTable];
		}
	} else {
		_sidebarView.frame = [self calculateSidebarFrame:searching];
		_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(_sidebarView.frame), 0);
		[_contentView addGestureRecognizer:_tapRecog];
		_menuTableView.frame = [self calculateSideTableFrame:searching];
		[searchTable removeFromSuperview];
		[_sidebarView addSubview:_menuTableView];
	}
	if (animate) {
		[UIView commitAnimations];
	}
    _isSidebarShowing = YES;
	_isSearching = searching;
}

#pragma mark -
#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO animated:YES];
}

- (void)toggleSidebar {
    [self toggleSidebar:!_isSidebarShowing animated:YES];
}

- (CGRect)calculateSidebarFrame:(BOOL)searching {
	CGRect bounds = self.view.bounds;
	CGFloat frameWidth = (searching) ? CGRectGetWidth(bounds) : kSidebarWidth;
	return CGRectMake(0, 0, frameWidth, CGRectGetHeight(bounds));
}

- (CGRect)calculateSideTableFrame:(BOOL)searching {
	CGRect bounds = self.view.bounds;
	CGFloat searchBarHeight = CGRectGetHeight(_searchVC.searchBar.frame);
	CGFloat frameWidth = (searching) ? CGRectGetWidth(bounds) : kSidebarWidth;
	return CGRectMake(0, searchBarHeight, frameWidth, CGRectGetHeight(bounds) - searchBarHeight);
}

@end
