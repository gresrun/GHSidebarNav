//
//  GHMenuHeaderView.m
//  GHSidebarNav
//
//  Created by Greg Haines on 9/30/12.
//
//

#import "GHMenuHeaderView.h"


#pragma mark Implementation
@implementation GHMenuHeaderView

#pragma mark Properties
@synthesize titleLabel;

#pragma mark Memory Management
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.bounds = CGRectMake(0, 0, 480, 21.0);
        self.contentView.frame = self.bounds;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.gradientLayer = [CAGradientLayer layer];
		self.gradientLayer.frame = self.bounds;
        self.gradientLayer.colors = @[
            (id)[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f].CGColor,
            (id)[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f].CGColor,
		];
		[self.layer insertSublayer:self.gradientLayer atIndex:0];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 12.0f, 5.0f)];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		self.titleLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(129.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        [self.contentView addSubview:self.titleLabel];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(78.0f/255.0f) green:(86.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
        topLine.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[self.contentView addSubview:topLine];
        
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(36.0f/255.0f) green:(42.0f/255.0f) blue:(5.0f/255.0f) alpha:1.0f];
        bottomLine.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[self.contentView addSubview:bottomLine];
    }
    return self;
}

#pragma mark UIView
- (void)layoutSubviews {
    self.gradientLayer.frame = self.bounds;
}

#pragma mark UITableViewHeaderFooterView
- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = @"";
}


@end
