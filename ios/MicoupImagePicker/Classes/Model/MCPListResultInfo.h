//
//  MCPListResultInfo.h
//  OurMarket
//
//  Created by coanyaa on 2014. 12. 30..
//  Copyright (c) 2014년 Joy2x. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"

@interface MCPListResultInfo : MCPModelBase

@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger offset;
@property (assign, nonatomic) NSInteger limit;
@property (strong, nonatomic) NSMutableArray *itemArray;

- (id)initWithData:(NSDictionary*)data itemClass:(Class)itemClass;
- (id)initWithData:(NSDictionary*)data itemClass:(Class)itemClass listKey:(NSString*)listKey;

@end
