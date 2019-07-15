//
//  MCPUploadFileInfo.m
//
//  Created by coanyaa
//  Copyright (c) 2015년 Timesystem. All rights reserved.
//

#import "MCPUploadFileInfo.h"

@implementation MCPUploadFileInfo

- (id)initWithFileData:(id)data key:(NSString*)key filename:(NSString*)filename mimeType:(NSString*)mimeType
{
    self = [super init];
    if( self ){
        self.fileData = data;
        self.fileName = filename;
        self.key = key;
        self.mimeType = mimeType;
    }
    return self;
}

@end
