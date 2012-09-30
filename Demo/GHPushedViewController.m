//
//  GHPushedViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/29/11.
//

#import "GHPushedViewController.h"


#pragma mark -
#pragma mark Implementation
@implementation GHPushedViewController

#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	view.backgroundColor = [UIColor redColor];
	[self.view addSubview:view];
}

@end
