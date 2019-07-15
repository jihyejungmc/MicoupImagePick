//
//  HTTPAPICommunicator.m
//
//  Created by coanyaa
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
@import POSInputStreamLibrary;
@import MRProgress;
@import UIColor_Hex;
@import UIAlertController_Blocks;
@import NSString_UrlEncode;
#import "HTTPAPICommunicator.h"
//#import "AppDelegate.h"
#import "DateHelper.h"
#import "MCPUploadFileInfo.h"
#import "Utility.h"
#import "MCPImageInfo.h"
#import "MCPLoginInfo.h"



@interface HTTPAPICommunicator ()<NSURLSessionTaskDelegate>
@property (strong, nonatomic) NSMutableArray *taskArray;
@property (strong, nonatomic) NSMutableDictionary *hudDict;
@property (strong, nonatomic) AFURLSessionManager *urlSessionManager;
@property (strong, nonatomic) HTTPAPIClientResultBlock jumpCompletionHandler;

@end

@implementation HTTPAPICommunicator

+ (instancetype)sharedInstance
{
    static HTTPAPICommunicator *communicator = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        communicator = [[HTTPAPICommunicator alloc] init];
        
#if TESTMODE==1
        [communicator changeTestServer];
#else
        [communicator changeRealServer];
#endif

    });
    
    return communicator;
}

- (NSString*)imageRootAddress
{
    return [self.rootAddress stringByAppendingPathComponent:API_ROOT];
}

- (void)changeTestServer
{
    self.rootDomain = TESTROOT_DOMAIN;
}

- (void)changeRealServer
{
    self.rootDomain = REALROOT_DOMAIN;
}

- (NSString*)rootAddress
{
    return [WEB_SCHEME stringByAppendingString:self.rootDomain];
}

- (BOOL)isTestServerAddress
{
    return [self.rootAddress isEqualToString:DEFAULT_TESTURL];
}

- (BOOL)isRealServerAddress
{
    return [self.rootAddress isEqualToString:DEFAULT_REALURL];
}

- (BOOL)isInternalUrl:(NSURL*)url
{
    BOOL isRet = NO;
    
    NSString *hostString = [url.host lowercaseString];
    NSLog(@"%s %@ / %@",__FUNCTION__, [url.host lowercaseString], self.rootDomain );
    if( [hostString containsString:@"missycoupons.com"] || [hostString containsString:@"micoup.com"] || [hostString containsString:@"micoup.local"] )
        isRet = YES;
    
    return isRet;
}

