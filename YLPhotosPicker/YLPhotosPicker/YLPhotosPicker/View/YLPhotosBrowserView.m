//
//  YLPhotosBrowserView.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotosBrowserView.h"
#import "YLPhotosPickerConfig.h"
#import "YLAssertPhoto.h"
#import "YLAssetManager.h"

@interface YLPhotosBrowserView ()<UIScrollViewDelegate>
@property (nonatomic,strong,readwrite) UIScrollView             *scrollview;
@property (nonatomic,strong,readwrite) UIImageView              *imageview;
@property (nonatomic,strong,readwrite) UIActivityIndicatorView  *indicator;
@property (nonatomic,assign          ) BOOL                      isLoading;
@end

@implementation YLPhotosBrowserView
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.scrollview];
        [self initGesture];
    }
    return self;
}

-(UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc]init];
        _scrollview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [_scrollview addSubview:self.imageview];
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        _scrollview.minimumZoomScale = 1.f;
        _scrollview.maximumZoomScale = 10.f;
    }
    return _scrollview;
}

-(UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        _imageview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
        _imageview.userInteractionEnabled = YES;
    }
    return _imageview;
}

-(UIActivityIndicatorView *)indicator
{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = self.imageview.center;
    }
    return _indicator;
}

-(void)initGesture
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self addGestureRecognizer:singleTap];
}

-(void)loadImage:(YLAssertPhoto *)photo
{
    if(!self.isLoading&&!self.imageview.image){
        [self.imageview addSubview:self.indicator];
        [self.indicator startAnimating];
        self.isLoading = YES;
        
        dispatch_async(dispatch_queue_create("youlan", NULL), ^{
            //先展示之前加载过的图片，再加载大图
            self.imageview.image = [[YLAssetManager manager]imageForPhoto:photo type:YLAssetRepresentationTypeAspectRatioThumbnail];
            UIImage *image = [[YLAssetManager manager]imageForPhoto:photo type:YLAssetRepresentationTypeFullScreenImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageview.image = image;
                
                [self.indicator stopAnimating];
                [self.indicator removeFromSuperview];
                self.isLoading = NO;
            });
        });
    }
}

#pragma mark---UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageview;
}

//需设置minimumZoomScale和maximumZoomScale才会调用如下方法
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    self.imageview.center = actualCenter;
}

#pragma mark---other methods
-(void)doubleTap:(UITapGestureRecognizer *)gesture
{
    //正在加载的时候禁止点击
    if(_isLoading){
        return;
    }
    
    CGPoint point = [gesture locationInView:self];
    if(self.scrollview.zoomScale <= 1.0){
        CGFloat scaleX = point.x + self.scrollview.contentOffset.x;
        CGFloat scaleY = point.y + self.scrollview.contentOffset.y;
        CGFloat scale = self.scrollview.zoomScale==1.0?1.2:10;
        [self.scrollview zoomToRect:CGRectMake(scaleX, scaleY, scale, scale) animated:YES];
    }else{
        [self.scrollview setZoomScale:1.0 animated:YES];
    }
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
    //正在加载的时候禁止点击
    if(_isLoading){
        return;
    }
    
    if(self.tapCallback){
        self.tapCallback(gesture);
    }
}

@end
