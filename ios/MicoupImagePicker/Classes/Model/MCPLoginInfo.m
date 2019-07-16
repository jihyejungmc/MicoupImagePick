//
//  LoginInfo.m
//  CaseByMe
//
//  Created by coanyaa on 2015. 12. 29..
//  Copyright © 2015년 Joy2x. All rights reserved.
//

#import "MCPLoginInfo.h"

#import "NSDictionary+SafeParseData.h"


@implementation MCPLoginInfo

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if( self ){
        self.userIdx = [[data safeObjectForKey:@"userIdx"] stringValue];
        self.nickname = [data safeObjectForKey:@"nickName"];
        self.profileImageUrl = [data safeObjectForKey:@"picture"];
        self.type = [data safeObjectForKey:@"type"];
        self.accessPage = [data safeObjectForKey:@"accessPage"];
    }
    
    return self;
}

@end
