    //
//  MCPPhotoSelectViewController.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <NYXImagesKit/NYXImagesKit.h>
#import <UIColor+Hex/UIColor+Hex.h>
#import <UIButton+BackgroundColor/UIButton+BackgroundColor.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

#import "MCPPhotoSelectViewController.h"
#import "PhotoCollectionViewCell.h"
#import "MCPPhotoEditViewController.h"
#import "MCPPhotoEditInfo.h"
#import "MCPUploadFileInfo.h"
#import "MCPImageInfo.h"
#import "MCPImageUploadResult.h"
#import "MCPRemoteImageInfo.h"
#import "Utility.h"
#import "HTTPAPICommunicator.h"

#import "UIImage+FixOrientation.h"
#import "UIImage+ExifMetaData.h"
#import "UIViewController+ToastMessage.h"


@interface MCPPhotoSelectViewController ()
@property (strong, nonatomic) __block NSMutableArray *selectedAssetArray;
@property (strong, nonatomic) __block NSMutableArray *itemArray;
@property (strong, nonatomic) __block NSMutableArray *uploadFileArray;
@property (strong, nonatomic) __block NSMutableArray *uploadImageInfoArray;
@property (strong, nonatomic) __block NSMutableArray *resultArray;
@property (strong, nonatomic) MCPImageUploadResult *uploadResult;
@end

@implementation MCPPhotoSelectViewController

- (void)generateItemsInGroups:(NSArray*)array
{
    dispatch_queue_t generateQueue = dispatch_queue_create("generate queue", 0);
    [self showProgressWithMessage:@"목록을 조회중입니다."];
    dispatch_async(generateQueue, ^{
        self.itemArray = [NSMutableArray array];
        for(ALAssetsGroup *group in array){
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if( result )
                    [_itemArray addObject:result];
            }];
        }
        [_itemArray sortUsingComparator:^NSComparisonResult(ALAsset *obj1, ALAsset *obj2) {
            NSDate *date1 = [obj1 valueForProperty:ALAssetPropertyDate];
            NSDate *date2 = [obj2 valueForProperty:ALAssetPropertyDate];
            
            return [date2 compare:date1];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            [_collectionView reloadData];
        });
    });
}

- (void)setupView
{
    [super setupView];
    
    if( [_selectedAssetArray count] < 1 ){
        self.selectedAssetArray = [NSMutableArray array];
    }
    [self updateSelectedCount];
    
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat cellWidth = floorf((self.appFrame.size.width - 2.0) / 3.0);
    cellSize = CGSizeMake( cellWidth, cellWidth);
    
    [self makeRoundedOutlineView:_addButton outlineColor:[UIColor whiteColor]];
    [_addButton setBackgroundColor:[UIColor colorWithHex:0xdbdbdb] forState:UIControlStateHighlighted];
    
    [self makeRoundedOutlineView:_editButton outlineColor:[UIColor whiteColor]];
    [_editButton setBackgroundColor:[UIColor colorWithHex:0xdbdbdb] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if( [_groupArray count] > 1 && [_itemArray count] < 1 ){
        [self generateItemsInGroups:_groupArray];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if( [_groupArray count] > 1 )
        count = [_itemArray count];
    else{
        ALAssetsGroup *group = [_groupArray objectAtIndex:section];
        count = [group numberOfAssets];
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    
    cell.gifMarkView.hidden = YES;
    if( [_groupArray count] > 1 ){
        ALAsset *result = [_itemArray objectAtIndex:indexPath.row];
        NSLog(@"%s %@/%@",__FUNCTION__, result.defaultRepresentation.filename, result.defaultRepresentation.UTI);
        if( [[[result.defaultRepresentation.filename pathExtension] lowercaseString] isEqualToString:@"gif"] )
            cell.gifMarkView.hidden = NO;
        
        cell.imageView.image = [UIImage imageWithCGImage:result.thumbnail];
        NSInteger index = [_selectedAssetArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *targetIndexPath = (NSIndexPath*)obj;
            if( [indexPath isEqual:targetIndexPath] )
                return YES;
            return NO;
        }];
        
        if( index != NSNotFound ){
            cell.numberLabel.text = [NSString stringWithFormat:@"%ld",index+1];
            cell.numberLabel.hidden = NO;
        }
        else{
            cell.numberLabel.text = nil;
            cell.numberLabel.hidden = YES;
        }
    }
    else{
        ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - indexPath.row - 1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if( result ){
                NSLog(@"%s %@/%@",__FUNCTION__, result.defaultRepresentation.filename, result.defaultRepresentation.UTI);
                if( [[[result.defaultRepresentation.filename pathExtension] lowercaseString] isEqualToString:@"gif"] )
                    cell.gifMarkView.hidden = NO;
                cell.imageView.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                NSInteger index = [_selectedAssetArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSIndexPath *targetIndexPath = (NSIndexPath*)obj;
                    if( [indexPath isEqual:targetIndexPath] )
                        return YES;
                    return NO;
                }];
                
                if( index != NSNotFound ){
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",index+1];
                    cell.numberLabel.hidden = NO;
                }
                else{
                    cell.numberLabel.text = nil;
                    cell.numberLabel.hidden = YES;
                }
                
            }
        }];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return cellSize;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if( [_selectedAssetArray count] >= self.maxCount ){
//        [self showToastMessage:[NSString stringWithFormat:@"최대 %ld장까지 입력 가능합니다.",self.maxCount]];
//        return;
//    }
    if( [_groupArray count] > 1 ){
        NSInteger index = [_selectedAssetArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *targetIndexPath = (NSIndexPath*)obj;
            if( [indexPath isEqual:targetIndexPath] )
                return YES;
            return NO;
        }];
        
        if( index != NSNotFound ){
            [_selectedAssetArray removeObjectAtIndex:index];
            [_collectionView reloadData];
        }
        else{
            if( [_selectedAssetArray count] >= self.maxCount ){
                [self showToastMessage:[NSString stringWithFormat:@"최대 %ld장까지 입력 가능합니다.",self.maxCount]];
            }
            else
                [_selectedAssetArray addObject:indexPath];
            [UIView animateWithDuration:0.0 animations:^{
                [_collectionView performBatchUpdates:^{
                    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:nil];
            } completion:nil];
        }
        
        [self updateSelectedCount];
    }
    else{
        ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - indexPath.row - 1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if( result ){
                NSInteger index = [_selectedAssetArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSIndexPath *targetIndexPath = (NSIndexPath*)obj;
                    if( [indexPath isEqual:targetIndexPath] )
                        return YES;
                    return NO;
                }];
                
                if( index != NSNotFound ){
                    [_selectedAssetArray removeObjectAtIndex:index];
                    [_collectionView reloadData];
                }
                else{
                    if( [_selectedAssetArray count] >= self.maxCount ){
                        [self showToastMessage:[NSString stringWithFormat:@"최대 %ld장까지 입력 가능합니다.",self.maxCount]];
                    }
                    else
                        [_selectedAssetArray addObject:indexPath];
                    [UIView animateWithDuration:0.0 animations:^{
                        [_collectionView performBatchUpdates:^{
                            [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        } completion:nil];
                    } completion:nil];
                }
                
                [self updateSelectedCount];
                *stop = YES;
            }
        }];
    }
}

