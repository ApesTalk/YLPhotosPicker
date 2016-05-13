//
//  YLPhotosBrowserView.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLAssertPhoto;

typedef void(^YLPhotosBrowserSingleTapBlock)(UITapGestureRecognizer *tapGesture);

@interface YLPhotosBrowserView : UIView
@property (nonatomic,strong,readonly) UIScrollView  *scrollview;
@property (nonatomic,strong,readonly) UIImageView   *imageview;

@property(nonatomic,copy)YLPhotosBrowserSingleTapBlock tapCallback;

-(void)loadImage:(YLAssertPhoto *)photo;

@end
//预览视图