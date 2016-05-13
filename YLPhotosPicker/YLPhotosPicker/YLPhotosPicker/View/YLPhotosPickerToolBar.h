//
//  YLPhotosPickerToolBar.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/26.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLAssertPhoto;

typedef NS_ENUM(NSUInteger,YLPhotosPickerToolBarType){
    YLPhotosPickerToolBarTypePreview,///< 预览
    YLPhotosPickerToolBarTypeBrowser,///< 浏览
};

@interface YLPhotosPickerToolBar : UIToolbar
@property (nonatomic,strong,readonly) UIButton  *previewBtn;      ///< 预览
@property (nonatomic,strong,readonly) UIButton  *orignalImageBtn; ///< 原图
@property (nonatomic,strong,readonly) UIButton  *sendBtn;         ///< 发送

-(instancetype)initWithToolBarType:(YLPhotosPickerToolBarType)barType;

/**状态刷新*/
-(void)reload;

/**只有选择了原图才调用这个方法*/
- (void)reloadImageDataWithPhoto:(YLAssertPhoto *)photo;

@end
