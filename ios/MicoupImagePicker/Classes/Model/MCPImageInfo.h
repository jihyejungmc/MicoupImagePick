//
//  MCPImageInfo.h
//
//  Created by coanyaa
//  Copyright © 2016년 Timesystem. All rights reserved.
//

@import UIKit;

@interface MCPImageInfo : NSObject

@property (strong, nonatomic) NSString *sourcePath;
@property (strong, nonatomic) NSString *thumbnailPath;

- (id)initWithSourceImage:(UIImage*)image saveFolder:(NSString*)saveFolder;

- (UIImage*)thumbnailImage;
- (void)removeFiles;

@end
