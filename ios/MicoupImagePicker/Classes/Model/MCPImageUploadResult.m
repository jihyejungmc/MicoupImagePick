//
//  MCPImageUploadResult.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 3. 1..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "MCPImageUploadResult.h"
#import "MCPRemoteImageInfo.h"

#import "NSDictionary+SafeParseData.h"


@implementation MCPImageUploadResult

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if( self ){
        self.isSuccess = [[data safeObjectForKey:@"success"] boolValue];
        self.result = [[data safeObjectForKey:@"result"] boolValue];
        self.message = [data safeObjectForKey:@"msg"];
        self.successCount = [data safeObjectForKey:@"success_count"];
        self.count = [data safeObjectForKey:@"count"];
        if( [data safeObjectForKey:@"files"] )
            self.fileArray = [self parseArrayResultForClass:[MCPRemoteImageInfo class] withArray:[data safeObjectForKey:@"files"]];
    }
    
    return self;
}

- (NSMutableDictionary *)dictionaryObject {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"isSuccess"] = @(self.isSuccess);
    result[@"result"] = @(self.result);
    result[@"message"] = self.message;
    result[@"successCount"] = self.successCount;
    result[@"count"] = self.count;
    
    NSMutableArray *fileArray = [NSMutableArray array];
    for (MCPRemoteImageInfo *imageInfo in self.fileArray) {
        NSDictionary *item = [imageInfo dictionaryObject];
        if (item) {
            [fileArray addObject:item];
        }
    }
    result[@"fileArray"] = [fileArray copy];
    
    return [result copy];
}

@end
