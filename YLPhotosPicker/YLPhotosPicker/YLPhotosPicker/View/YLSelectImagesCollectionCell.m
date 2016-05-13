//
//  YLSelectImagesCollectionCell.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLSelectImagesCollectionCell.h"
#import "YLAssertPhoto.h"
#import "YLAssetManager.h"

static CGFloat const kSelectedBtnSize = 30.f;

@interface YLSelectImagesCollectionCell ()
@property(nonatomic,strong)UILabel *tipsLabel;
@end

@implementation YLSelectImagesCollectionCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    if(_tipsLabel){
        [_tipsLabel removeFromSuperview];
    }
    _imageView.center = self.contentView.center;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(frame.size.width-kSelectedBtnSize, 0, kSelectedBtnSize, kSelectedBtnSize);
        [_selectBtn setImage:[UIImage imageNamed:@"yl_photo_unselect"] forState:UIControlStateNormal];
        [_imageView addSubview:_selectBtn];
    }
    return self;
}

-(UILabel *)tipsLabel
{
    if(!_tipsLabel){
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.frame = CGRectMake((_imageView.frame.size.width - 60) * 0.5, 5, 60, 20);
        _tipsLabel.backgroundColor = [UIColor grayColor];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:10];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = @"松手发图";
        _tipsLabel.layer.cornerRadius = 10.f;
        _tipsLabel.layer.masksToBounds = YES;
    }
    return _tipsLabel;
}

-(void)refreshWithPhoto:(YLAssertPhoto *)photo
{
    _imageView.image = [[YLAssetManager manager]imageForPhoto:photo type:YLAssetRepresentationTypeAspectRatioThumbnail];
    UIImage *image = photo.isSelected?[UIImage imageNamed:@"yl_photo_selected"]:[UIImage imageNamed:@"yl_photo_unselect"];
    [_selectBtn setImage:image forState:UIControlStateNormal];
}

-(void)showTips:(BOOL)show
{
    self.selectBtn.hidden = show;
    
    if(show){
        [_imageView addSubview:self.tipsLabel];
    }else{
        if(_tipsLabel){
            [_tipsLabel removeFromSuperview];
        }
    }
}

@end
