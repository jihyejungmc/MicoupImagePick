//
//  MCPPhotoEditInfo.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 2. 7..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

@import UIKit;
#import "MCPModelBase.h"

typedef NS_ENUM(NSInteger, EditImageMode){
    EditImageMode_Original,
    EditImageMode_W400,
    EditImageMode_W800,
};

@interface MCPPhotoEditInfo : MCPModelBase

@property (assign, nonatomic) EditImageMode imageMode;
@property (strong, nonatomic) id imageSource;
@property (strong, nonatomic) UIImage *editedImage;
@property (strong, nonatomic) UIImage *originalImage;
@property (readonly, nonatomic) NSString *originalFilename;
@property (readonly, nonatomic) NSString *editingFilename;
@property (assign, nonatomic) BOOL isModified;

- (id)initWithSource:(id)source;
- (void)loadOriginalImageWithCompletion:(void (^)(UIImage *image))completion;
- (NSData*)imageData;
- (void)loadOrCreateEditingImageWithCompletion:(void (^)(UIImage *image))completion;
- (void)createEditingImageFromOriginalImageWithCompletion:(void (^)(NSString *imagePath))completion;
- (void)saveEditingImage;


@end
