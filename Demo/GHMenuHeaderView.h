//
//  GHMenuHeaderView.h
//  GHSidebarNav
//
//  Created by Greg Haines on 9/30/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface GHMenuHeaderView : UITableViewHeaderFooterView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end
