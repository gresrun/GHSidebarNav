//
//  GHSidebarMenuCell.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarMenuCell.h"


#pragma mark Implementation
@implementation GHSidebarMenuCell

#pragma mark -
#pragma mark Memory Management
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.clipsToBounds = YES;
		
		UIView *bgView = [[UIView alloc] init];
		bgView.backgroundColor = [UIColor colorWithRed:(38.f/255.f) green:(44.f/255.f) blue:(58.f/255.f) alpha:1.f];
		self.selectedBackgroundView = bgView;
				
		self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.2)];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
		self.textLabel.textColor = [UIColor colorWithRed:(196.f/255.f) green:(204.f/255.f) blue:(218.f/255.f) alpha:1.f];
		self.imageView.contentMode = UIViewContentModeCenter;
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 1)];
		topLine.backgroundColor = [UIColor colorWithRed:(54.0/255.0) green:(61.0/255.0) blue:(76.0/255.0) alpha:1.0];
		[self.textLabel.superview addSubview:topLine];
		
		UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, [UIScreen mainScreen].bounds.size.height, 1)];
		topLine2.backgroundColor = [UIColor colorWithRed:(54.0/255.0) green:(61.0/255.0) blue:(77.0/255.0) alpha:1.0];
		[self.textLabel.superview addSubview:topLine2];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.height, 1)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(40.0/255.0) green:(47.0/255.0) blue:(61.0/255.0) alpha:1.0];
		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

#pragma mark -
#pragma mark UIView
- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(50, 0, 200, 43);
	self.imageView.frame = CGRectMake(0, 0, 50, 43);
}

@end
