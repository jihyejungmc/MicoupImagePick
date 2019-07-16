//
//  NSDictionary+SafeParseData.m
//  NODCoCo
//
//  Created by coanyaa on 2015. 4. 27..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

#import "NSDictionary+SafeParseData.h"

@implementation NSDictionary (SafeParseData)

- (id)safeObjectForKey:(NSString*)key
{
    id value = [self objectForKey:key];
    if( value == nil || [value isKindOfClass:[NSNull class]] )
        return nil;
    return value;
}

@end
