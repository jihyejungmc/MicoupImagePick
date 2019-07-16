//
//  UIImage+ExifMetaData.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 10. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ExifMetaData)

- (NSData*)jpegDataByRemovingExif;
- (NSArray*)metadata;

@end
