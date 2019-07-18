
#import "NSDictionary+MCPSafeConvert.h"

@implementation NSMutableDictionary (MCPSafeConvert)

- (void)mcp_setObject:(id)value forKey:(NSString *)key {
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return;
    }

    if (value && value != [NSNull null] && key) {
        [self setObject:value forKey:key];
    }
}

- (void)mcp_setBool:(BOOL)value forKey:(NSString *)key {
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return;
    }

    if (key) {
        [self setObject:@(value) forKey:key];
    }
}

- (void)mcp_setInteger:(NSInteger)value forKey:(NSString *)key {
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return;
    }

    if (key) {
        [self setObject:@(value) forKey:key];
    }
}

@end

@implementation NSDictionary (MCPSafeConvert)

- (BOOL)mcp_boolForKey:(NSString *)key {
    if (![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return nil;
    }

    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (NSInteger)mcp_integerForKey:(NSString *)key {
    if (![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return nil;
    }

    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSString *)mcp_stringForKey:(NSString *)key {
    if (![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"유형이 잘못되었거나 사전이 값을 설정할 수 없습니다!");
        return nil;
    }

    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return nil;
}

@end
