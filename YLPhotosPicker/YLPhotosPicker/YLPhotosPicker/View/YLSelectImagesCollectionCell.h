//
//  YLSelectImagesCollectionCell.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLAssertPhoto;

@interface YLSelectImagesCollectionCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView  *imageView; ///< 展示图片
@property (nonatomic,strong) UIButton     *selectBtn; ///< 选中按钮

-(void)refreshWithPhoto:(YLAssertPhoto *)photo;

-(void)showTips:(BOOL)show;

@end
