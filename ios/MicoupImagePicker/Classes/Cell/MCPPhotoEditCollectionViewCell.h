//
//  PhotoEditCollectionViewCell.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 2. 7..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

@import UIKit;

@class BFCropInterface;

@class MCPPhotoEditInfo;
@interface MCPPhotoEditCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate> {
    __block BOOL isLoading;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) BFCropInterface *cropInterface;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property (strong, nonatomic) MCPPhotoEditInfo *info;

- (void)showCropView;
- (void)hideCropView;

@end
