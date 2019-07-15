//
//  MCPModelBase.m
//
//  Created by coanyaa on 2015. 6. 12..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

#import "MCPModelBase.h"

@implementation MCPModelBase

- (id)initWithData:(id)data
{
    self = [super init];
    if( self ){
        
    }
    
    return self;
}

- (id)parseResultForClass:(Class)modelClass withData:(id)data
{
    return [((MCPModelBase*)[modelClass alloc]) initWithData:data];
}

- (NSMutableArray*)parseArrayResultForClass:(Class)modelClass withArray:(NSArray*)array
{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for(NSDictionary *item in array){
        id info = [self parseResultForClass:modelClass withData:item];
        if( info )
            [retArray addObject:info];
    }
    
    return retArray;
}

- (NSDictionary*)dictionaryObject
{
    return nil;
}

- (void)copyFrom:(id)target
{
    
}

+ (NSDate*)dateFromUnixTimstamp:(NSTimeInterval)timestamp
{
    return [NSDate dateWithTimeIntervalSince1970:timestamp*0.001];
}

@end
