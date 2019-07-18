
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import "MCPBaseViewController.h"
#import "MCPPhotoEditResultViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoGroupViewController.h"
#import "MCPPhotoSelectViewController.h"
#import "MCPResultInfo.h"

@interface MCPMicoupImagePicker : NSObject <RCTBridgeModule>

- (void)showImagePicker:(NSDictionary *)options;

@end
