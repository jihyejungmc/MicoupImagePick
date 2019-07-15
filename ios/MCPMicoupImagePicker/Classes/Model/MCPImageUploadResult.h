//
//  MCPImageUploadResult.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 3. 1..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"


@interface MCPImageUploadResult : MCPModelBase

@property (assign, nonatomic) BOOL isSuccess;
@property (assign, nonatomic) BOOL result;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSNumber *successCount;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSMutableArray *fileArray;

@end
