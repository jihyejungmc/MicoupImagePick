
#import "MCPMicoupImagePicker.h"

#import "HTTPAPICommunicator.h"


@interface MCPMicoupImagePicker ()

@property (nonatomic, strong) RCTPromiseResolveBlock showImagePickerResolveHandler;
@property (nonatomic, strong) RCTPromiseRejectBlock showImagePickerRejectHandler;

@end

@implementation MCPMicoupImagePicker

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(showImagePickerWithOptions,
                 options:(NSDictionary *)options
                 showImagePickerResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    self.showImagePickerResolveHandler = resolve;
    self.showImagePickerRejectHandler = reject;
    [self showImagePickerWithOptions:options];
}

- (void)showImagePickerWithOptions:(NSDictionary *)options {
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

    NSString *cookie = options[@"cookie"];
    if (cookie) {
        [HTTPAPICommunicator sharedInstance].cookie = cookie;
    }

    NSString *userAgent = options[@"userAgent"];
    if (userAgent) {
        [HTTPAPICommunicator sharedInstance].userAgent = userAgent;
    }

    NSString *imageUploadURL = options[@"imageUploadURL"];
    if (imageUploadURL) {
        [HTTPAPICommunicator sharedInstance].imageUploadURL = imageUploadURL;
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

    if (self.showImagePickerResolveHandler) {
        self.showImagePickerResolveHandler(result);
    }

    self.showImagePickerResolveHandler = nil;
    self.showImagePickerRejectHandler = nil;
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

    if (self.showImagePickerRejectHandler) {
        NSString *code = [NSString stringWithFormat:@"%d", error.code];
        NSString *message = error.localizedDescription;
        self.showImagePickerRejectHandler(code, message, error);
    }

    self.showImagePickerResolveHandler = nil;
    self.showImagePickerRejectHandler = nil;
}

@end
