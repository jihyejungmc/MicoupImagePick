//
//  AlbumGroupListTableViewCell.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 27..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "AlbumGroupListTableViewCell.h"

@implementation AlbumGroupListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGroupInfo:(ALAssetsGroup *)groupInfo
{
    _groupInfo = groupInfo;
    _titleLabel.text = [groupInfo valueForProperty:ALAssetsGroupPropertyName];
    _countLabel.text = [NSString stringWithFormat:@"%ld",(long)groupInfo.numberOfAssets];
}

@end
