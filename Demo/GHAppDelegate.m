//
//  GHAppDelegate.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHAppDelegate.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRootViewController.h"
#import "GHRevealViewController.h"


#pragma mark -
#pragma mark Private Interface
@interface GHAppDelegate ()
@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHAppDelegate

#pragma mark Properties
@synthesize window;
@synthesize revealController;
@synthesize searchController;
@synthesize menuController;

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
	
	RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:!self.revealController.sidebarShowing duration:kGHRevealSidebarDefaultAnimationDuration];
	};
	
	NSMutableArray *headers = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *cellInfos = [[NSMutableArray alloc] initWithCapacity:2];
	
	NSMutableArray *profileInfos = [[NSMutableArray alloc] initWithCapacity:1];
	NSMutableArray *profileControllers = [[NSMutableArray alloc] initWithCapacity:1];
	[profileInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"Profile", @""), kSidebarCellTextKey, nil]];
	[profileControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]]];
	[headers addObject:[NSNull null]];
	[cellInfos addObject:profileInfos];
	[controllers addObject:profileControllers];
	
	NSMutableArray *favoritesInfos = [[NSMutableArray alloc] initWithCapacity:5];
	NSMutableArray *favoritesControllers = [[NSMutableArray alloc] initWithCapacity:5];
	[favoritesInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"News Feed", @""), kSidebarCellTextKey, nil]];
	[favoritesControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"News Feed" withRevealBlock:revealBlock]]];
	[favoritesInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"Messages", @""), kSidebarCellTextKey, nil]];
	[favoritesControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Messages" withRevealBlock:revealBlock]]];
	[favoritesInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"Nearby", @""), kSidebarCellTextKey, nil]];
	[favoritesControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Nearby" withRevealBlock:revealBlock]]];
	[favoritesInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"Events", @""), kSidebarCellTextKey, nil]];
	[favoritesControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Events" withRevealBlock:revealBlock]]];
	[favoritesInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"user.png"], kSidebarCellImageKey, NSLocalizedString(@"Friends", @""), kSidebarCellTextKey, nil]];
	[favoritesControllers addObject:[[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Friends" withRevealBlock:revealBlock]]];
	[headers addObject:@"FAVORITES"];
	[cellInfos addObject:favoritesInfos];
	[controllers addObject:favoritesControllers];
	
	self.searchController = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self.revealController];
	self.searchController.view.backgroundColor = [UIColor clearColor];
    self.searchController.searchDelegate = self;
	self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchController.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBG.png"];
	self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", @"");
	self.searchController.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
	for (UIView *subview in self.searchController.searchBar.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *searchTextField = (UITextField *) subview;
			searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
		}
	}
	UIEdgeInsets insets = UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f);
	UIImage *searchTextBG = [[UIImage imageNamed:@"searchTextBG.png"] resizableImageWithCapInsets:insets];
	UIImage *searchBarIcon = [UIImage imageNamed:@"searchBarIcon.png"];
	[self.searchController.searchBar setSearchFieldBackgroundImage:searchTextBG	
														  forState:UIControlStateNormal];
	[self.searchController.searchBar setSearchFieldBackgroundImage:searchTextBG	
														  forState:UIControlStateDisabled];
	[self.searchController.searchBar setImage:searchBarIcon 
							 forSearchBarIcon:UISearchBarIconSearch 
										state:UIControlStateNormal];
	[self.searchController.searchBar setImage:searchBarIcon 
							 forSearchBarIcon:UISearchBarIconSearch 
										state:UIControlStateHighlighted];
	
	self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController 
																		withSearchBar:self.searchController.searchBar 
																		  withHeaders:headers 
																	  withControllers:controllers 
																		withCellInfos:cellInfos];
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
	callback([NSArray arrayWithObjects:@"Foo", @"Bar", @"Baz", nil]);
}

@end
