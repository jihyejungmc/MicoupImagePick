//
//  MCPModelBase.h
//
//  Created by coanyaa on 2015. 6. 12..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

@import Foundation;

#define DEFAULT_DATETIMEFORMAT              @"yyyy-MM-dd'T'HH:mm:ss"

#define YNTOBool(str)                       ([[str lowercaseString] isEqualToString:@"y"])
#define BoolTOYN(flag)                      ( (flag) ? @"Y" : @"N" )

@interface MCPModelBase : NSObject

@property (assign, nonatomic) BOOL selected;

- (id)initWithData:(id)data;
- (id)parseResultForClass:(Class)modelClass withData:(id)data;
- (NSMutableArray*)parseArrayResultForClass:(Class)modelClass withArray:(NSArray*)array;
- (NSMutableDictionary*)dictionaryObject;
- (void)copyFrom:(id)target;

+ (NSDate*)dateFromUnixTimstamp:(NSTimeInterval)timestamp;

@end
