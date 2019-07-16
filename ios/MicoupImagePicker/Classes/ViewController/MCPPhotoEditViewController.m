//
//  PhotoEditViewController.m
//  MissyCoupon
//
//  Created by coanyaa on 2017. 1. 13..
//  Copyright © 2017년 Joy2x. All rights reserved.
//

#import <NYXImagesKit/NYXImagesKit.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

#import "MCPPhotoEditViewController.h"
#import "MCPPhotoEditCollectionViewCell.h"
#import "MCPPhotoEditInfo.h"
#import "MCPUploadFileInfo.h"
#import "MCPImageInfo.h"
#import "MCPImageUploadResult.h"
#import "MCPRemoteImageInfo.h"
#import "Utility.h"
#import "HTTPAPICommunicator.h"
#import "BFCropInterface.h"

#import "UIImage+ExifMetaData.h"
#import "UIViewController+ToastMessage.h"

NSNotificationName const NotifyImageUploadSuccess = @"NotifyImageUploadSuccess";
NSNotificationName const NotifyImageUploadFail = @"NotifyImageUploadFail";

@interface MCPPhotoEditViewController (){
    __block BOOL isPrepareDone;
}
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) __block NSMutableArray *uploadFileArray;
@property (strong, nonatomic) __block NSMutableArray *uploadImageInfoArray;
@property (strong, nonatomic) __block NSMutableArray *resultArray;
@property (strong, nonatomic) MCPImageUploadResult *uploadResult;

@end

@implementation MCPPhotoEditViewController

- (void)updateCurrentPage
{
    NSInteger index = _collectionView.contentOffset.x / _collectionView.frame.size.width;
    self.naviTitleLabel.text = [NSString stringWithFormat:@"%ld / %ld", index+1, [_imageArray count]];
    self.currentIndex = index;
    
    MCPPhotoEditInfo *info = [_imageArray objectAtIndex:index];
    [self updateSizeButtonWithInfo:info];
}

- (void)updateSizeButtonWithInfo:(MCPPhotoEditInfo*)info
{
    if( info.imageMode == EditImageMode_Original ){
        [_currentSizeButton setTitle:@"▵ 원본" forState:UIControlStateNormal];
        [_currentSizeButton setTitle:@"▲ 원본" forState:UIControlStateSelected];
    }
    else if( info.imageMode == EditImageMode_W400 ){
        [_currentSizeButton setTitle:@"▵ 가로400" forState:UIControlStateNormal];
        [_currentSizeButton setTitle:@"▲ 가로400" forState:UIControlStateSelected];
    }
    else if( info.imageMode == EditImageMode_W800 ){
        [_currentSizeButton setTitle:@"▵ 가로800" forState:UIControlStateNormal];
        [_currentSizeButton setTitle:@"▲ 가로800" forState:UIControlStateSelected];
    }
}

- (void)changeCropMode
{
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if( [cell isKindOfClass:[MCPPhotoEditCollectionViewCell class]] ){
        MCPPhotoEditCollectionViewCell *editCell = (MCPPhotoEditCollectionViewCell*)cell;
        _collectionView.scrollEnabled = NO;
        [editCell showCropView];
        isCropMode = YES;
        
        [self closeSizeButtonAnimated:NO];
//        _bottomBaseView.hidden = YES;
        for(UIButton *button in _controlButtons )
            button.hidden = YES;
        _currentSizeButton.hidden = YES;
        _backButton.hidden = YES;
        _cancelButton.hidden = NO;
        self.naviTitleLabel.text = @"자르기";
    }
}

- (void)cancelCropMode
{
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if( [cell isKindOfClass:[MCPPhotoEditCollectionViewCell class]] ){
        MCPPhotoEditCollectionViewCell *editCell = (MCPPhotoEditCollectionViewCell*)cell;
        _collectionView.scrollEnabled = YES;
        [editCell hideCropView];
        isCropMode = NO;
        
//        _bottomBaseView.hidden = NO;
        for(UIButton *button in _controlButtons )
            button.hidden = NO;
        _currentSizeButton.hidden = NO;
        _backButton.hidden = NO;
        _cancelButton.hidden = YES;
        [self updateCurrentPage];
    }
}

