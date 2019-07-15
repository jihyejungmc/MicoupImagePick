//
//  MCPRemoteImageInfo.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 3. 1..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"

@interface MCPRemoteImageInfo : MCPModelBase

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isSuccess;
@property (assign, nonatomic) BOOL isImageLink;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSNumber *imageId;
@property (strong, nonatomic) NSString *serial;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) BOOL isDefault;
@property (strong, nonatomic) NSNumber *displayWidth;
@property (strong, nonatomic) NSNumber *displayHeight;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSNumber *thumbnailWidth;
@property (strong, nonatomic) NSNumber *thumbnailHeight;
@property (assign, nonatomic) BOOL isLoadFail;
@property (assign, nonatomic) BOOL isCheckedUrl;

@end
