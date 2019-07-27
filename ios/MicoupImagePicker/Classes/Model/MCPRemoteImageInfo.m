//
//  MCPRemoteImageInfo.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 3. 1..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "MCPRemoteImageInfo.h"

#import "NSDictionary+SafeParseData.h"


@implementation MCPRemoteImageInfo

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if( self ){
        self.name = [data safeObjectForKey:@"name"];
        self.isSuccess = [[data safeObjectForKey:@"success"] boolValue];
        self.message = [data safeObjectForKey:@"msg"];
        self.imageId = [data safeObjectForKey:@"image_id"];
        self.serial = [data safeObjectForKey:@"serial"];
        self.width = [data safeObjectForKey:@"width"];
        self.height = [data safeObjectForKey:@"height"];
        self.url = [data safeObjectForKey:@"url"];
    }
    
    return self;
}

- (NSMutableDictionary *)dictionaryObject {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"name"] = self.name;
    result[@"isSuccess"] = @(self.isSuccess);
    result[@"isImageLink"] = @(self.isImageLink);
    result[@"message"] = self.message;
    result[@"imageId"] = self.imageId;
    result[@"serial"] = self.serial;
    result[@"width"] = self.width;
    result[@"height"] = self.height;
    result[@"url"] = self.url;
    result[@"isDefault"] = @(self.isDefault);
    result[@"displayWidth"] = self.displayWidth;
    result[@"displayHeight"] = self.displayHeight;
    result[@"thumbnailUrl"] = self.thumbnailUrl;
    result[@"thumbnailWidth"] = self.thumbnailWidth;
    result[@"thumbnailHeight"] = self.thumbnailHeight;
    result[@"isLoadFail"] = @(self.isLoadFail);
    result[@"isCheckedUrl"] = @(self.isCheckedUrl);
    
    return [result copy];
}

@end
