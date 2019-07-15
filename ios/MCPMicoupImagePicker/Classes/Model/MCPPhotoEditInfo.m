//
//  MCPPhotoEditInfo.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 2. 7..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
@import SDWebImage;
#import "MCPPhotoEditInfo.h"
#import "UIImage+FixOrientation.h"
#import "Utility.h"

@implementation MCPPhotoEditInfo

- (void)dealloc
{
    self.originalImage = nil;
    self.editedImage = nil;
    self.imageSource = nil;
}

- (id)initWithSource:(id)source
{
    self = [super init];
    if( self ){
        if( [source isKindOfClass:[UIImage class]] ){
            NSString *filename = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
            NSString *path = [Utility filePathFromCachDirectory:filename];
            @autoreleasepool{
                NSData *originalData = UIImageJPEGRepresentation(source, 0.7);
                [originalData writeToFile:path atomically:YES];
                originalData = nil;
            }
            self.imageSource = path;
        }
        else{
            self.imageSource = source;
        }
        self.isModified = NO;
    }
    
    return self;
}

- (void)loadOriginalImageWithCompletion:(void (^)(UIImage *image))completion
{
    if( [_imageSource isKindOfClass:[UIImage class]] ){
        self.originalImage = _imageSource;
        self.editedImage = self.originalImage;
        if( completion )
            completion(self.originalImage);
    }
    else if( [_imageSource isKindOfClass:[ALAsset class]] ){
        ALAsset *asset = (ALAsset*)_imageSource;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        UIImageOrientation imgOrientation = (UIImageOrientation)[rep orientation];
        self.originalImage = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:[rep scale] orientation:( imgOrientation == UIImageOrientationRight || imgOrientation == UIImageOrientationLeft ? imgOrientation : UIImageOrientationUp)];//(UIImageOrientation)[rep orientation]];
        self.editedImage = self.originalImage;
        if( completion )
            completion(self.originalImage);
    }
    else if( [_imageSource isKindOfClass:[NSURL class]] ){
        // remote image
        NSURL *imageUrl = (NSURL*)_imageSource;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if( error == nil && finished){
                self.originalImage = image;
                self.editedImage = self.originalImage;
                if( completion )
                    completion(image);
            }
        }];
    }
    else if( [_imageSource isKindOfClass:[NSString class]] ){
        // local image
        self.originalImage = [UIImage imageWithContentsOfFile:(NSString*)_imageSource];
        self.editedImage = self.originalImage;
        if( completion )
            completion(self.originalImage);
    }
}

- (NSString*)originalFilename
{
    NSString *filename = nil;
    if( [_imageSource isKindOfClass:[UIImage class]] ){
        filename = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
    }
    else if( [_imageSource isKindOfClass:[ALAsset class]] ){
        ALAsset *asset = (ALAsset*)_imageSource;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        filename = rep.filename;
    }
    else if( [_imageSource isKindOfClass:[NSURL class]] ){
        // remote image
        NSURL *imageUrl = (NSURL*)_imageSource;
        filename = [imageUrl.absoluteString lastPathComponent];
    }
    else if( [_imageSource isKindOfClass:[NSString class]] ){
        // local image
        NSString *path = (NSString*)_imageSource;
        filename = [path lastPathComponent];
    }
    
    return filename;
}

- (NSData*)imageData
{
    NSData *data = nil;
    if( [_imageSource isKindOfClass:[UIImage class]] ){
        data = UIImageJPEGRepresentation(_imageSource, 0.7);
    }
    else if( [_imageSource isKindOfClass:[ALAsset class]] ){
        ALAsset *asset = (ALAsset*)_imageSource;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0 length:(NSUInteger)rep.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    else if( [_imageSource isKindOfClass:[NSURL class]] ){
        // remote image
        data = [NSData dataWithContentsOfURL:(NSURL*)_imageSource];
    }
    else if( [_imageSource isKindOfClass:[NSString class]] ){
        // local image
        NSString *path = (NSString*)_imageSource;
        data = [NSData dataWithContentsOfFile:path];
    }
    
    return data;
}

- (NSString*)editingFilename
{
    NSString *sourceFilename = self.originalFilename;
    NSString *retFilename = [[[sourceFilename stringByDeletingPathExtension] stringByAppendingString:@"_editing"] stringByAppendingPathExtension:[sourceFilename pathExtension]];
    
    return retFilename;
}

- (void)loadOrCreateEditingImageWithCompletion:(void (^)(UIImage *image))completion
{
    NSString *filename = self.editingFilename;
    if( [filename length] > 0){
        NSString *path = [Utility filePathFromCachDirectory:filename];
        if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ){
            @autoreleasepool{
                NSData *originalData = [self imageData];
                [originalData writeToFile:path atomically:YES];
                originalData = nil;
            }
        }

        if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
            self.editedImage = [UIImage imageWithContentsOfFile:path];
        
        if( completion )
            completion(self.editedImage);
    }
    else{
        if( completion )
            completion(nil);
    }
}

- (void)createEditingImageFromOriginalImageWithCompletion:(void (^)(NSString *imagePath))completion
{
    NSString *filename = self.editingFilename;
    if( [filename length] > 0){
        NSString *path = [Utility filePathFromCachDirectory:filename];
        @autoreleasepool{
            NSData *originalData = [self imageData];
            [originalData writeToFile:path atomically:YES];
            originalData = nil;
        }
        self.isModified = NO;
        if( completion )
            completion(path);
    }
    else{
        if( completion )
            completion(nil);
    }
}

- (void)saveEditingImage
{
    if( self.editedImage ){
        NSString *filename = self.editingFilename;
        NSString *path = [Utility filePathFromCachDirectory:filename];
        @autoreleasepool{
            NSData *imgData = nil;
            if( [[[filename pathExtension] lowercaseString] isEqualToString:@"png"] ){
                imgData = UIImagePNGRepresentation(self.editedImage);
            }
            else{
                imgData = UIImageJPEGRepresentation(self.editedImage, 0.7);
            }
            [imgData writeToFile:path atomically:YES];
            imgData = nil;
        }
    }
}

@end
