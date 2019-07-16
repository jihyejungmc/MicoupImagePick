//
//  MCPBaseViewController.m
//  MCPMicoupImagePicker
//
//  Created by kkr on 14/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <MRProgress/MRProgress.h>
#import <UIColor+Hex/UIColor+Hex.h>

#import "MCPBaseViewController.h"

#import "HTTPAPICommunicator.h"
#import "Utility.h"


@interface MCPBaseViewController ()

@property (strong, nonatomic) __block MRProgressOverlayView *hudProgress;

@end

@implementation MCPBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appFrame = [UIScreen mainScreen].bounds;
    if (self.naviView) {
        self.naviView.layer.shadowOffset = CGSizeMake(0.0, 0.5);
        self.naviView.layer.shadowRadius = 0.0;
        self.naviView.layer.shadowOpacity = 1.0;
        self.naviView.layer.shadowColor = [UIColor colorWithHex:0xededed].CGColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupView];
}

- (void)setupView
{
    if( [self.title length] > 0 )
        self.naviTitleLabel.text = self.title;
}

#pragma mark - Property

- (HTTPAPICommunicator*)apiManager
{
    return [HTTPAPICommunicator sharedInstance];
}

#pragma mark - Instance Method

- (void)showProgressWithMessage:(NSString*)message
{
    if( self.hudProgress )
        [self.hudProgress dismiss:NO];
    
    self.hudProgress = [MRProgressOverlayView showOverlayAddedTo:self.view title:( [message length] > 0 ? message : @"") mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
}

- (void)updateProgressMessage:(NSString*)message
{
    if( self.hudProgress ){
        _hudProgress.titleLabelText = message;
    }
}

- (void)hideProgress
{
    if( self.hudProgress )
        [self.hudProgress dismiss:YES];
    self.hudProgress = nil;
}

- (void)makeRoundedOutlineView:(UIView*)view outlineColor:(UIColor*)outlineColor
{
    [Utility makeOutlineWithView:view outlineColor:outlineColor outlineWidth:1.0 cornerRadius:5.0];
}

#pragma mark - Action

- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender
{
    if( self.navigationController )
        [self.navigationController popViewControllerAnimated:YES];
}

@end
