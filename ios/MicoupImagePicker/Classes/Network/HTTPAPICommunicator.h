//
//  HTTPAPICommunicator.h
//
//  Created by coanyaa
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

@import Foundation;
#import <AFNetworking/AFNetworking.h>

#import "MCPResultInfo.h"

#define USE_HTTPS   1

#define TESTROOT_DOMAIN                     @"a-s1.micoup.com"
#define REALROOT_DOMAIN                     @"www.missycoupons.com"

#if (USE_HTTPS == 1)
#define WEB_SCHEME                          @"https://"
#else
#define WEB_SCHEME                          @"http://"
#endif

#define DEFAULT_TESTURL                     WEB_SCHEME TESTROOT_DOMAIN
#define DEFAULT_REALURL                     WEB_SCHEME REALROOT_DOMAIN

#define PAGE_ROOT                           @"/app.jsp"

#define PAGE_FINDPASSWORD                   @"/zero/lostpw.php"
#define PAGE_FINDID                         @"/zero/lostid.php"
#define PAGE_MEMBERREGISTER                 @"/zero/join.php?group_no=1"
#define PAGE_HELP                           @"/zero/board.php#id=faq"
#define PAGE_LOGIN                          @"/zero/login.php"
#define PAGE_MEMBERMEMO                     @"/zero/member_memo.php"
#define PAGE_WRITEDOCUMENT                  @"/zero/write.php"
#define PAGE_NEWCOMMENT                     @"/zero/new_comment.php"
#define PAGE_GALLERY                        @"/zero/product_image_gallery.php"
#define PAGE_WRITEMEMO                      @"/zero/view_info.php"
#define PAGE_MEMBERINFO                     @"/zero/view_info2.php"
#define PAGE_FILEBOX                        @"/zero/file_box.php"
#define PAGE_IMAGEBOX                       @"/zero/image_box.php"
#define PAGE_SEARCH                         @"/zero/search_main.php"
#define PAGE_CAFELIST                       @"/zero/board.php#f=cafes"
#define PAGE_MODIFYCOMMENT                  @"/zero/modify_comment.php"
#define PAGE_BOARD                          @"/zero/board.php"

#define API_ROOT                            @"/zero"
#define API_LOGIN                           API_ROOT @"/p/login.php"
#define API_LOGOUT                          API_ROOT @"/p/logout.php"
#define API_CHECKMEMO                       API_ROOT @"/d/mi_new_memo.php"
#define API_POPOVERMENULIST                 API_ROOT @"/j/logo_list.php"
#define API_MAINMENULIST                    API_ROOT @"/j/menu_list.php"
#define API_SETTINGMENULIST                 API_ROOT @"/j/mysettings.php"
#define API_SESSIONCHECK                    API_ROOT @"/j/session_check.php"
#define API_BOARDINFO                       API_ROOT @"/j/get_board_info.php"
#define API_ADDITIONALBOARDINFO             API_ROOT @"/j/additional_boards_list.php"

#define API_SELECTCATEGORYUI                API_ROOT @"/j/ui/select_category_ui.php"
#define API_WRITENEWDOCUMENT                API_ROOT @"/j/ui/new_post_ui.php"
#define API_MODIFYDOCUMENT                  API_ROOT @"/j/ui/modify_post_ui.php"
#define API_MERCHANTLIST                    API_ROOT @"/j/ui/merchant_list.php"

#define API_NEWCOMMENTUI                    API_ROOT @"/j/ui/new_comment_ui.php"
#define API_MODIFYCOMMENTUI                 API_ROOT @"/j/ui/modify_comment_ui.php"

#define API_UPLOADIMAGES                    API_ROOT @"/p/file_upload.php"
#define API_DELETEIMAGE                     API_ROOT @"/p/file_delete.php"
#define API_WRITEDOCUMENT                   API_ROOT @"/wrt_ok.php"

#define API_PAGEINFO                        API_ROOT @"/j/get_page_info.php"
#define API_AUTHORIZEOTP                    API_ROOT @"/p/authorize_otp.php"
#define API_SHAREINFO                       API_ROOT @"/j/get_share_info.php"

#define API_LOCK                            API_ROOT @"/wiki/dynamic_lock.php"
#define API_UNLOCK                          API_ROOT @"/wiki/dynamic_unlock.php"

#define PARAM_USERID                        @"user_id"
#define PARAM_PASSWORD                      @"password"
#define PARAM_AUTOLOGIN                     @"auto_login"

#define PARAM_BOARDID                       @"id"
#define PARAM_CATEGORYID                    @"category"
#define PARAM_AGECATEGORYID                 @"age_category_id"
#define PARAM_DOCUMENTNO                    @"no"
#define PARAM_IMAGEID                       @"image_id"
#define PARAM_SERIAL                        @"serial"
#define PARAM_COMMENTNO                     @"comment_no"
#define PARAM_PAGEURL                       @"page_url"
#define PARAM_MEMBERNO                      @"member_no"
#define PARAM_UPDATED                       @"updated"

