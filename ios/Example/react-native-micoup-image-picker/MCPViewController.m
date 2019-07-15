//
//  MCPViewController.m
//  react-native-micoup-image-picker
//
//  Created by kimkr on 07/14/2019.
//  Copyright (c) 2019 kimkr. All rights reserved.
//

@import MCPMicoupImagePicker;
#import "MCPViewController.h"

@interface MCPViewController ()

@property (nonatomic, strong) MCPMicoupImagePicker *imagePicker;

@end

@implementation MCPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagePicker = [[MCPMicoupImagePicker alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectPhotoButtonAction:(UIButton *)sender {
    [self.imagePicker showImagePickerWithOptions:@{@"boardId": @"review", @"documentNo": @"-1", @"maxCount": @(3)} completionHandler:^{
        
    }];
}

@end
