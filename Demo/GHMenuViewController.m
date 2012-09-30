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
#import "GHRootViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Constants
static NSString *const HeaderIdentifier = @"SectionHeader";

#pragma mark Private Interface
@interface GHMenuViewController ()
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *controllers;
@property (strong, nonatomic) NSArray *cellInfos;
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
    [self.menuTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderIdentifier];
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
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:(38.0f/255.0f) green:(44.0f/255.0f) blue:(58.0f/255.0f) alpha:1.0f];
    cell.selectedBackgroundView = bgView;
	NSDictionary *info = self.cellInfos[indexPath.section][indexPath.row];
	cell.titleLabel.text = info[kSidebarCellTextKey];
	cell.imageView.image = info[kSidebarCellImageKey];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (self.headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = self.headers[section];
	UITableViewHeaderFooterView *headerView = nil;
	if (headerText != [NSNull null]) {
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
        headerView.backgroundView = nil;
        headerView.bounds = CGRectMake(0, 0, 260, 21);
        
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
			(id)[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f].CGColor,
			(id)[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f].CGColor,
		];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
		textLabel.text = (NSString *)headerText;
        textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
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
	self.sidebarVC.contentViewController = self.controllers[indexPath.section][indexPath.row];
	[self.sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
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

@end
