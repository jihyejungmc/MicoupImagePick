//
//  UIImage+ExifMetaData.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 10. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "UIImage+ExifMetaData.h"

@implementation UIImage (ExifMetaData)

- (NSData*)jpegDataByRemovingExif
{
    NSData *imageData = UIImageJPEGRepresentation(self, 0.7);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    NSMutableData *mutableData = nil;
    
    if (source) {
        CFStringRef type = CGImageSourceGetType(source);
        size_t count = CGImageSourceGetCount(source);
        mutableData = [NSMutableData data];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)mutableData, type, count, NULL);
        
        NSDictionary *removeExifProperties = @{(id)kCGImagePropertyExifDictionary: (id)kCFNull,
                                               (id)kCGImagePropertyGPSDictionary : (id)kCFNull};
        
        if (destination) {
            for (size_t index = 0; index < count; index++) {
                CGImageDestinationAddImageFromSource(destination, source, index, (__bridge CFDictionaryRef)removeExifProperties);
            }
            
            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"CGImageDestinationFinalize failed");
            }
            
            CFRelease(destination);
        }
        
        CFRelease(source);
    }
    
    return mutableData;
}

- (NSArray*)metadata
{
    NSData *imageData = UIImageJPEGRepresentation(self, 0.7);
    
    NSArray *metadataArray = nil;
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    
    if (source) {
        CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(source, 0, NULL);
        if (metadata) {
            metadataArray = CFBridgingRelease(CGImageMetadataCopyTags(metadata));
            CFRelease(metadata);
        }
        CFRelease(source);
    }
    
    return metadataArray;
}

@end
