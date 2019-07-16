//
//  ScreenUtil.m
//
//  Created by coanyaa on
//  Copyright (c) 2014년 Joy2x. All rights reserved.
//

#import "ScreenUtil.h"

@implementation ScreenUtil

+ (UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect)rect
{
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    //Get the width and heights
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)strokCircleImageSize:(CGSize)size color:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextAddArc(context, size.width*0.5, size.height*0.5, size.width*0.5-0.5, 0.0, M_PI*2.0, YES);
    CGContextStrokePath(context);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage*)cropImage:(UIImage*)srcImage inRect:(CGRect)rect
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
	CGContextFillRect(context, rect);
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, srcImage.size.width, srcImage.size.height);
	
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
	
    // draw image
    [srcImage drawInRect:drawRect];
	
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return subImage;
	
}

+ (UIImage*)captureImageFromView:(UIView*)targetView
{
//    UIGraphicsBeginImageContext(targetView.frame.size);
    UIGraphicsBeginImageContextWithOptions(targetView.frame.size, NO, [UIScreen mainScreen].scale);
    [targetView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+ (UIImage*)captureAndSaveToPhotoAlbumFromView:(UIView*)targetView
{
    UIImage *caputreImage = [ScreenUtil captureImageFromView:targetView];
    UIImageWriteToSavedPhotosAlbum(caputreImage, nil, nil, nil);
    
    return caputreImage;
}

+ (UIImage*)cropImage:(UIImage*)srcImage inRect:(CGRect)rect orientation:(UIImageOrientation)orientation
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context, rect);
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, srcImage.size.width, srcImage.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [srcImage drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
    
}

+ (UIImage*)resizeImage:(UIImage *)image size:(CGSize)size isApplyRatio:(BOOL)isApplyRatio
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat ratio = 1.0;
    CGSize resizeSize = CGSizeMake(size.width / scale, size.height / scale);
    CGSize originalSize = image.size;
    
    if( image.size.width != image.size.height ){
        if( image.size.width > image.size.height ){
            ratio = image.size.height / image.size.width;
            resizeSize = CGSizeMake(resizeSize.width, resizeSize.width * ratio);
        }
        else{
            ratio = image.size.width / image.size.height;
            resizeSize = CGSizeMake(resizeSize.height * ratio, resizeSize.height);
        }
    }

    UIGraphicsBeginImageContextWithOptions(resizeSize, NO, scale);
    [image drawInRect:CGRectMake(0,0,resizeSize.width,resizeSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage*)mergeImage:(UIImage*)srcImage withImage:(UIImage*)targetImage atPosition:(CGPoint)position
{
    CGSize newSize = CGSizeMake(MAX(srcImage.size.width,position.x+targetImage.size.width),MAX(srcImage.size.height,position.y+targetImage.size.height));
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [srcImage drawAtPoint:CGPointMake(0, 0)];
    [targetImage drawAtPoint:position];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)clearImage:(UIImage*)image rect:(CGRect)rect
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawAtPoint:CGPointMake(0, 0)];
    CGContextClearRect(context, rect);
    
    UIImage *resultImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