- (void)cropImageWithInfo:(MCPPhotoEditInfo*)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool{
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
            if( [cell isKindOfClass:[MCPPhotoEditCollectionViewCell class]] ){
                MCPPhotoEditCollectionViewCell *editCell = (MCPPhotoEditCollectionViewCell*)cell;
                UIImage *cropedImage = [editCell.cropInterface getCroppedImage];
//                PhotoEditInfo *info = [_imageArray objectAtIndex:_currentIndex];
                info.editedImage = cropedImage;
                cropedImage = nil;
                info.isModified = YES;
                [info saveEditingImage];
                editCell.info = info;
            }
            [self cancelCropMode];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideProgress];
            });
        }
    });
    
}

- (void)prepareEditImages
{
    isPrepareDone = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        __block NSInteger countOfLoading = 0;
        if( [_imageArray count] > 0 ){
            for(MCPPhotoEditInfo *info in _imageArray ){
                [info createEditingImageFromOriginalImageWithCompletion:^(NSString *imagePath) {
                    countOfLoading++;
                    if( countOfLoading >= [_imageArray count] ){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            isPrepareDone = YES;
                            [self hideProgress];
                            [_collectionView reloadData];
                        });
                    }
                }];
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                isPrepareDone = YES;
                [self hideProgress];
                [_collectionView reloadData];
            });
        }
    });
}

- (void)setupView
{
    [super setupView];
    self.navigationController.navigationBarHidden = YES;
    [self updateCurrentPage];

    if( !self.beingPresented && self.movingToParentViewController ){
        
        [self showProgressWithMessage:@"편집 준비중입니다."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self prepareEditImages];
        });
    }
    else
        [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cancelButton.hidden = YES;
    [self closeSizeButtonAnimated:NO];
    
    if( _isModal )
        [_backButton setImage:[UIImage imageNamed:@"btn_close_x"] forState:UIControlStateNormal];
    else
        [_backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return ( isPrepareDone ? 1 : 0 );
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_imageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MCPPhotoEditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    MCPPhotoEditInfo *info = [_imageArray objectAtIndex:indexPath.row];
    cell.info = info;
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.appFrame.size.width, collectionView.frame.size.height);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    MCPPhotoEditInfo *info = [_imageArray objectAtIndex:indexPath.row];
    info.editedImage = nil;
//    if( [cell isKindOfClass:[PhotoEditCollectionViewCell class]] ){
//        PhotoEditCollectionViewCell *editCell = (PhotoEditCollectionViewCell*)cell;
//        editCell.imageView.image = nil;
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( !decelerate )
        [self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateCurrentPage];
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
- (void)closeSizeButtonAnimated:(BOOL)animated
{
    for(NSInteger i=0; i < [_sizeButtons count]; i++){
        UIButton *button = [_sizeButtons objectAtIndex:i];
        NSLayoutConstraint *layout = [_sizeButtonBottomLayouts objectAtIndex:i];
        layout.constant = -button.frame.size.height;
    }
    [UIView animateWithDuration:( animated ? 0.25 : 0.0 ) animations:^{
        [self.view layoutIfNeeded];
        for(UIButton *button in _sizeButtons)
            button.alpha = 0.0;
    } completion:^(BOOL finished) {
        for(UIButton *button in _sizeButtons)
            button.hidden = YES;
        _currentSizeButton.selected = NO;
    }];
}

- (void)openSizeButtonAnimated:(BOOL)animated
{
    for(NSInteger i=0; i < [_sizeButtons count]; i++){
        UIButton *button = [_sizeButtons objectAtIndex:i];
        NSLayoutConstraint *layout = [_sizeButtonBottomLayouts objectAtIndex:i];
        button.hidden = NO;
        button.alpha = 0.0;
        layout.constant = ( i > 0 ? 0.0 : 1.0 );
    }
    [UIView animateWithDuration:( animated ? 0.25 : 0.0 ) animations:^{
        [self.view layoutIfNeeded];
        for(UIButton *button in _sizeButtons)
            button.alpha = 1.0;
    } completion:^(BOOL finished) {
        _currentSizeButton.selected = YES;
    }];
}

- (IBAction)toggleOpenAction:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    if( button.selected ){
        [self openSizeButtonAnimated:YES];
    }
    else{
        [self closeSizeButtonAnimated:YES];
    }
}

