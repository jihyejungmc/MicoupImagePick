//
//  MCPPhotoGroupViewController.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "MCPPhotoGroupViewController.h"
#import "AlbumGroupListTableViewCell.h"
#import "MCPPhotoSelectViewController.h"

@interface MCPPhotoGroupViewController ()
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (assign, nonatomic) NSInteger totalItemCount;
@property (strong, nonatomic) UIImage *fullThumnail;

@end

@implementation MCPPhotoGroupViewController

    
- (void)loadAssetGroups
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupArray = [NSMutableArray array];
    [_assetsLibrary enumerateGroupsWithTypes:/*ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupPhotoStream | ALAssetsGroupSavedPhotos |*/ ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if( !(*stop) && group ){
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if( group.numberOfAssets > 0){
                [_groupArray addObject:group];
                self.totalItemCount += group.numberOfAssets;
            }
        }
        else{
            ALAssetsGroup *targetGroup = nil;
            for(ALAssetsGroup *grp in _groupArray){
                if( [[grp valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos ){
                    targetGroup = grp;
                    break;
                }
            }
            if( targetGroup ){
                [_groupArray removeObject:targetGroup];
                [_groupArray insertObject:targetGroup atIndex:0];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    } failureBlock:nil];
}


- (void)setupView
{
    [super setupView];
    [loadingView setHidden:NO];
    if( [_groupArray count] < 1 ){
        [self loadAssetGroups];
    }
    else
        [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(100, 400, 80, 80)];
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView.layer.cornerRadius = 5;
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Loading...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:lblLoading];
    [self.view addSubview:loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumGroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.row];
    
    cell.groupInfo = group;
    
    if( [group numberOfAssets] > 0 ){
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if( !(*stop) && result ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithCGImage:result.thumbnail];
                    cell.thumbnailImageView.backgroundColor = [UIColor clearColor];
                    cell.thumbnailImageView.image = image;
                    if( indexPath.section == 1 && self.fullThumnail == nil ){
                        self.fullThumnail = image;
                        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
                *stop = YES;
            }
        }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    
    MCPPhotoSelectViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoSelectViewController"];
    nextVC.boardId = self.boardId;
    nextVC.documentNo = self.documentNo;
    nextVC.maxCount = self.maxCount;
    ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.row];
    nextVC.title = [group valueForProperty:ALAssetsGroupPropertyName];
    nextVC.groupArray = [NSMutableArray arrayWithObject:group];
    [self.navigationController pushViewController:nextVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
