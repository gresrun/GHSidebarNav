//
//  GHSidebarViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Constants
const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration = 0.25;
const CGFloat kGHRevealSidebarWidth = 260.0f;
const CGFloat kGHRevealSidebarFlickVelocity = 1000.0f;
static NSString *const sidebarSegueName = @"sidebarSegue";
static NSString *const contentSegueName = @"contentSegue";

#pragma mark Private Interface
@interface GHRevealViewController ()
@property (nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readwrite, getter = isSearching) BOOL searching;
@property (nonatomic) BOOL searchIsShowing;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecog;
- (void)hideSidebar;
@end

#pragma mark Implementation
@implementation GHRevealViewController

#pragma mark Properties
@synthesize sidebarView, contentView, sidebarViewController, contentViewController;
@synthesize sidebarShowing, searching, tapRecog;

- (void)setSidebarViewController:(UIViewController *)svc {
	if (sidebarViewController == nil) {
		svc.view.frame = self.sidebarView.bounds;
		sidebarViewController = svc;
		[self addChildViewController:sidebarViewController];
		[self.sidebarView addSubview:sidebarViewController.view];
		[sidebarViewController didMoveToParentViewController:self];
	} else if (sidebarViewController != svc) {
		svc.view.frame = self.sidebarView.bounds;
		[sidebarViewController willMoveToParentViewController:nil];
		[self addChildViewController:svc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:sidebarViewController
						  toViewController:svc
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[sidebarViewController removeFromParentViewController];
									[svc didMoveToParentViewController:self];
									sidebarViewController = svc;
								}
		 ];
	}
}

- (void)setContentViewController:(UIViewController *)cvc {
	if (contentViewController == nil) {
		cvc.view.frame = self.contentView.bounds;
		contentViewController = cvc;
		[self addChildViewController:contentViewController];
		[self.contentView addSubview:contentViewController.view];
		[contentViewController didMoveToParentViewController:self];
	} else if (contentViewController != cvc) {
		cvc.view.frame = self.contentView.bounds;
		[contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:cvc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:contentViewController
						  toViewController:cvc
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[contentViewController removeFromParentViewController];
									[cvc didMoveToParentViewController:self];
									contentViewController = cvc;
								}
         ];
	}
}

#pragma mark UIViewController
- (void)viewDidLoad {
    self.sidebarShowing = NO;
    self.searching = NO;
    
    self.tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebar)];
    self.tapRecog.cancelsTouchesInView = YES;
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.contentView.layer.shadowOpacity = 1.0f;
    self.contentView.layer.shadowRadius = 2.5f;
    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds].CGPath;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (self.searchIsShowing) {
		[self.sidebarView setFrame:self.view.bounds];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sidebarSegueName isEqualToString:segue.identifier]) {
        sidebarViewController = [segue destinationViewController];
    }
    if ([contentSegueName isEqualToString:segue.identifier]) {
        contentViewController = [segue destinationViewController];
    }
}

#pragma mark Public Methods
- (void)dragContentView:(UIPanGestureRecognizer *)panGesture {
	CGFloat translation = [panGesture translationInView:self.view].x;
	if (panGesture.state == UIGestureRecognizerStateChanged) {
		if (sidebarShowing) {
			if (translation > 0.0f) {
				self.contentView.frame = CGRectOffset(self.contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else if (translation < -kGHRevealSidebarWidth) {
				self.contentView.frame = self.contentView.bounds;
				self.sidebarShowing = NO;
			} else {
				self.contentView.frame = CGRectOffset(self.contentView.bounds, (kGHRevealSidebarWidth + translation), 0.0f);
			}
		} else {
			if (translation < 0.0f) {
				self.contentView.frame = self.contentView.bounds;
				self.sidebarShowing = NO;
			} else if (translation > kGHRevealSidebarWidth) {
				self.contentView.frame = CGRectOffset(self.contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else {
				self.contentView.frame = CGRectOffset(self.contentView.bounds, translation, 0.0f);
			}
		}
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
		CGFloat velocity = [panGesture velocityInView:self.view].x;
		BOOL show = (fabs(velocity) > kGHRevealSidebarFlickVelocity)
			? (velocity > 0)
			: (translation > (kGHRevealSidebarWidth / 2));
		[self toggleSidebar:show duration:kGHRevealSidebarDefaultAnimationDuration];
	}
}

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration {
	[self toggleSidebar:show duration:duration completion:nil];
}

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
	if (self.contentView.superview == nil) {
		self.contentView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
		[self.view addSubview:self.contentView];
	}
	void (^animations)(void) = ^{
		if (show) {
			self.contentView.frame = CGRectOffset(self.contentView.bounds, kGHRevealSidebarWidth, 0.0f);
			[self.contentView addGestureRecognizer:self.tapRecog];
		} else {
			if (self.isSearching) {
				self.sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			} else {
				[self.contentView removeGestureRecognizer:self.tapRecog];
			}
			self.contentView.frame = self.contentView.bounds;
		}
		self.sidebarShowing = show;
	};
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:completion];
	} else {
		animations();
		if (completion != nil) {
			completion(YES);
		}
	}
}

- (void)toggleSearch:(BOOL)showSearch duration:(NSTimeInterval)duration {
	[self toggleSearch:showSearch duration:duration completion:nil];
}

- (void)toggleSearch:(BOOL)showSearch duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
	if (!showSearch) {
		self.contentView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
		[self.view addSubview:self.contentView];
		self.searchIsShowing = NO;
	} else {
		self.searchIsShowing = YES;
	}
	void (^animations)(void) = ^{
		if (showSearch) {
			self.contentView.frame = CGRectOffset(self.contentView.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
			[self.contentView removeGestureRecognizer:self.tapRecog];
			self.sidebarView.frame = self.view.bounds;
		} else {
			self.sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			[self.view insertSubview:self.sidebarView atIndex:0];
			self.sidebarView.frame = CGRectMake(0, 0, kGHRevealSidebarWidth, self.view.bounds.size.height);
			self.contentView.frame = CGRectOffset(self.contentView.bounds, kGHRevealSidebarWidth, 0.0f);
		}
	};
	void (^fullCompletion)(BOOL) = ^(BOOL finished){
		if (showSearch) {
			self.contentView.frame = CGRectOffset(self.contentView.bounds, CGRectGetHeight([UIScreen mainScreen].bounds), 0.0f);
			[self.contentView removeFromSuperview];
		} else {
			[self.contentView addGestureRecognizer:self.tapRecog];
		}
		self.sidebarShowing = YES;
		self.searching = showSearch;
		if (completion != nil) {
			completion(finished);
		}
	};
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:fullCompletion];
	} else {
		animations();
		if (completion != nil) {
			fullCompletion(YES);
		}
	}
}

#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

@end
