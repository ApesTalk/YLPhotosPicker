//
//  YLPhotosActionSheetController.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/22.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotosActionSheet.h"
#import "YLPhotosPickerConfig.h"
#import "YLSelectImagesView.h"
#import "YLAssetManager.h"
#import "YLPhotoGroupsViewController.h"
#import "YLPhotosPickerNavigationController.h"
#import "YLImagePickerController.h"

static NSTimeInterval const kAnimationDuration = 0.2f;
static NSUInteger const kActionButtonTag = 1000;
static CGFloat const kActionBtnHeight = 50.f;

@interface YLPhotosActionSheet ()<YLSelectImagesViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,weak  ) UIViewController    *superViewController; ///< 父视图
@property (nonatomic,strong) UIView              *bottomView;          ///< 底部视图
@property (nonatomic,strong) YLSelectImagesView  *selectImagesView;    ///< 图片选择视图
@property (nonatomic,strong) UIButton            *cancelBtn;           ///< 取消按钮 0
@property (nonatomic,strong) UIButton            *albumBtn;            ///< 相册按钮 1
@property (nonatomic,strong) UIButton            *cameraBtn;           ///< 相机按钮 2

@end


@implementation YLPhotosActionSheet

-(instancetype)init
{
    if(self = [super init]){
        self.maxShowCount = 1;
        self.maxSelectCount = 1;
        
        [self setSubViews];
    }
    return self;
}

- (instancetype)initWithMaxShowCount:(NSUInteger)showCount
                      maxSelectCount:(NSUInteger)selectCount
                            delegate:(id<YLPhotosActionSheetDelegate>)delegate
{
    if(self = [super init]){
        self.maxShowCount = MAX(showCount, 1);
        self.maxSelectCount = MAX(selectCount, 1);
        self.delegate = delegate;
        
        YLAssetManager *manager = [YLAssetManager manager];
        manager.maxSelectCount = self.maxSelectCount;
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.clipsToBounds = NO;
    self.alpha = 0.f;
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);

    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.cancelBtn];
    [self.bottomView addSubview:self.albumBtn];
    [self.bottomView addSubview:self.cameraBtn];
    [self.bottomView addSubview:self.selectImagesView];
}

-(UIView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        CGFloat kBottomViewHeight = kSelectImageHeight + kActionBtnHeight * 3 + 11;
        _bottomView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomViewHeight);
    }
    return _bottomView;
}

-(YLSelectImagesView *)selectImagesView
{
    if(!_selectImagesView){
        _selectImagesView = [[YLSelectImagesView alloc]initWithMaxShowCount:self.maxShowCount];
        _selectImagesView.frame = CGRectMake(0, 0, kScreenWidth, kSelectImageHeight);
        _selectImagesView.delegate = self;
    }
    return _selectImagesView;
}

-(UIButton *)cameraBtn
{
    if(!_cameraBtn){
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraBtn.backgroundColor = [UIColor whiteColor];
        [_cameraBtn addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cameraBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cameraBtn setTitleColor:kTitleColor forState:UIControlStateNormal];
        [_cameraBtn setTitle:@"拍照" forState:UIControlStateNormal];
        _cameraBtn.tag = kActionButtonTag + 2;
        _cameraBtn.frame = CGRectMake(0, kSelectImageHeight, kScreenWidth, kActionBtnHeight);
    }
    return _cameraBtn;
}

-(UIButton *)albumBtn
{
    if(!_albumBtn){
        _albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumBtn.backgroundColor = [UIColor whiteColor];
        [_albumBtn addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _albumBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_albumBtn setTitleColor:kTitleColor forState:UIControlStateNormal];
        [_albumBtn setTitle:@"从相册选取" forState:UIControlStateNormal];
        _albumBtn.tag = kActionButtonTag + 1;
        _albumBtn.frame = CGRectMake(0, kSelectImageHeight + kActionBtnHeight + 1, kScreenWidth, kActionBtnHeight);
    }
    return _albumBtn;
}

