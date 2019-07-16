//
//  MCPImageInfo.m
//
//  Created by coanyaa
//  Copyright © 2016년 Timesystem. All rights reserved.
//

#import "MCPImageInfo.h"
#import "Utility.h"
#import "ScreenUtil.h"
#import "DateHelper.h"

@implementation MCPImageInfo

- (id)initWithSourceImage:(UIImage*)image saveFolder:(NSString*)saveFolder
{
    self = [super init];
    if( self ){
        
        NSString *filename = [DateHelper dateStringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmssSSS"];
        NSString *thumbnailName = [filename stringByAppendingString:@"_thumbnail"];
        
        self.sourcePath = [[saveFolder stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"jpg"];
        self.thumbnailPath = [[saveFolder stringByAppendingPathComponent:thumbnailName] stringByAppendingPathExtension:@"jpg"];
        
        UIImage *thumbnailImage = [ScreenUtil resizeImage:image size:CGSizeMake(192, 192.0) isApplyRatio:YES];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        [imageData writeToFile:self.sourcePath atomically:YES];
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.7);
        [thumbnailData writeToFile:self.thumbnailPath atomically:YES];
    }
    
    return self;
}

- (UIImage*)thumbnailImage
{
    return [UIImage imageWithContentsOfFile:self.thumbnailPath];
}

- (void)removeFiles
{
    NSFileManager *nf = [NSFileManager defaultManager];
    if( [self.sourcePath length] > 0 ){
        if( [nf fileExistsAtPath:self.sourcePath] )
            [nf removeItemAtPath:self.sourcePath error:nil];
    }
    if( [self.thumbnailPath length] > 0 ){
        if( [nf fileExistsAtPath:self.thumbnailPath] )
            [nf removeItemAtPath:self.thumbnailPath error:nil];
    }
    self.sourcePath = nil;
    self.thumbnailPath = nil;
}

@end
