//
//  YLPhotosBrowserViewController.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLPhotosBrowserDelegate <NSObject>

-(void)selectedPhotosChanged;

@end

@interface YLPhotosBrowserViewController : UIViewController
@property(nonatomic,assign)NSInteger currentIndex;///< 当前展示的索引，默认为0
@property(nonatomic,assign)id<YLPhotosBrowserDelegate>delegate;

-(instancetype)initWithPhotos:(NSArray *)array;

@end
//图片预览