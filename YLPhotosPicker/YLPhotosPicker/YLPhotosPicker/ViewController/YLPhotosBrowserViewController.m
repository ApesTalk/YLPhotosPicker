//
//  YLPhotosBrowserViewController.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotosBrowserViewController.h"
#import "YLPhotosPickerConfig.h"
#import "YLPhotosPickerToolBar.h"
#import "YLAssertPhoto.h"
#import "YLAssetManager.h"
#import "YLPhotosBrowserView.h"

static NSInteger const kSubBrowserImageTag = 1000;

@interface YLPhotosBrowserViewController ()<UIScrollViewDelegate>
{
    NSInteger              lastIndex;
    NSArray                *photos;
    UILabel                *titleLabel;
    UIButton               *selectBtn;
    UIScrollView           *photosScrollView;
    YLPhotosPickerToolBar  *toolBar;
    BOOL                    isSendOrignalImage;
}
@end

@implementation YLPhotosBrowserViewController
-(instancetype)initWithPhotos:(NSArray *)array
{
    if(self = [super init]){
        photos = [array copy];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavigationItem];
    [self initScrollView];
    [self initToolbar];
    
    [self loadImageViews];
    //预加载6张
    NSInteger minIndex = MAX(_currentIndex - 3, 0);//至少为0
    NSInteger maxIndex = MIN(_currentIndex + 3, photos.count);//最大为photos.count
    for(NSInteger i = minIndex;i < maxIndex;i++){
        [self loadImageAtIndex:i];
    }
    [photosScrollView scrollRectToVisible:CGRectMake(_currentIndex * kScreenWidth, 0, kScreenWidth, kScreenHeight) animated:NO];
    
    [self updateBar];
}

-(void)initNavigationItem
{
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0, 0, 44, 44);
    [selectBtn setImage:[UIImage imageNamed:@"yl_photo_unselect"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *selectItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = selectItem;
}

-(void)initScrollView
{
    photosScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    photosScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photosScrollView.pagingEnabled = YES;
    photosScrollView.showsHorizontalScrollIndicator = NO;
    photosScrollView.showsVerticalScrollIndicator = NO;
    photosScrollView.delegate = self;
    
    photosScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * photos.count, self.view.bounds.size.height);
    [self.view addSubview:photosScrollView];
}

-(void)initToolbar
{
    toolBar = [[YLPhotosPickerToolBar alloc]initWithToolBarType:YLPhotosPickerToolBarTypeBrowser];
    toolBar.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
    [toolBar.orignalImageBtn addTarget:self action:@selector(orignalImage) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.sendBtn addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toolBar];
}

- (void)hideBar
{
    CGRect frame = toolBar.frame;
    if (self.navigationController.navigationBarHidden) {
        frame.origin.y = kScreenHeight - 44;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        frame.origin.y = kScreenHeight;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [UIView animateWithDuration:.25f animations:^{
        toolBar.frame = frame;
    }];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)loadImageViews
{
    for(NSInteger i = 0;i < photos.count;i++){
        YLPhotosBrowserView *browserView = [[YLPhotosBrowserView alloc]initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight)];
        browserView.tag = kSubBrowserImageTag + i;
        browserView.tapCallback = ^(UITapGestureRecognizer *gesture){
            [self hideBar];
        };
        [photosScrollView addSubview:browserView];
    }
}

-(void)loadImageAtIndex:(NSInteger)index
{
    YLPhotosBrowserView *browserView = (YLPhotosBrowserView *)[photosScrollView viewWithTag:kSubBrowserImageTag + index];
    YLAssertPhoto *photo = photos[index];
    [browserView loadImage:photo];
}

-(void)updateBar
{
    titleLabel.text = [NSString stringWithFormat:@"%li/%li",_currentIndex + 1,photos.count];
    YLAssertPhoto *photo = photos[_currentIndex];
    UIImage *image = photo.isSelected?[UIImage imageNamed:@"yl_photo_selected"]:[UIImage imageNamed:@"yl_photo_unselect"];
    [selectBtn setImage:image forState:UIControlStateNormal];
    
    [toolBar reload];
    if(isSendOrignalImage){
        [toolBar reloadImageDataWithPhoto:photo];
    }
}

#pragma mark---UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    lastIndex = _currentIndex;
    
    NSInteger left = MAX(_currentIndex - 2, 0);
    NSInteger right = MIN(_currentIndex + 2, photos.count);
    
    //预加载三张图片
    for (NSInteger i = left; i < right; i++) {
        [self loadImageAtIndex:i];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x  / scrollView.bounds.size.width;
    if(lastIndex!=_currentIndex){
        YLPhotosBrowserView *browserView = (YLPhotosBrowserView *)[photosScrollView viewWithTag:kSubBrowserImageTag + lastIndex];
        browserView.scrollview.zoomScale = 1.0;
    }
    [self updateBar];
    if(isSendOrignalImage){
        YLAssertPhoto *photo = photos[_currentIndex];
        [toolBar reloadImageDataWithPhoto:photo];
    }
}

#pragma mark---other methods
-(void)orignalImage
{
    if(isSendOrignalImage){
        toolBar.orignalImageBtn.selected = NO;
        [toolBar.orignalImageBtn setTitle:@"原图" forState:UIControlStateNormal];
    }else{
        toolBar.orignalImageBtn.selected = YES;
        NSString *title = nil;
        YLAssertPhoto *photo = photos[_currentIndex];
        long long size = [photo size] / 1024;
        if(size > 1024){
            size = size/1024;
            title = [NSString stringWithFormat:@"原图(%lliM)",size];
        }else{
            title = [NSString stringWithFormat:@"原图(%lliK)",size];
        }
        [toolBar.orignalImageBtn setTitle:title forState:UIControlStateNormal];
    }
    isSendOrignalImage = !isSendOrignalImage;
}

-(void)sendImage
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[YLAssetManager manager]postSendImages:nil compress:!isSendOrignalImage];
    }];
}

-(void)selectImage:(UIButton *)sender
{
    YLAssertPhoto *currentPhoto = photos[_currentIndex];
    YLAssetManager *manager = [YLAssetManager manager];
    currentPhoto.isSelected = [manager selectPhoto:currentPhoto];
    UIImage *image = currentPhoto.isSelected?[UIImage imageNamed:@"yl_photo_selected"]:[UIImage imageNamed:@"yl_photo_unselect"];
    [sender setImage:image forState:UIControlStateNormal];
    if(currentPhoto.isSelected){
        sender.transform = CGAffineTransformMakeScale(0, 0);
        //damp决定振动程度 velocity决定速度
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sender.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if([_delegate respondsToSelector:@selector(selectedPhotosChanged)]){
        [_delegate selectedPhotosChanged];
    }
    
    [toolBar reload];
}

@end
