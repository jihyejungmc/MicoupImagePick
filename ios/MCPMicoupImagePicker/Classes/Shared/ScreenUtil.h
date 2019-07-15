//
//  ScreenUtil.h
//
//  Created by coanyaa
//  Copyright (c) 2014년 Joy2x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ScreenUtil : NSObject

+ (UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect)rect;
+ (UIImage*)strokCircleImageSize:(CGSize)size color:(UIColor*)color;
+ (UIImage*)cropImage:(UIImage*)srcImage inRect:(CGRect)rect;

+ (UIImage*)captureImageFromView:(UIView*)targetView;
+ (UIImage*)captureAndSaveToPhotoAlbumFromView:(UIView*)targetView;
+ (UIImage*)cropImage:(UIImage*)srcImage inRect:(CGRect)rect orientation:(UIImageOrientation)orientation;
+ (UIImage*)resizeImage:(UIImage *)image size:(CGSize)size isApplyRatio:(BOOL)isApplyRatio;
+ (UIImage*)mergeImage:(UIImage*)srcImage withImage:(UIImage*)targetImage atPosition:(CGPoint)position;
+ (UIImage*)clearImage:(UIImage*)image rect:(CGRect)rect;
@end
