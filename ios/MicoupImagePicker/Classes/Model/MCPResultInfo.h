//
//  MCPResultInfo.h
//  NameUp
//
//  Created by coanyaa on 2015. 4. 21..
//  Copyright (c) 2015년 Joy2x. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"

enum ResultCodeEnum{
    ResultCode_Success = 0,
};

@class MCPListResultInfo;
@interface MCPResultInfo : MCPModelBase

@property (assign, nonatomic) BOOL isSuccess;
@property (strong, nonatomic) NSString *errorCode;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) id jsonData;
@property (strong, nonatomic) NSString *textData;
@property (strong, nonatomic) id resultData;
@property (strong, nonatomic) NSHTTPURLResponse *urlResponse;

@end
