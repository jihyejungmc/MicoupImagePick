//
//  MCPResultInfo.m
//  NameUp
//
//  Created by coanyaa on 2015. 4. 21..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

#import "MCPResultInfo.h"
#import "NSDictionary+SafeParseData.h"
#import "MCPModelBase.h"
#import "MCPListResultInfo.h"

@implementation MCPResultInfo

- (id)initWithData:(id)data
{
    self = [super init];
    if( self ){
        NSError *error = nil;
        self.textData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if( error == nil ){
            self.errorCode = [json safeObjectForKey:@"resultCode"];
            self.isSuccess = ( [_errorCode integerValue] == 0 );
            self.message = [json safeObjectForKey:@"resultMsg"];
            self.jsonData = json;
            self.resultData = json;
        }
        else{
//            self.isSuccess = [[self.textData lowercaseString] isEqualToString:@"true"];
            self.isSuccess = NO;
            self.resultData = self.textData;
        }
        
        
    }
    
    return self;
}

@end
