//
//  MCPPhotoGroupViewController.h
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import "MCPBaseViewController.h"

@interface MCPPhotoGroupViewController : MCPBaseViewController<UITableViewDelegate, UITableViewDataSource>{
    
    IBOutlet UITableView *_tableView;
    UIView *loadingView;
}

@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *documentNo;
@property (assign, nonatomic) NSInteger maxCount;

@end
