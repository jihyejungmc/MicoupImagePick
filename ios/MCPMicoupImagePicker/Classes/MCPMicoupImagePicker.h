
//#import <React/RCTBridgeModule.h>

#import "MCPBaseViewController.h"
#import "MCPPhotoEditResultViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoGroupViewController.h"
#import "MCPPhotoSelectViewController.h"
#import "MCPResultInfo.h"

typedef void (^MCPMicoupImagePickerCompletionHandler)(void);

@interface MCPMicoupImagePicker : NSObject /* <RCTBridgeModule> */

- (void)showImagePickerWithOptions:(NSDictionary *)options completionHandler:(MCPMicoupImagePickerCompletionHandler)completionHandler;

@end
  
