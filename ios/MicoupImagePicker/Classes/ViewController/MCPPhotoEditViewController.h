//
//  PhotoEditViewController.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

@import UIKit;
#import "MCPBaseViewController.h"

extern NSNotificationName const NotifyImageUploadSuccess;
extern NSNotificationName const NotifyImageUploadFail;

@interface MCPPhotoEditViewController : MCPBaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    BOOL isCropMode;
    
    IBOutletCollection(NSLayoutConstraint) NSArray *_sizeButtonBottomLayouts;
    IBOutletCollection(UIButton) NSArray *_sizeButtons;
    IBOutletCollection(UIButton) NSArray *_controlButtons;
    IBOutlet UICollectionView *_collectionView;
    IBOutlet UIButton *_backButton;
    IBOutlet UIButton *_cancelButton;
    IBOutlet UIView *_bottomBaseView;
    IBOutlet UIButton *_currentSizeButton;
}

@property (strong, nonatomic) NSArray *imageArray;
@property (assign, nonatomic) BOOL isModal;
@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *documentNo;

@end