- (void)updateSelectedCount
{
    _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",[_selectedAssetArray count], self.maxCount];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - action method

- (void)removeTempUploadFiles:(NSArray*)fileArray
{
    for(MCPUploadFileInfo *info in fileArray ){
        MCPImageInfo *imgInfo = info.fileData;
        if( [[NSFileManager defaultManager] fileExistsAtPath:imgInfo.sourcePath isDirectory:nil] )
            [[NSFileManager defaultManager] removeItemAtPath:imgInfo.sourcePath error:nil];
    }
}

- (IBAction)addAction:(id)sender {
    if( [_selectedAssetArray count] < 1 ){
        [self showToastMessage:@"사진을 선택해 주세요."];
        return;
    }
    
    [self showProgressWithMessage:@"이미지를 처리중입니다."];
    NSMutableArray *imageArray = [NSMutableArray array];
    for(NSIndexPath *indexPath in _selectedAssetArray){
        ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - indexPath.row - 1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if( result ){
                [imageArray addObject:[[MCPPhotoEditInfo alloc] initWithSource:result]];
            }
        }];
    }
    
    dispatch_queue_t taskQueue = dispatch_queue_create("upload process", 0);
    dispatch_async(taskQueue, ^{
        // 1200 보다 큰 이미지 리사이즈 & 로컬파일 저장 (업로드 대비)
        self.uploadImageInfoArray = [NSMutableArray array];
        self.resultArray = [NSMutableArray array];
        
        for(MCPPhotoEditInfo *info in imageArray ){
            @autoreleasepool {
                [info loadOriginalImageWithCompletion:^(UIImage *image) {
                    
                    UIImage *uploadTargetImage = info.editedImage;
                    NSString *filename = info.originalFilename;
                    NSString *filePath = [Utility filePathFromCachDirectory:filename];
                    
                    if( info.editedImage.size.width > 1200.0 && ![[[filename pathExtension] lowercaseString] isEqualToString:@"gif"] ){
                        CGFloat ratio = info.editedImage.size.height / info.editedImage.size.width;
                        UIImage *resizeImage = [info.editedImage scaleToSize:CGSizeMake(1200.0, floorf(1200.0 * ratio))];
                        uploadTargetImage = resizeImage;
                    }
                    
                    if( uploadTargetImage ){
                        NSString *mimeType = @"image/";
                        NSData *imageData = nil;
                        if( [[[filename pathExtension] lowercaseString] isEqualToString:@"gif"] ){
                            mimeType = [mimeType stringByAppendingString:[filename pathExtension]];
                            imageData = [info imageData];
                        }
                        else{
                            mimeType = [mimeType stringByAppendingString:@"jpg"];
//                            imageData = UIImageJPEGRepresentation( uploadTargetImage, 0.7);
                            imageData = [uploadTargetImage jpegDataByRemovingExif];
                            filePath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
                        }
                        
                        if( [imageData writeToFile:filePath atomically:YES] ){
                            MCPImageInfo *imgInfo = [[MCPImageInfo alloc] init];
                            imgInfo.sourcePath = filePath;
                            MCPUploadFileInfo *upInfo = [[MCPUploadFileInfo alloc] initWithFileData:imgInfo key:@"files[]" filename:[filePath lastPathComponent] mimeType:mimeType];
                            [_uploadImageInfoArray addObject:upInfo];
                        }
                    }
                    info.originalImage = nil;
                    info.editedImage = nil;
                }];
            }
        }
        self.uploadFileArray = [self.uploadImageInfoArray mutableCopy];
        for(NSInteger i=0; i < [_uploadFileArray count]; i++){
            MCPUploadFileInfo *upInfo = [_uploadFileArray objectAtIndex:i];
            NSLog(@"%s %02ld. uploadfilename : %@",__FUNCTION__, i+1 ,upInfo.fileName);
        }
        self.uploadResult = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processUpload];
        });
        
    });

}

