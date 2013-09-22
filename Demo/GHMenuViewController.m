//
//  GHMenuViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
#pragma mark Implementation
@implementation GHMenuViewController {
	GHRevealViewController *_sidebarVC;
	UISearchBar *_searchBar;
	UITableView *_menuTableView;
	NSArray *_headers;
	NSArray *_controllers;
	NSArray *_cellInfos;
}

#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC 
					  withSearchBar:(UISearchBar *)searchBar 
						withHeaders:(NSArray *)headers 
					withControllers:(NSArray *)controllers 
					  withCellInfos:(NSArray *)cellInfos {
	if (self = [super initWithNibName:nil bundle:nil]) {
		_sidebarVC = sidebarVC;
		_searchBar = searchBar;
		_headers = headers;
		_controllers = controllers;
		_cellInfos = cellInfos;
		
		_sidebarVC.sidebarViewController = self;
		_sidebarVC.contentViewController = _controllers[0][0];
	}
	return self;
}

#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview:_searchBar];
	
	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds) - 44.0f) 
												  style:UITableViewStylePlain];
	_menuTableView.delegate = self;
	_menuTableView.dataSource = self;
	_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_menuTableView];
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.frame = CGRectMake(0.0f, 0.0f,kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	[_searchBar sizeToFit];
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

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = _cellInfos[indexPath.section][indexPath.row];
	cell.textLabel.text = info[kSidebarCellTextKey];
	cell.imageView.image = info[kSidebarCellImageKey];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (_headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = _headers[section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
			(id)[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f].CGColor,
			(id)[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f].CGColor,
		];
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
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
	[_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
	[_menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
	if (scrollPosition == UITableViewScrollPositionNone) {
		[_menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
	}
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
}

@end
