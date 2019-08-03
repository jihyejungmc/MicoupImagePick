//
//  MCPCameraViewController.h
//  Pods
//
//  Created by kkr on 03/08/2019.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "MCPBaseViewController.h"

@interface MCPCameraViewController : MCPBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
  
}

@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *documentNo;

@end
