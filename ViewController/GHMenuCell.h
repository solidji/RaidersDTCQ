//
//  GHSidebarMenuCell.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

extern NSString const *kSidebarCellTextKey;
extern NSString const *kSidebarCellImageKey;

@interface GHMenuCell : UITableViewCell{
    UILabel *tagLabel;
}

@property (nonatomic, strong) UILabel *tagLabel;

@end
