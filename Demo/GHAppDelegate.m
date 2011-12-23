//
//  GHAppDelegate.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHAppDelegate.h"
#import "GHSidebarViewController.h"
#import "GHRootViewController.h"


#pragma mark -
#pragma mark Private Interface
@interface GHAppDelegate ()
@property(nonatomic, strong) GHSidebarViewController *viewController;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHAppDelegate

#pragma mark Properties
@synthesize window;
@synthesize viewController;

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	NSMutableArray *headers = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *cellInfos = [[NSMutableArray alloc] initWithCapacity:2];
	self.viewController = [[GHSidebarViewController alloc] initWithHeaders:headers withContollers:controllers withCellInfos:cellInfos];
    
	void (^revealBlock)() = ^(){
		[self.viewController toggleSidebar:!self.viewController.sidebarShowing animated:YES];
	};
	
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
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