- (id)init
{
    self = [super init];
    if( self ){
        self.taskArray = [NSMutableArray array];
        self.isShowProgress = NO;
        self.progressMessage = nil;
        self.hudDict = [NSMutableDictionary dictionary];
        self.urlSessionManager = [[AFURLSessionManager alloc] init];
        AFHTTPResponseSerializer *responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        [responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", nil]];
        _urlSessionManager.responseSerializer = responseSerializer;
    }
    
    return self;
}

- (void)addTask:(id)task
{
    if( [_taskArray indexOfObject:task] == NSNotFound )
        [self.taskArray addObject:task];
    else
        [task cancel];
}

- (void)removeTask:(id)task
{
    [_taskArray removeObject:task];
}


- (void)showProgressWithTask:(id)task
{
    if( self.isShowProgress ){
        NSURLSessionDataTask *dataTask = (NSURLSessionDataTask*)task;
        NSNumber *taskId = @(dataTask.taskIdentifier);
        
        MRProgressOverlayView *hud = [_hudDict objectForKey:taskId];
        if( hud ){
            [hud dismiss:YES];
            [_hudDict removeObjectForKey:taskId];
        }
        
        UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
        MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:keyWindow title:([self.progressMessage length] < 1 ? @"" : self.progressMessage) mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        [_hudDict setObject:progressView forKey:taskId];
    }
}

- (void)hideProgressWithTask:(id)task
{
    self.progressMessage = @"";

    NSURLSessionDataTask *dataTask = (NSURLSessionDataTask*)task;
    NSNumber *taskId = @(dataTask.taskIdentifier);
    MRProgressOverlayView *hud = [_hudDict objectForKey:taskId];
    if( hud ){
        [hud dismiss:YES];
    }
    [_hudDict removeObjectForKey:taskId];
}


- (void)processSuccessWithTask:(id)task responseObject:(id)responseObject complitionHandler:(HTTPAPIClientResultBlock)complitionHandler
{
    NSURLSessionTask *sessionTask = (NSURLSessionTask*)task;
    NSURLRequest *request = sessionTask.originalRequest;
    
    [self hideProgressWithTask:task];
    
    MCPResultInfo *response = nil;
    if( responseObject ){
        response = [[MCPResultInfo alloc] initWithData:responseObject];
        response.urlResponse = sessionTask.response;
        NSLog(@"%@ response data : %@",[request.URL absoluteString],response.textData);
    }
    
    if( complitionHandler ){
        complitionHandler(response,nil);
    }
    [self removeTask:task];
}

- (void)processFailWithTask:(id)task error:(NSError*)error complitionHandler:(HTTPAPIClientResultBlock)complitionHandler
{
    NSURLSessionTask *sessionTask = (NSURLSessionTask*)task;
    NSURLRequest *request = sessionTask.currentRequest;
    
    NSLog(@"%@ %@",[request.URL absoluteString],[error localizedDescription]);
    [self hideProgressWithTask:task];
    if( complitionHandler )
        complitionHandler(nil, error);
    [self removeTask:task];
}


- (NSURLSessionDataTask*)createRequestWithURL:(NSString*)url method:(NSString*)method httpHeaderParam:(NSDictionary*)httpHeaderParam parameters:(id)parameters complitionHandler:(HTTPAPIClientResultBlock)complitionHandler
{
    NSMutableDictionary *defaultParams = [self defaultHeaderParams];

    AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:url parameters:parameters error:nil];
    
    for(NSString *key in [defaultParams allKeys] ){
        [request setValue:[defaultParams objectForKey:key] forHTTPHeaderField:key];
    }
    
    for(NSString *key in [httpHeaderParam allKeys] ){
        [request setValue:[httpHeaderParam objectForKey:key] forHTTPHeaderField:key];
    }
    
    [request addValue:[Utility userAgentString] forHTTPHeaderField:@"User-Agent"];
    
    NSLog(@"%s %@ %@, http header: %@, default : %@, params:%@",__FUNCTION__,method,url,httpHeaderParam,defaultParams,parameters);
    
    __block NSURLSessionDataTask *operation = [self.urlSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if( error )
            [self processFailWithTask:operation error:error complitionHandler:complitionHandler];
        else
            [self processSuccessWithTask:operation responseObject:responseObject complitionHandler:complitionHandler];
    }];
    
//    [self showProgressWithTask:operation];
    
    [self addTask:operation];
    
    return operation;
}

- (NSURLSessionDataTask*)createMultipartFormDataRequestWithURL:(NSString*)url method:(NSString*)method httpHeaderParam:(NSDictionary*)httpHeaderParam parameters:(NSDictionary*)parameters files:(NSArray*)fileArray complitionHandler:(HTTPAPIClientResultBlock)complitionHandler
{
    
//    NSMutableDictionary *defaultParams = [self defaultHeaderParams];
//    if( parameters )
//        [defaultParams addEntriesFromDictionary:parameters];
    AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:method URLString:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UInt64 totalSize = 0;
        
        NSInteger count = 0;
        for(MCPUploadFileInfo *fileInfo in fileArray){
            if( [fileInfo.fileData isKindOfClass:[NSData class]] )
                [formData appendPartWithFileData:fileInfo.fileData name:fileInfo.key fileName:fileInfo.fileName mimeType:fileInfo.mimeType];
//            else if( [fileInfo.fileData isKindOfClass:[ALAsset class]] ){
//                ALAsset *asset = (ALAsset*)fileInfo.fileData;
//                NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
//                ALAssetRepresentation *representation = [asset defaultRepresentation];
//                
//                NSInputStream *stream = [NSInputStream pos_inputStreamWithAssetURL:assetURL];
//                [stream open];
//                //            self.uploadStream = stream;
//                [formData appendPartWithInputStream:stream name:fileInfo.key fileName:fileInfo.fileName length:[representation size] mimeType:@"application/octet-stream"];
//            }
            else if( [fileInfo.fileData isKindOfClass:[MCPImageInfo class]] ){
                MCPImageInfo *imageInfo = (MCPImageInfo*)fileInfo.fileData;
                NSURL *fileURL = [NSURL fileURLWithPath:imageInfo.sourcePath];
                NSNumber *fileSize = nil;
                [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
                totalSize += [fileSize unsignedLongLongValue];
                
                NSLog(@"%s %ld %.2fMB",__FUNCTION__, count+1, [fileSize doubleValue] / (1024.0*1024.0));
                
                NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:imageInfo.sourcePath];
                //            self.uploadStream = stream;
                [formData appendPartWithInputStream:stream name:fileInfo.key fileName:fileInfo.fileName length:[fileSize longLongValue] mimeType:@"application/octet-stream"];
            }
            count++;
        }
        NSLog(@"%s total %ld files size : %.2f MB",__FUNCTION__, count,(double)totalSize / ( 1024.0*1024.0) );
    } error:nil];
    
    
    NSDictionary *defaultParams = [self defaultHeaderParams];
    for(NSString *key in [defaultParams allKeys] ){
        [request setValue:[defaultParams objectForKey:key] forHTTPHeaderField:key];
    }
    
    for(NSString *key in [httpHeaderParam allKeys] ){
        [request setValue:[httpHeaderParam objectForKey:key] forHTTPHeaderField:key];
    }
    
    [request setValue:[Utility userAgentString] forHTTPHeaderField:@"User-Agent"];

    NSLog(@"%s %@ %@, http header: %@, default : %@, params:%@",__FUNCTION__,method,url,httpHeaderParam,defaultParams,parameters);
    __block NSURLSessionDataTask *operation = [self.urlSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if( error )
            [self processFailWithTask:operation error:error complitionHandler:complitionHandler];
        else
            [self processSuccessWithTask:operation responseObject:responseObject complitionHandler:complitionHandler];
    }];
    
    [self showProgressWithTask:operation];
    [self addTask:operation];

    return operation;
}


