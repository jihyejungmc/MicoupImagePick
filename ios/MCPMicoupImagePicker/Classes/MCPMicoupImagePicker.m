
#import "MCPMicoupImagePicker.h"

@interface MCPMicoupImagePicker ()

@end


@implementation MCPMicoupImagePicker

/*
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()
 */

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"MCPMicoupImagePicker init");
    }
    return self;
}

- (void)showImagePickerWithOptions:(NSDictionary *)options completionHandler:(MCPMicoupImagePickerCompletionHandler)completionHandler {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceBundleURL = [bundle URLForResource:@"Resources" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceBundleURL];
    UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Board" bundle:resourceBundle];
    MCPPhotoGroupViewController *viewController = [storyboad instantiateViewControllerWithIdentifier:@"PhotoGroupViewController"];
    
    NSString *boardId = options[@"boardId"];
    if (boardId.length) {
        viewController.boardId = boardId;
    }
    
    NSString *documentNo = options[@"documentNo"];
    if (documentNo.length) {
        viewController.documentNo = documentNo;
    }
    
    NSNumber *maxCount = options[@"maxCount"];
    if (maxCount) {
        viewController.maxCount = [maxCount integerValue];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBarHidden = YES;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:navigationController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccessNotificationHandler:) name:NotifyImageUploadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFailNotificationHandler:) name:NotifyImageUploadFail object:nil];
}

- (void)imageUploadSuccessNotificationHandler:(NSNotification *)notification {
    NSDictionary *result = notification.object;
    NSLog(@"%@", result);
}

- (void)imageUploadFailNotificationHandler:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSError *error = userInfo[@"error"];
    if (error) {
        
    }
    
    MCPResultInfo *response = userInfo[@"response"];
    if (response) {
        NSLog(@"%@", response.resultData);
    }
}

@end
  