-(UIButton *)cancelBtn
{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        [_cancelBtn addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelBtn setTitleColor:kTitleColor forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.tag = kActionButtonTag;
        _cancelBtn.frame = CGRectMake(0, kSelectImageHeight + 2 * kActionBtnHeight + 1 + 10, kScreenWidth, kActionBtnHeight);
    }
    return _cancelBtn;
}


+ (instancetype)actionSheetWithMaxShowCount:(NSUInteger)showCount
                             maxSelectCount:(NSUInteger)selectCount
                                   delegate:(id<YLPhotosActionSheetDelegate>)delegate
{
    YLPhotosActionSheet *actionSheet = [[YLPhotosActionSheet alloc]initWithMaxShowCount:showCount
                                                                         maxSelectCount:selectCount
                                                                               delegate:delegate];
    return actionSheet;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *lastTouch = [touches anyObject];
    CGPoint point = [lastTouch locationInView:self];
    if(!CGRectContainsPoint(self.bottomView.frame, point)){
        [self dismiss];
        [[YLAssetManager manager]reset];
    }
}

#pragma mark---animation method
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    
    [self.selectImagesView reloadData];
    [self.cameraBtn setTitle:@"拍照" forState:UIControlStateNormal];
    
    CGRect frame = self.bottomView.frame;
    CGFloat kBottomViewHeight = kSelectImageHeight + kActionBtnHeight * 3 + 11;
    frame.origin.y = kScreenHeight - kBottomViewHeight;
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bottomView.frame = frame;
                         self.alpha = 1.f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    CGRect frame = self.bottomView.frame;
    frame.origin.y = kScreenHeight;
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bottomView.frame = frame;
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark---actionbtn method
- (void)actionButtonClick:(UIButton *)sender
{
    NSUInteger tag = sender.tag - kActionButtonTag;
    if(tag==0){
        //cancel
        [self dismiss];
        [[YLAssetManager manager]reset];
    }else if (tag==1){
        //album
        UIViewController *roootVc = [[[[UIApplication sharedApplication]delegate]window]rootViewController];
        _superViewController = roootVc;
        
        YLPhotoGroupsViewController *photoGroupsVc = [[YLPhotoGroupsViewController alloc]init];
        YLPhotosPickerNavigationController *nav = [[YLPhotosPickerNavigationController alloc]initWithRootViewController:photoGroupsVc];

        [_superViewController presentViewController:nav animated:YES completion:^{
            [self dismiss];
        }];
    }else{
        //camera
        YLAssetManager *manager = [YLAssetManager manager];
        if(manager.selectedPhotos.count > 0){
            //发送
            [[YLAssetManager manager]postSendImages:nil compress:YES];
            [self dismiss];
        }else{
            //拍照
            UIViewController *roootVc = [[[[UIApplication sharedApplication]delegate]window]rootViewController];
            _superViewController = roootVc;
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                YLImagePickerController *imagePicker = [[YLImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                [_superViewController presentViewController:imagePicker animated:YES completion:^{
                    [self dismiss];
                }];
            }
        }
    }
}

#pragma mark---YLSelectImagesViewDelegate
-(void)selectedImageChanged
{
    YLAssetManager *manager = [YLAssetManager manager];
    if(manager.selectedPhotos.count==0){
        [_cameraBtn setTitle:@"拍照" forState:UIControlStateNormal];
    }else{
        [_cameraBtn setTitle:[NSString stringWithFormat:@"发送(%li)",manager.selectedPhotos.count] forState:UIControlStateNormal];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orignalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
   //发送
    [[YLAssetManager manager]postSendImages:@[orignalImage] compress:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UINavigationControllerDelegate  以下两个方法可以统一状态条颜色，避免点击相册到选择照片页面的时候状态条文字颜色变黑不统一!!!

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