typedef void (^HTTPAPIClientResultBlock)(MCPResultInfo *response, NSError *error);
typedef void (^HTTPDownloadProgressBlock)(NSProgress *downloadProgress);


@interface HTTPAPICommunicator : NSObject{
}

@property (assign, nonatomic) BOOL isShowProgress;
@property (strong, nonatomic) NSString *progressMessage;
@property (readonly, nonatomic) NSString *rootAddress;
@property (strong, nonatomic) NSString *rootDomain;
@property (readonly, nonatomic) NSString *imageRootAddress;

@property (copy, nonatomic) NSString *cookie;
@property (copy, nonatomic) NSString *userAgent;
@property (copy, nonatomic) NSString *imageUploadURL;

+ (instancetype)sharedInstance;

- (NSString*)getAddressWithAPI:(NSString*)api;
- (void)changeTestServer;
- (void)changeRealServer;
- (BOOL)isTestServerAddress;
- (BOOL)isRealServerAddress;
- (BOOL)isInternalUrl:(NSURL*)url;

#pragma mark - Common api

- (NSURLSessionDataTask*)sessionCheckWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)loginWithUserId:(NSString*)userId password:(NSString*)password isAutoLogin:(BOOL)isAutoLogin completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)logoutWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)checkNewMemoWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;

- (NSURLSessionDataTask*)popoverMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)mainMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)settingMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)pageInfoWithUrl:(NSString*)pageUrl completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)shareInfoWithUrl:(NSString*)pageUrl completionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - board api
- (NSURLSessionDataTask*)selectCategoryUIWithBoardId:(NSString*)boardId categoryId:(NSString*)categoryId ageCategoryId:(NSString*)ageCategoryId completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)writeDocumentForBoardId:(NSString*)boardId categoryId:(NSString*)categoryId ageCategoryId:(NSString*)ageCategoryId additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)writeDocumentForBoardId:(NSString*)boardId categoryParameters:(NSDictionary*)categoryParameters additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler;

- (NSURLSessionDataTask*)modifyDocumentForBoardId:(NSString*)boardId documentNo:(NSString*)documentNo additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)merchantListForBoardId:(NSString*)boardId completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)postDocumentForUrl:(NSString*)postUrl boardId:(NSString*)boardId documentNo:(NSNumber*)documentNo params:(NSMutableDictionary*)params completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)boardInfoWithId:(NSString*)boardId completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)additionalBoardListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - comment api
- (NSURLSessionDataTask*)writeCommentUIForBoard:(NSString*)boardId documentNo:(NSNumber*)documentNo completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)modifyCommentUIForBoard:(NSString*)boardId documentNo:(NSNumber*)documentNo commentNo:(NSNumber*)commentNo  completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)postCommentForUrl:(NSString*)postUrl boardId:(NSString*)boardId documentNo:(NSString*)documentNo commentNo:(NSString*)commentNo params:(NSMutableDictionary*)params completionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - image
- (NSURLSessionDataTask*)uploadImageToBoard:(NSString*)boardId documentNo:(NSString*)documentNo files:(NSArray*)files completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)deleteImage:(NSNumber*)imageId serial:(NSString*)serial completionHandler:(HTTPAPIClientResultBlock)completionHandler;

// download
- (NSURLSessionDownloadTask*)downloadFileFromURL:(NSString*)fileUrl downPath:(NSString*)downPath parameters:(NSDictionary*)parameters progress:(HTTPDownloadProgressBlock)progress completionHandler:(HTTPAPIClientResultBlock)completionHandler;

- (void)isExistsFileAtUrl:(NSString*)urlString completionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - common error
- (void)processError:(NSError*)error completion:(void (^)(NSHTTPURLResponse *response))completion;

#pragma mark - login OTP
- (NSURLSessionDataTask*)otpLoginWithMemberNo:(NSString*)memberNo password:(NSString*)password completionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - other
- (void)queryToJumpPageWithUrl:(NSURL*)url userAgent:(NSString*)userAgent completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (void)queryRedirectWithUrl:(NSURL*)url userAgent:(NSString*)userAgent completionHandler:(HTTPAPIClientResultBlock)completionHandler;

#pragma mark - lock
- (NSURLSessionDataTask*)lockDocumentWithBoardId:(NSString*)boardId documentNo:(NSString*)documentNo updated:(NSString*)updated  completionHandler:(HTTPAPIClientResultBlock)completionHandler;
- (NSURLSessionDataTask*)unlockDocumentWithBoardId:(NSString*)boardId documentNo:(NSString*)documentNo updated:(NSString*)updated completionHandler:(HTTPAPIClientResultBlock)completionHandler;

@end
