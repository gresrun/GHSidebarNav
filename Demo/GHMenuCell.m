//
//  GHSidebarMenuCell.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHMenuCell.h"


#pragma mark -
#pragma mark Implementation
@implementation GHMenuCell

#pragma mark Properties
@synthesize imageView, titleLabel;

#pragma mark UITableViewCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.titleLabel.text = @"";
}

@end
