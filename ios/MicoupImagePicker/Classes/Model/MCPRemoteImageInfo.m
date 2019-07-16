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

@end
