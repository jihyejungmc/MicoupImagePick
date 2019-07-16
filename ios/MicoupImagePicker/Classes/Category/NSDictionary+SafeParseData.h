//
//  NSDictionary+SafeParseData.h
//  NODCoCo
//
//  Created by coanyaa on 2015. 4. 27..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeParseData)

- (id)safeObjectForKey:(NSString*)key;
@end
