//
//  YLPhotosActionSheetController.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/22.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YLPhotosActionSheetDelegate;

@interface YLPhotosActionSheet : UIView
@property(nonatomic,assign)id<YLPhotosActionSheetDelegate>delegate;
@property(nonatomic,assign)NSUInteger maxShowCount;
@property(nonatomic,assign)NSUInteger maxSelectCount;

- (instancetype)initWithMaxShowCount:(NSUInteger)showCount
                      maxSelectCount:(NSUInteger)selectCount
                            delegate:(id<YLPhotosActionSheetDelegate>)delegate;

+ (instancetype)actionSheetWithMaxShowCount:(NSUInteger)showCount
                             maxSelectCount:(NSUInteger)selectCount
                                   delegate:(id<YLPhotosActionSheetDelegate>)delegate;

- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

//弹出选择图片视图，预览+从相册选择+相机+取消


@protocol YLPhotosActionSheetDelegate <NSObject>

- (void)photosActionSheet:(YLPhotosActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end