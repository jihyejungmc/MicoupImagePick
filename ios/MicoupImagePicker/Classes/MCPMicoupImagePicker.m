
#import "MCPMicoupImagePicker.h"
#import <React/RCTLog.h>

#import "HTTPAPICommunicator.h"
#import "NSDictionary+MCPSafeConvert.h"

@interface MCPMicoupImagePicker ()

@property (nonatomic, strong) RCTPromiseResolveBlock showImagePickerResolveHandler;
@property (nonatomic, strong) RCTPromiseRejectBlock showImagePickerRejectHandler;

@end

- (instancetype)init {
    self = [super init];
    return self;
}

@implementation MCPMicoupImagePicker

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(log:(NSString *)text)
{
  RCTLogInfo(@"FROM MCPMicoupImagePicker %@", text);
}

RCT_REMAP_METHOD(showImagePickerWithOptions,
                 options:(NSDictionary *)options
                 showImagePickerWithOptionsResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    self.showImagePickerResolveHandler = resolve;
    self.showImagePickerRejectHandler = reject;
    [self showImagePicker:options];
}

- (void)showImagePicker:(NSDictionary *)options  {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceBundleURL = [bundle URLForResource:@"Resources" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceBundleURL];
    UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Board" bundle:resourceBundle];
    MCPPhotoGroupViewController *viewController = [storyboad instantiateViewControllerWithIdentifier:@"PhotoGroupViewController"];

    NSString *boardId = [options mcp_stringForKey:@"boardId"];
    if (boardId.length) {
        viewController.boardId = boardId;
    }

    NSInteger documentNo = [options mcp_integerForKey:@"documentNo"];
    viewController.documentNo = [NSString stringWithFormat: @"%ld", (long)documentNo];

    NSInteger maxCount = [options mcp_integerForKey:@"imageCount"];
    if (maxCount) {
        viewController.maxCount = maxCount;
    }

    NSString *cookie = [options mcp_stringForKey:@"cookie"];
    if (cookie) {
        [HTTPAPICommunicator sharedInstance].cookie = cookie;
    }

    NSString *userAgent = [options mcp_stringForKey:@"userAgent"];
    if (userAgent) {
        [HTTPAPICommunicator sharedInstance].userAgent = userAgent;
    }

    NSString *imageUploadURL = [options mcp_stringForKey:@"imageUploadURL"];
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
