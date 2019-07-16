//
//  PhotoEditCollectionViewCell.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 2. 7..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "MCPPhotoEditCollectionViewCell.h"
#import "MCPPhotoEditInfo.h"
#import "BFCropInterface.h"

@implementation MCPPhotoEditCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _loadingView.layer.cornerRadius = 5.0;
    _loadingView.layer.masksToBounds = YES;
    _loadingView.hidden = YES;
}

- (void)setupImageViewWithInfo:(MCPPhotoEditInfo*)info
{
    if( self.imageView == nil ){
        self.imageView = [[UIImageView alloc] initWithImage:info.editedImage];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = YES;
        _imageView.frame = _scrollView.bounds;
        //        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        //        _scrollView.delegate = self;
    }
    else
        _imageView.image = info.editedImage;
    
    // 이미지 크기에 맞게 imageView frame 변경
    if( info.editedImage ){
        CGRect scrollFrame = CGRectMake(16.0, 16.0, _scrollView.frame.size.width - 32.0, _scrollView.frame.size.height - 32.0);
        if( info.editedImage.size.height > info.editedImage.size.width ){
            // 높이를 기준으로 폭을 맞춰야함
            CGFloat ratio = info.editedImage.size.width / info.editedImage.size.height;
            CGFloat displayHeight = MIN( scrollFrame.size.height, info.editedImage.size.height );
            CGFloat displayWidth = floorf(displayHeight * ratio);
            if( displayWidth > scrollFrame.size.width ){
                CGFloat wRatio = scrollFrame.size.width / displayWidth;
                displayHeight = floorf(displayHeight * wRatio);
                displayWidth = scrollFrame.size.width;
            }
            _imageView.frame = CGRectMake(0, 0, displayWidth, displayHeight );
        }
        else{
            CGFloat displayWidth = MIN( scrollFrame.size.width, info.editedImage.size.width );
            CGFloat ratio = info.editedImage.size.height / info.editedImage.size.width;
            CGFloat displayHeight = floorf(displayWidth * ratio );
            if( displayHeight > scrollFrame.size.height ){
                CGFloat hRatio = scrollFrame.size.height / displayHeight;
                displayWidth = floorf( displayWidth * hRatio);
                displayHeight = scrollFrame.size.height;
            }
            _imageView.frame = CGRectMake( scrollFrame.origin.x, scrollFrame.origin.y, displayWidth, displayHeight  );
        }
        _imageView.center = CGPointMake(_scrollView.bounds.size.width *0.5, _scrollView.bounds.size.height * 0.5);
    }
    self.imageView.hidden = NO;
    [self.imageView setNeedsDisplay];
}

- (void)setInfo:(MCPPhotoEditInfo *)info
{
    _info = info;
    
    if( info.editedImage == nil ){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if( !isLoading ){
//            isLoading = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [info loadOrCreateEditingImageWithCompletion:^(UIImage *image) {
                    _loadingView.hidden = YES;
                    [self setupImageViewWithInfo:info];
//                    isLoading = NO;
                }];
            });
//        }
//        });
    }
    else{
        _loadingView.hidden = YES;
        [self setupImageViewWithInfo:info];
    }
}

- (void)showCropView
{
    if( self.cropInterface )
        [self.cropInterface removeFromSuperview];
    
    self.cropInterface = [[BFCropInterface alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x - 16.0, _imageView.frame.origin.y - 16.0, _imageView.frame.size.width + 32.0, _imageView.frame.size.height + 32.0) andImage:_imageView.image];
    // this is the default color even if you don't set it
    _cropInterface.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    // white is the default border color.
    _cropInterface.borderColor = [UIColor redColor];    
    // add interface to superview. here we are covering the main image view.
    [_scrollView addSubview:self.cropInterface];
}

- (void)hideCropView
{
    if( self.cropInterface )
        [self.cropInterface removeFromSuperview];
    self.cropInterface = nil;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
