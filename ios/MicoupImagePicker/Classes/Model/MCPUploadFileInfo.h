//
//  MCPUploadFileInfo.h
//
//  Created by coanyaa
//  Copyright (c) 2015년 Timesystem. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"

@interface MCPUploadFileInfo : MCPModelBase

@property (strong, nonatomic) id fileData;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *mimeType;

- (id)initWithFileData:(id)data key:(NSString*)key filename:(NSString*)filename mimeType:(NSString*)mimeType;
@end
