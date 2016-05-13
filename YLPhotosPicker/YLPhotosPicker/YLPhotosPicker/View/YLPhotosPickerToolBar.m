//
//  YLPhotosPickerToolBar.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotosPickerToolBar.h"
#import "YLPhotosPickerConfig.h"
#import "YLAssetManager.h"
#import "YLAssertPhoto.h"

@interface YLPhotosPickerToolBar ()
@property (nonatomic,strong,readwrite) UIButton  *previewBtn;      ///< 预览
@property (nonatomic,strong,readwrite) UIButton  *orignalImageBtn; ///< 原图
@property (nonatomic,strong,readwrite) UIButton  *sendBtn;         ///< 发送
@property (nonatomic,strong          ) UILabel   *numLabel;        ///< 数量
@end

@implementation YLPhotosPickerToolBar
-(instancetype)initWithToolBarType:(YLPhotosPickerToolBarType)barType
{
    if(self = [super init]){
        [self customWithBarType:barType];
    }
    return self;
}

- (void)customWithBarType:(YLPhotosPickerToolBarType)barType
{
    if(barType==YLPhotosPickerToolBarTypePreview){
        self.barStyle = UIBarStyleDefault;
        
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:kTitleColor forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[kTitleColor colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _previewBtn.frame = CGRectMake(15, 0, 44, 44);//toolbar 系统默认44
        _previewBtn.enabled = NO;
        [self addSubview:_previewBtn];
    }else{
        self.barStyle = UIBarStyleBlack;
        
        _orignalImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _orignalImageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_orignalImageBtn setImage:[UIImage imageNamed:@"yl_photo_unselect"] forState:UIControlStateNormal];
        [_orignalImageBtn setImage:[UIImage imageNamed:@"yl_photo_selected"] forState:UIControlStateSelected];
        [_orignalImageBtn setTitle:@"原图" forState:UIControlStateNormal];
        _orignalImageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_orignalImageBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        [_orignalImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _orignalImageBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _orignalImageBtn.frame = CGRectMake(15, 0, 150, 44);
        [self addSubview:_orignalImageBtn];
    }
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:kHightlightColor forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[kHightlightColor colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _sendBtn.frame = CGRectMake(kScreenWidth-70, 0, 60, 44);
    _sendBtn.enabled = NO;
    [self addSubview:_sendBtn];
    
    _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, (44 - 20) * 0.5, 20, 20)];
    _numLabel.layer.cornerRadius = 10.f;
    _numLabel.layer.masksToBounds = YES;
    _numLabel.backgroundColor = kHightlightColor;
    _numLabel.font = [UIFont systemFontOfSize:10];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.textColor = [UIColor whiteColor];
    _numLabel.hidden = YES;
    [_sendBtn addSubview:_numLabel];
}

- (void)reload
{
    YLAssetManager *manager = [YLAssetManager manager];
    BOOL enable = manager.selectedPhotos.count > 0;
    _previewBtn.enabled = enable;
    _sendBtn.enabled = enable;
    _numLabel.hidden = !enable;
    BOOL animate = enable&&[_numLabel.text integerValue]!=manager.selectedPhotos.count;
    _numLabel.text = [NSString stringWithFormat:@"%li",manager.selectedPhotos.count];
    if(animate){
        _numLabel.transform = CGAffineTransformMakeScale(0, 0);
        //damp决定振动程度 velocity决定速度
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _numLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)reloadImageDataWithPhoto:(YLAssertPhoto *)photo
{
    _orignalImageBtn.selected = YES;
    NSString *title = nil;
    long long size = [photo size] / 1024;
    if(size > 1024){
        size = size/1024;
        title = [NSString stringWithFormat:@"原图(%lliM)",size];
    }else{
        title = [NSString stringWithFormat:@"原图(%lliK)",size];
    }
    [_orignalImageBtn setTitle:title forState:UIControlStateNormal];
}

@end