#pragma mark - addres control
- (NSMutableDictionary *)defaultHeaderParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
//    params[@"cookie"] = [NSString stringWithFormat:@"MCSESSID=%@;", @"84fe2ebb9cfea4401ebc272386c37429"];
    
    return params;
}

- (NSString*)getAddressWithAPI:(NSString*)api
{
    return [self.rootAddress stringByAppendingString:api];
}

#pragma mark - Common api

- (NSURLSessionDataTask*)sessionCheckWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_SESSIONCHECK];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)loginWithUserId:(NSString*)userId password:(NSString*)password isAutoLogin:(BOOL)isAutoLogin completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_LOGIN];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_USERID:userId, PARAM_PASSWORD:password, PARAM_AUTOLOGIN:( isAutoLogin ? @"true" : @"false" )}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)logoutWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_LOGOUT];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)checkNewMemoWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_CHECKMEMO];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)popoverMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_POPOVERMENULIST];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)mainMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_MAINMENULIST];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)settingMenuListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_SETTINGMENULIST];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)pageInfoWithUrl:(NSString*)pageUrl completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [[self getAddressWithAPI:API_PAGEINFO] stringByAppendingFormat:@"?%@=%@",PARAM_PAGEURL,[pageUrl URLEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)shareInfoWithUrl:(NSString*)pageUrl completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [[self getAddressWithAPI:API_SHAREINFO] stringByAppendingFormat:@"?%@=%@",PARAM_PAGEURL,[pageUrl URLEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

#pragma mark - board 
- (NSURLSessionDataTask*)selectCategoryUIWithBoardId:(NSString*)boardId categoryId:(NSString*)categoryId ageCategoryId:(NSString*)ageCategoryId completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_SELECTCATEGORYUI];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId}];
    if( categoryId )
        [params setObject:categoryId forKey:PARAM_CATEGORYID];
    if( ageCategoryId )
        [params setObject:ageCategoryId forKey:PARAM_AGECATEGORYID];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)writeDocumentForBoardId:(NSString*)boardId categoryId:(NSString*)categoryId ageCategoryId:(NSString*)ageCategoryId additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_WRITENEWDOCUMENT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId}];
    if( categoryId )
        [params setObject:categoryId forKey:PARAM_CATEGORYID];
    if( ageCategoryId )
        [params setObject:ageCategoryId forKey:PARAM_AGECATEGORYID];
    if( [additionalParams count] > 0 )
        [params addEntriesFromDictionary:additionalParams];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)writeDocumentForBoardId:(NSString*)boardId categoryParameters:(NSDictionary*)categoryParameters additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_WRITENEWDOCUMENT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId}];
    if( [categoryParameters count] > 0 )
        [params addEntriesFromDictionary:categoryParameters];
    if( [additionalParams count] > 0 )
        [params addEntriesFromDictionary:additionalParams];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)modifyDocumentForBoardId:(NSString*)boardId documentNo:(NSString*)documentNo additionalParams:(NSDictionary*)additionalParams completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_MODIFYDOCUMENT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId}];
    if( documentNo )
        [params setObject:documentNo forKey:PARAM_DOCUMENTNO];
    if( [additionalParams count] > 0 )
        [params addEntriesFromDictionary:additionalParams];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)merchantListForBoardId:(NSString*)boardId completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_MERCHANTLIST];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)postDocumentForUrl:(NSString*)postUrl boardId:(NSString*)boardId documentNo:(NSNumber*)documentNo params:(NSMutableDictionary*)params completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:postUrl];
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)boardInfoWithId:(NSString*)boardId completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_BOARDINFO];
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:@{PARAM_BOARDID:boardId} complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)additionalBoardListWithCompletionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_ADDITIONALBOARDINFO];
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:nil complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

