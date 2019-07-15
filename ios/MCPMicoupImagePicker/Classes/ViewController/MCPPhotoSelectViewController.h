//
//  MCPPhotoSelectViewController.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "MCPBaseViewController.h"

@interface MCPPhotoSelectViewController : MCPBaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    CGSize cellSize;
    
    IBOutlet UICollectionView *_collectionView;
    IBOutlet UILabel *_countLabel;
    IBOutlet UIButton *_editButton;
    IBOutlet UIButton *_addButton;
}

@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *documentNo;
@property (assign, nonatomic) NSInteger maxCount;

@end
