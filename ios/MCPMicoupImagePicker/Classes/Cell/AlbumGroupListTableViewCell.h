//
//  AlbumGroupListTableViewCell.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 27..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AlbumGroupListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) ALAssetsGroup *groupInfo;

@end
