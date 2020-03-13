//
//  MCPCameraViewController.m
//  AFNetworking
//
//  Created by kkr on 03/08/2019.
//

#import <Foundation/Foundation.h>
#import "MCPCameraViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoEditInfo.h"

@interface MCPCameraViewController ()

@end

@implementation MCPCameraViewController

- (void)setupView
{
  [super setupView];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self openCamera];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)openCamera
{
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.editing = NO;
  if( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
    return;
  }
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [picker dismissViewControllerAnimated:YES completion:^{
        [rootViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
  MCPPhotoEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoEditViewController"];
  NSMutableArray *imageArray = [NSMutableArray array];
  [imageArray addObject:[[MCPPhotoEditInfo alloc] initWithSource:image]];
  editVC.imageArray = [imageArray copy];
  editVC.boardId = self.boardId;
  editVC.documentNo = self.documentNo;
  UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
  UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:editVC];
  navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
  navCtrl.navigationBarHidden = YES;
  [picker dismissViewControllerAnimated:NO completion:^{
    [self dismissViewControllerAnimated:NO completion:^{
      [rootViewController presentViewController:navCtrl animated:YES completion:nil];
    }];
  }];
}

@end
