//
//  GHSidebarMenuCell.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

extern NSString const *kSidebarCellTextKey;
extern NSString const *kSidebarCellImageKey;

@interface GHMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