- (void)processUpload
{
    if( [_uploadImageInfoArray count] < 1 ){
        [self hideProgress];
        return;
    }
    [self updateProgressMessage:[NSString stringWithFormat:@"%ld / %ld 장 업로드 중",[_uploadFileArray count] - ([_uploadImageInfoArray count]-1),[_uploadFileArray count] ]];
    MCPUploadFileInfo *uploadInfo = [_uploadImageInfoArray firstObject];
    self.apiManager.isShowProgress = NO;
    [self.apiManager uploadImageToBoard:self.boardId documentNo:self.documentNo files:@[uploadInfo] completionHandler:^(MCPResultInfo *response, NSError *error) {
        [_uploadImageInfoArray removeObjectAtIndex:0];
        BOOL isProcessNext = YES;
        if( error == nil ){
            MCPImageUploadResult *result = [[MCPImageUploadResult alloc] initWithData:response.resultData];
            if( self.uploadResult == nil )
                self.uploadResult = result;
            else
                [self.uploadResult.fileArray addObjectsFromArray:result.fileArray];
            NSLog(@"%s %@",__FUNCTION__, result.fileArray);
            if( [result.fileArray count] > 0 ){
                MCPRemoteImageInfo *imgInfo = [result.fileArray firstObject];
                if( !imgInfo.isSuccess){
                    isProcessNext = NO;
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"알림" message:[imgInfo.name stringByAppendingFormat:@"\n%@",@"업로드가 불가능한 이미지파일입니다."] cancelButtonTitle:@"확인" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                        
                        if( [_uploadImageInfoArray count] < 1 ){
                            [self removeTempUploadFiles:self.uploadFileArray];
                            [self hideProgress];
                            
                            [self closeAction:nil];
                        }
                        else{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self processUpload];
                            });
                        }
                        
                    }];
                }
                else{
                    if( [_uploadImageInfoArray count] < 1 ) {
                        NSDictionary *userInfo = @{@"result": self.uploadResult,
                                                   @"isLast": @( ([_uploadImageInfoArray count] < 1) )};
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyImageUploadSuccess object:self userInfo:userInfo];
                    }
                }
            }
            else if (result.isSuccess == NO) {
                NSDictionary *userInfo = @{@"response": response};
                [[NSNotificationCenter defaultCenter] postNotificationName:NotifyImageUploadFail object:self userInfo:userInfo];
            }
        }
        else{
//             NSDictionary *userInfo = @{@"error": error};
//             [[NSNotificationCenter defaultCenter] postNotificationName:NotifyImageUploadFail object:self userInfo:userInfo];
            
            [self.apiManager processError:error completion:^(NSHTTPURLResponse *response) {

            }];
        }
        if( isProcessNext ){
            if( [_uploadImageInfoArray count] < 1 ){
                [self removeTempUploadFiles:self.uploadFileArray];
                [self hideProgress];
                
                [self closeAction:nil];
            }
            else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self processUpload];
                });
            }
        }
    }];
}

- (IBAction)editAction:(id)sender {
    if( [_selectedAssetArray count] < 1 ){
        [self showToastMessage:@"사진을 선택해 주세요."];
        return;
    }
    NSMutableArray *imageArray = [NSMutableArray array];
    for(NSIndexPath *indexPath in _selectedAssetArray){
        if( [_groupArray count] > 1 ){
            
        }
        else{
            ALAssetsGroup *group = [_groupArray objectAtIndex:indexPath.section];
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - indexPath.row - 1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if( result ){
                    [imageArray addObject:[[MCPPhotoEditInfo alloc] initWithSource:result]];
                }
            }];
        }
    }
    
    MCPPhotoEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoEditViewController"];
    editVC.imageArray = [imageArray copy];
    editVC.boardId = self.boardId;
    editVC.documentNo = self.documentNo;
    [self.navigationController pushViewController:editVC animated:YES];
}

@end
