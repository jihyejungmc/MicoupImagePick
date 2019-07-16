//
//  UIViewController+ToastMessage.h
//  dingdong
//
//  Created by coanyaa on 2015. 6. 14..
//  Copyright (c) 2015년 Timesystem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ToastMessage)

- (void)showToastMessage:(NSString*)messgae;
- (void)showToastMessageAtCenter:(NSString*)messgae;
- (void)showToastMessageAtTop:(NSString*)messgae;
- (void)showToastMessage:(NSString *)messgae duration:(NSTimeInterval)duration;
@end
