//
//  GHMenuViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHMenuHeaderView.h"
#import "GHRevealViewController.h"
#import "GHRootViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Constants
static NSString *const HeaderIdentifier = @"SectionHeader";
static NSString *const CellIdentifier = @"GHMenuCell";

#pragma mark Private Interface
@interface GHMenuViewController () <GHSidebarSearchViewControllerDelegate>
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *controllers;
@property (strong, nonatomic) NSArray *cellInfos;
@property (nonatomic) BOOL searchEntrySelected;
- (UITableViewCell *)createCellWithTitle:(NSString *)title image:(UIImage *)image;
@end

#pragma mark Implementation
@implementation GHMenuViewController

#pragma mark Properties
@synthesize sidebarVC, searchBar, menuTableView;
@synthesize headers, controllers, cellInfos;

#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.headers = @[
        [NSNull null],
        @"FAVORITES"
    ];
    self.controllers = @[
        @[
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"Profile", @"")]]
        ],
        @[
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"News Feed", @"")]],
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"Messages", @"")]],
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"Nearby", @"")]],
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"Events", @"")]],
            [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:NSLocalizedString(@"Friends", @"")]]
        ]
    ];
    self.cellInfos = @[
        @[
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")}
        ],
        @[
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"News Feed", @"")},
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Messages", @"")},
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Nearby", @"")},
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Events", @"")},
            @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Friends", @"")},
        ]
    ];
    [self.menuTableView registerClass:[GHMenuHeaderView class] forHeaderFooterViewReuseIdentifier:HeaderIdentifier];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBG.png"];
    for (UIView *subview in self.searchBar.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *searchTextField = (UITextField *) subview;
			searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
		}
	}
	[self.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searchTextBG.png"]
                                                               resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)]
                                         forState:UIControlStateNormal];
	[self.searchBar setImage:[UIImage imageNamed:@"searchBarIcon.png"]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sidebarVC = (GHRevealViewController *)self.parentViewController;
    [self.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.sidebarVC
																						 action:@selector(dragContentView:)];
			panGesture.cancelsTouchesInView = YES;
			[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
		}];
	}];
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        ? UIInterfaceOrientationMaskAll
        : UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *info = self.cellInfos[indexPath.section][indexPath.row];
    return [self createCellWithTitle:info[kSidebarCellTextKey] image:info[kSidebarCellImageKey]];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (self.headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = self.headers[section];
	GHMenuHeaderView *headerView = nil;
	if (headerText != [NSNull null]) {
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
		headerView.titleLabel.text = (NSString *)headerText;
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.sidebarVC.contentViewController = self.controllers[indexPath.section][indexPath.row];
	[self.sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

#pragma mark GHSidebarSearchViewControllerDelegate
- (void)searchBegan {
    self.menuTableView.alpha = 0.0;
    [self.sidebarVC toggleSearch:YES duration:kGHRevealSidebarDefaultAnimationDuration];
    self.searchEntrySelected = NO;
}

- (void)searchEnded {
    if (self.searchEntrySelected) {
        [self.sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    } else {
        [self.sidebarVC toggleSearch:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    }
    self.menuTableView.alpha = 1.0;
    self.searchEntrySelected = NO;
}

- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
	callback(@[@"Foo", @"Bar", @"Baz"]);
}

- (void)searchController:(UISearchDisplayController *)controller selectedResult:(id)result atIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Selected Search Result - result: %@ indexPath: %@", result, indexPath);
    self.searchEntrySelected = YES;
    [controller setActive:NO animated:YES];
}

- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	return [self createCellWithTitle:entry image:[UIImage imageNamed:@"user.png"]];
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    if ((NSInteger)self.controllers.count > indexPath.section) {
        [self.menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
        if (scrollPosition == UITableViewScrollPositionNone) {
            [self.menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
        }
        self.sidebarVC.contentViewController = self.controllers[indexPath.section][indexPath.row];
    }
}

#pragma mark Private Methods
- (UITableViewCell *)createCellWithTitle:(NSString *)title image:(UIImage *)image {
    GHMenuCell* cell = [self.menuTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:(38.0f/255.0f) green:(44.0f/255.0f) blue:(58.0f/255.0f) alpha:1.0f];
    cell.selectedBackgroundView = bgView;
	cell.titleLabel.text = title;
	cell.imageView.image = image;
    return cell;
}

@end
