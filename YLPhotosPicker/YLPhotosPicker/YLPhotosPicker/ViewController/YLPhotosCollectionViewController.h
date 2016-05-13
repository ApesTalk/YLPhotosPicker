//
//  YLPhotosCollectionViewController.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAssetsGroup;

@interface YLPhotosCollectionViewController : UIViewController
@property(nonatomic,strong)ALAssetsGroup *currentGroup;///< 当前对应的相册

/**传入相册*/
-(instancetype)initWithGroup:(ALAssetsGroup *)group;

@end
//当前选择的相册下的图片