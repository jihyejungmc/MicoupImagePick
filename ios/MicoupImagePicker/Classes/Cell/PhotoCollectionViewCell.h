//
//  PhotoCollectionViewCell.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 27..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UIView *gifMarkView;

@end
