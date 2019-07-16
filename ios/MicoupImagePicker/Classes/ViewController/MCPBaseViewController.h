//
//  MCPBaseViewController.h
//  MCPMicoupImagePicker
//
//  Created by kkr on 14/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPAPICommunicator;

@interface MCPBaseViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *naviTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *naviView;
@property (assign, nonatomic) CGRect appFrame;

@property (readonly, nonatomic) HTTPAPICommunicator *apiManager;

- (void)setupView;
- (void)showProgressWithMessage:(NSString*)message;
- (void)updateProgressMessage:(NSString*)message;
- (void)hideProgress;

- (void)makeRoundedOutlineView:(UIView*)view outlineColor:(UIColor*)outlineColor;

- (IBAction)closeAction:(id)sender;
- (IBAction)backAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
