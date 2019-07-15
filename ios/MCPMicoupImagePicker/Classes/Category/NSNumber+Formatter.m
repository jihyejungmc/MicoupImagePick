//
//  NSNumber+Formatter.m
//  YPER
//
//  Created by coanyaa on 2015. 12. 18..
//  Copyright © 2015년 joy2x. All rights reserved.
//

#import "NSNumber+Formatter.h"

@implementation NSNumber (Formatter)

- (NSString*)decimalStyleFormatString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    return [nf stringFromNumber:self];
}

- (NSString*)priceStyleFormatString
{
    return [@"₩" stringByAppendingString:[self decimalStyleFormatString]];
}

@end