#pragma mark - comment api
- (NSURLSessionDataTask*)writeCommentUIForBoard:(NSString*)boardId documentNo:(NSNumber*)documentNo completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_NEWCOMMENTUI];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId, PARAM_DOCUMENTNO:documentNo}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)modifyCommentUIForBoard:(NSString*)boardId documentNo:(NSNumber*)documentNo commentNo:(NSNumber*)commentNo  completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_MODIFYCOMMENTUI];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId, PARAM_DOCUMENTNO:documentNo, PARAM_COMMENTNO:commentNo }];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)postCommentForUrl:(NSString*)postUrl boardId:(NSString*)boardId documentNo:(NSString*)documentNo commentNo:(NSString*)commentNo params:(NSMutableDictionary*)params completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:postUrl];
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

#pragma mark - image
- (NSURLSessionDataTask*)uploadImageToBoard:(NSString*)boardId documentNo:(NSString*)documentNo files:(NSArray*)files completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_UPLOADIMAGES];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId, PARAM_DOCUMENTNO:( [documentNo length] < 1 ? @"-1" : documentNo)}];
    
    NSURLSessionDataTask *operation = [self createMultipartFormDataRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params files:files complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)deleteImage:(NSNumber*)imageId serial:(NSString*)serial completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_DELETEIMAGE];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_IMAGEID:imageId, PARAM_SERIAL:serial}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

#pragma mark - file download
- (NSURLSessionDownloadTask*)downloadFileFromURL:(NSString*)fileUrl downPath:(NSString*)downPath parameters:(NSDictionary*)parameters progress:(HTTPDownloadProgressBlock)progress completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSMutableDictionary *defaultParams = [self defaultHeaderParams];
    
    AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:fileUrl parameters:parameters error:nil];
    
    for(NSString *key in [defaultParams allKeys] ){
        [request setValue:[defaultParams objectForKey:key] forHTTPHeaderField:key];
    }
    [request addValue:[Utility userAgentString] forHTTPHeaderField:@"User-Agent"];
    
    NSLog(@"%s %@ %@, default : %@, params:%@",__FUNCTION__,@"GET",fileUrl,defaultParams,parameters);
    
    __block NSURLSessionDownloadTask *operation = [self.urlSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if( progress )
            progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:downPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if( error )
            [self processFailWithTask:operation error:error complitionHandler:completionHandler];
        else{
            [self hideProgressWithTask:operation];
            
            MCPResultInfo *response = [[MCPResultInfo alloc] init];
            response.isSuccess = YES;
            response.resultData = [filePath path];
            if( completionHandler ){
                completionHandler(response,nil);
            }
            [self removeTask:operation];
        }
    }];
    
    [self showProgressWithTask:operation];
    [self addTask:operation];
    [operation resume];
    
    return operation;
}