- (IBAction)sizeSelectAction:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger type = button.tag - 10;
    
    MCPPhotoEditInfo *info = [_imageArray objectAtIndex:_currentIndex];
    info.imageMode = type;
    [self updateSizeButtonWithInfo:info];
    [self closeSizeButtonAnimated:YES];
    
    // 이미지 사이즈를 조정한다.
    switch( type ){
        case EditImageMode_Original:
            info.editedImage = [UIImage imageWithCGImage:info.originalImage.CGImage];
            break;
        case EditImageMode_W400:
        case EditImageMode_W800:{
            CGFloat maxWidth = 0.0;
            if( type == EditImageMode_W800 )
                maxWidth = 800.0;
            else
                maxWidth = 400.0;
            CGFloat resizeWidth = MIN(info.editedImage.size.width, maxWidth);
            CGFloat ratio = resizeWidth / info.editedImage.size.width;
            if( ratio != 1.0 ){
                CGSize imgSize = CGSizeMake( resizeWidth, info.editedImage.size.height * ratio );
                info.editedImage = [info.editedImage scaleToSize:imgSize];
            }
        }
            break;
    }
    [UIView animateWithDuration:0.0 animations:^{
        [_collectionView performBatchUpdates:^{
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentIndex inSection:0]]];
        } completion:nil];
    } completion:nil];
}

- (IBAction)rotateAction:(id)sender {
    // 이미지 90도씩 우측으로 회전
    __block MCPPhotoEditInfo *info = [_imageArray objectAtIndex:_currentIndex];
    
    NSString *filename = info.editingFilename;
    if( [[[filename pathExtension] lowercaseString] isEqualToString:@"gif"] ){
        [self showToastMessage:@"GIF 이미지는 편집이 불가능합니다"];
        return;
    }
    
    [self showProgressWithMessage:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self rotateImageWithInfo:info];
    });
}

- (void)rotateImageWithInfo:(MCPPhotoEditInfo*)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool{
            if( info.editedImage == nil ){
                info.editedImage = [UIImage imageWithContentsOfFile:[Utility filePathFromCachDirectory:info.editingFilename]];
            }

            UIImage *editImage = [info.editedImage rotateInDegrees:-90.0];
            info.editedImage = editImage;
            editImage = nil;
            info.isModified = YES;
            [info saveEditingImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                MCPPhotoEditCollectionViewCell *editCell = (MCPPhotoEditCollectionViewCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
                editCell.info = info;
                [editCell setNeedsDisplay];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hideProgress];
                });
            });
        }
    });
    
}


- (IBAction)cropAction:(id)sender {
    MCPPhotoEditInfo *info = [_imageArray objectAtIndex:_currentIndex];
    NSString *filename = info.editingFilename;
    if( [[[filename pathExtension] lowercaseString] isEqualToString:@"gif"] ){
        [self showToastMessage:@"GIF 이미지는 편집이 불가능합니다"];
        return;
    }
    [self changeCropMode];
}

