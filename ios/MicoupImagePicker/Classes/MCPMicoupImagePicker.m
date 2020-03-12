
#import "MCPMicoupImagePicker.h"
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <AVFoundation/AVFoundation.h>

#import "HTTPAPICommunicator.h"
#import "MCPPhotoGroupViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPImageUploadResult.h"
#import "MCPPhotoEditInfo.h"
#import "MCPCameraViewController.h"

@interface MCPMicoupImagePicker ()

@property (nonatomic, strong) RCTPromiseResolveBlock showImagePickerResolveHandler;
@property (nonatomic, strong) RCTPromiseRejectBlock showImagePickerRejectHandler;

@end

@implementation MCPMicoupImagePicker


- (instancetype)init {
    self = [super init];
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(log:(NSString *)text) {
  RCTLogInfo(@"FROM MCPMicoupImagePicker %@", text);
}

RCT_EXPORT_METHOD(showImagePickerWithOptions:(NSDictionary *)options
                              resolveHandler:(RCTPromiseResolveBlock)resolve
                               rejectHandler:(RCTPromiseRejectBlock)reject) {
    self.showImagePickerResolveHandler = resolve;
    self.showImagePickerRejectHandler = reject;
    [self showImagePicker:options];
}

RCT_EXPORT_METHOD(openCameraWithOptions:(NSDictionary *)options
                              resolveHandler:(RCTPromiseResolveBlock)resolve
                               rejectHandler:(RCTPromiseRejectBlock)reject) {
    self.showImagePickerResolveHandler = resolve;
    self.showImagePickerRejectHandler = reject;
    [self openCamera:options];
}

- (void)openCamera:(NSDictionary *)options  {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceBundleURL = [bundle URLForResource:@"Resources" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceBundleURL];
    UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Board" bundle:resourceBundle];
    MCPCameraViewController *viewController = [storyboad instantiateViewControllerWithIdentifier:@"CameraViewController"];


    NSString *boardId = options[@"boardId"];
    if (boardId.length) {
        viewController.boardId = boardId;
    }

    NSString *documentNo = options[@"documentNo"];
    if (documentNo.length) {
        viewController.documentNo = documentNo;
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
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    navigationController.navigationBarHidden = YES;

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:navigationController animated:YES completion:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccessNotificationHandler:) name:NotifyImageUploadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFailNotificationHandler:) name:NotifyImageUploadFail object:nil];
}

- (void)showImagePicker:(NSDictionary *)options  {
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

    NSNumber *maxCount = options[@"imageCount"];
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
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    navigationController.navigationBarHidden = YES;

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:navigationController animated:YES completion:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccessNotificationHandler:) name:NotifyImageUploadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFailNotificationHandler:) name:NotifyImageUploadFail object:nil];
}

- (void)imageUploadSuccessNotificationHandler:(NSNotification *)notification {
    MCPImageUploadResult *result = notification.userInfo[@"result"];
    NSDictionary *resultDic = [result dictionaryObject];
    NSLog(@"%@", resultDic);

    if (self.showImagePickerResolveHandler) {
        self.showImagePickerResolveHandler(resultDic);
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