- (void)isExistsFileAtUrl:(NSString*)urlString completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSRange range = [urlString rangeOfString:@"http" options:NSCaseInsensitiveSearch];
    if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
        urlString = [@"http://" stringByAppendingString:urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //MAKING A HEAD REQUEST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    request.timeoutInterval = 3;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         if (connectionError == nil) {
             if ((long)[httpResponse statusCode] == 200)
             {
                 //FILE EXISTS
                 NSDictionary *dic = httpResponse.allHeaderFields;
                 if( completionHandler ){
                     MCPResultInfo *info = [[MCPResultInfo alloc] init];
                     info.isSuccess = YES;
                     NSString *length = [dic valueForKey:@"Content-Length"];
                     info.resultData = dic;
                     completionHandler(info, nil);
                 }
             }
             else
             {
                 //FILE DOESNT EXIST
                 if( completionHandler ){
                     MCPResultInfo *info = [[MCPResultInfo alloc] init];
                     info.isSuccess = YES;
                     info.resultData = nil;
                     completionHandler(info, nil);
                 }
             }
         }
         else
         {
             if( completionHandler ){
                 MCPResultInfo *info = [[MCPResultInfo alloc] init];
                 info.isSuccess = NO;
                 info.resultData = nil;
                 completionHandler(info,connectionError);
             }
         }
     }];
}

#pragma mark - common error
- (void)processError:(NSError*)error completion:(void (^)(NSHTTPURLResponse *response))completion
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"];
    NSData *errorData = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    BOOL isShowDefaultAlert = NO;
    if( [errorData length] > 0 ){
        NSString *errorString = [[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if( [errorString length] > 0 ){
            UIViewController *topMostViewController = [Utility topMostViewController];
            [UIAlertController showAlertInViewController:topMostViewController withTitle:nil message:errorString cancelButtonTitle:@"확인" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                if( completion )
                    completion( response );
            }];
        }
        else
            isShowDefaultAlert = YES;
    }
    else
        isShowDefaultAlert = YES;
    
    if( isShowDefaultAlert ){
        UIViewController *topMostViewController = [Utility topMostViewController];
        [UIAlertController showAlertInViewController:topMostViewController withTitle:nil message:[error localizedFailureReason] cancelButtonTitle:@"확인" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            if( completion )
                completion( response );
        }];
    }
}

#pragma mark - login OTP
- (NSURLSessionDataTask*)otpLoginWithMemberNo:(NSString*)memberNo password:(NSString*)password completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_AUTHORIZEOTP];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_MEMBERNO:memberNo, PARAM_PASSWORD:password}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"POST" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

#pragma mark - other
- (void)queryToJumpPageWithUrl:(NSURL*)url userAgent:(NSString*)userAgent completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *queryUrl = [self getAddressWithAPI:@"/jump.jsp"];
    NSString *paramUrl = [[url absoluteString] URLEncode];
    queryUrl = [queryUrl stringByAppendingFormat:@"?%@",paramUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryUrl]];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    request.HTTPShouldUsePipelining = NO;
    [request setValue:self.rootAddress forHTTPHeaderField:@"Referer"];
    if( [userAgent length] > 0 )
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    self.jumpCompletionHandler = completionHandler;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)queryRedirectWithUrl:(NSURL*)url userAgent:(NSString*)userAgent completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    request.HTTPShouldUsePipelining = NO;
    [request setValue:self.rootAddress forHTTPHeaderField:@"Referer"];
    if( [userAgent length] > 0 )
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    self.jumpCompletionHandler = completionHandler;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    NSDictionary *dic = httpResponse.allHeaderFields;
    if( self.jumpCompletionHandler ){
        MCPResultInfo *info = [[MCPResultInfo alloc] init];
        info.isSuccess = YES;
        info.resultData = dic;
        info.urlResponse = httpResponse;
        self.jumpCompletionHandler(info, error);
    }
    
    self.jumpCompletionHandler = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *newRequest = request;
    if (redirectResponse) {
        newRequest = nil;
    }
    
    completionHandler(newRequest);
}

#pragma mark - lock
- (NSURLSessionDataTask*)lockDocumentWithBoardId:(NSString*)boardId documentNo:(NSString*)documentNo updated:(NSString*)updated  completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_LOCK];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId, PARAM_DOCUMENTNO:documentNo, PARAM_UPDATED:updated}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}

- (NSURLSessionDataTask*)unlockDocumentWithBoardId:(NSString*)boardId documentNo:(NSString*)documentNo updated:(NSString*)updated completionHandler:(HTTPAPIClientResultBlock)completionHandler
{
    NSString *url = [self getAddressWithAPI:API_UNLOCK];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{PARAM_BOARDID:boardId, PARAM_DOCUMENTNO:documentNo, PARAM_UPDATED:updated}];
    
    NSURLSessionDataTask *operation = [self createRequestWithURL:url method:@"GET" httpHeaderParam:nil parameters:params complitionHandler:completionHandler];
    [operation resume];
    
    return operation;
}


@end