- (IBAction)doneAction:(id)sender {
    if( isCropMode ){
        [self showProgressWithMessage:nil];
        __block MCPPhotoEditInfo *info = [_imageArray objectAtIndex:_currentIndex];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cropImageWithInfo:info];
        });
        
    }
    else{
        // 이미지 업로드 및 주소 결과 가져옴
        [self showProgressWithMessage:@"이미지를 처리중입니다."];
        dispatch_queue_t taskQueue = dispatch_queue_create("upload process", 0);
        dispatch_async(taskQueue, ^{
            // 1200 보다 큰 이미지 리사이즈 & 로컬파일 저장 (업로드 대비)
            self.uploadImageInfoArray = [NSMutableArray array];
            self.resultArray = [NSMutableArray array];
            
            for(MCPPhotoEditInfo *info in _imageArray ){
                @autoreleasepool {
                    UIImage *editImage = [UIImage imageWithContentsOfFile:[Utility filePathFromCachDirectory:info.editingFilename]];
                    UIImage *uploadTargetImage = editImage;
                    NSString *filename = info.editingFilename;
                    NSString *filePath = [Utility filePathFromCachDirectory:filename];
                    
                    if( editImage.size.width > 1200.0 && ![[[filename pathExtension] lowercaseString] isEqualToString:@"gif"] ){
                        CGFloat ratio = editImage.size.height / editImage.size.width;
                        UIImage *resizeImage = [editImage scaleToSize:CGSizeMake(1200.0, floorf(1200.0 * ratio))];
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
//                            imageData = UIImageJPEGRepresentation(uploadTargetImage, 0.7);
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
                }
            }
            self.uploadFileArray = [self.uploadImageInfoArray mutableCopy];
            self.uploadResult = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self processUpload];
            });
        });

    }
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
            
            if( [result.fileArray count] > 0 ){
                MCPRemoteImageInfo *imgInfo = [result.fileArray firstObject];
                if( !imgInfo.isSuccess){
                    isProcessNext = NO;
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"알림" message:[imgInfo.name stringByAppendingFormat:@"\n%@",@"업로드가 불가능한 이미지파일입니다."] cancelButtonTitle:@"확인" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                        
                        if( [_uploadImageInfoArray count] < 1 ){
                            [self removeTempUploadFiles:self.uploadFileArray];
                            [self hideProgress];
                            [self clearEditingImage];
                            [self closeAction:nil];
                        }
                        else{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self processUpload];
                            });
                        }
                        
                    }];
                }
                else {
                    if( [_uploadImageInfoArray count] < 1 ) {
                        NSDictionary *userInfo = @{@"result": self.uploadResult,
                                                   @"isLast": @( ([_uploadImageInfoArray count] < 1) )};
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyImageUploadSuccess object:self userInfo:userInfo];
                    }
                }
            }
        }
        else{
            NSDictionary *userInfo = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationName:NotifyImageUploadFail object:self userInfo:userInfo];
            
            [self.apiManager processError:error completion:^(NSHTTPURLResponse *response) {
                
            }];
        }
        if( isProcessNext ){
            if( [_uploadImageInfoArray count] < 1 ){
                [self removeTempUploadFiles:self.uploadFileArray ];
                [self hideProgress];
                [self clearEditingImage];
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

- (void)removeTempUploadFiles:(NSArray*)fileArray
{
    for(MCPUploadFileInfo *info in fileArray ){
        MCPImageInfo *imgInfo = info.fileData;
        if( [[NSFileManager defaultManager] fileExistsAtPath:imgInfo.sourcePath isDirectory:nil] )
            [[NSFileManager defaultManager] removeItemAtPath:imgInfo.sourcePath error:nil];
    }
}

- (IBAction)cancelCropAction:(id)sender {
    [self cancelCropMode];
}

- (void)backAction:(id)sender
{
    BOOL isModifyed = NO;
    
    for(MCPPhotoEditInfo *info in _imageArray ){
        if( info.isModified ){
            isModifyed = YES;
            break;
        }
    }
    
    if( isModifyed ){
        [UIAlertController showAlertInViewController:self withTitle:nil message:@"편집중인 사진이 있습니다.\n편집을 중단하시겠습니까?" cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@[@"확인"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            if( buttonIndex == controller.firstOtherButtonIndex ){
                [self clearEditingImage];
                [super closeAction:sender];
            }
        }];
    }
    else{
        [self clearEditingImage];
        [super closeAction:sender];
    }
}

- (void)clearEditingImage
{
    for(MCPPhotoEditInfo *info in _imageArray){
        NSString *path = [Utility filePathFromCachDirectory:info.editingFilename];
        if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
