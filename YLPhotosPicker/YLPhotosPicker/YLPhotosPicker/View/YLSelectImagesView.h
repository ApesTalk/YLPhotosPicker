//
//  YLSelectImagesView.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kSelectImageHeight;

@protocol YLSelectImagesViewDelegate <NSObject>

-(void)selectedImageChanged;

@end

@interface YLSelectImagesView : UIView
@property(nonatomic,assign)NSUInteger maxShowCount;///< 最多展示多少图片
@property(nonatomic,assign)id<YLSelectImagesViewDelegate>delegate;

-(instancetype)initWithMaxShowCount:(NSUInteger)count;

- (void)reloadData;

@end
