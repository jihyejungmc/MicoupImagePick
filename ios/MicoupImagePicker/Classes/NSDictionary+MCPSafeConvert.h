#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MCPSafeConvert)

- (void)mcp_setObject:(id)value forKey:(NSString *)key;

- (void)mcp_setInteger:(NSInteger)value forKey:(NSString *)key;

- (void)mcp_setBool:(BOOL)value forKey:(NSString *)key;

@end

@interface NSDictionary (MCPSafeConvert)

- (NSString *)mcp_stringForKey:(NSString *)key;

- (BOOL)mcp_boolForKey:(NSString *)key;

- (NSInteger)mcp_integerForKey:(NSString *)key;

@end
