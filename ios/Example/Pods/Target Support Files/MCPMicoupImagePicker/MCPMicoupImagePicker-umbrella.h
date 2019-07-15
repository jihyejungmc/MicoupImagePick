#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MCPMicoupImagePicker.h"
#import "MCPBaseViewController.h"
#import "MCPPhotoEditResultViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoGroupViewController.h"
#import "MCPPhotoSelectViewController.h"
#import "MCPImageInfo.h"
#import "MCPImageUploadResult.h"
#import "MCPListResultInfo.h"
#import "MCPLoginInfo.h"
#import "MCPModelBase.h"
#import "MCPPhotoEditInfo.h"
#import "MCPRemoteImageInfo.h"
#import "MCPResultInfo.h"
#import "MCPUploadFileInfo.h"

FOUNDATION_EXPORT double MCPMicoupImagePickerVersionNumber;
FOUNDATION_EXPORT const unsigned char MCPMicoupImagePickerVersionString[];

