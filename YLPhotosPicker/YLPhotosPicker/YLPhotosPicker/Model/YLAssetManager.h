//
//  YLAssetManager.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class ALAsset;
@class ALAssetsGroup;
@class YLAssertPhoto;

typedef NS_ENUM(NSUInteger,YLAssetRepresentationType){
    YLAssetRepresentationTypeThumbnail = 0,             ///< 缩略图
    YLAssetRepresentationTypeAspectRatioThumbnail,     ///< aspectRatioThumbnail
    YLAssetRepresentationTypeFullScreenImage,         ///< 全屏图fullScreenImage
    YLAssetRepresentationTypeFullResolution          ///< fullResolutionImage
};

typedef void (^YLAssetsSuccessBlock)(NSArray *array);
typedef void (^ALAssetsFailureBlock)(NSError *error);

@interface YLAssetManager : NSObject
@property (nonatomic,assign        ) NSUInteger       maxSelectCount;     ///< 最多可选择多少张图片，默认为1
@property (nonatomic, copy,readonly) NSMutableArray  *selectedPhotos;     ///< 已经选择了的图片数组
@property (nonatomic, copy,readonly) NSMutableArray  *assetGroups;        ///< 资产分组数据
@property (nonatomic, copy,readonly) NSMutableArray  *currentGroupPhotos; ///< 当前Group下的图片数组

/**单例*/
+ (instancetype)manager;

/** 获得所有资产组 即相册*/
-(void)getAssetGroupList:(YLAssetsSuccessBlock)successBlock;

/**传入资产分组 获取该组下面的所有图片*/
-(void)getPhotosInGroup:(ALAssetsGroup *)group
            complection:(YLAssetsSuccessBlock)successBlock;

/**传入资产分组 获取该组下面的指定数量图片*/
-(void)getPhotosInGroup:(ALAssetsGroup *)group
              withCount:(NSUInteger)count
            complection:(YLAssetsSuccessBlock)successBlock;

/**获取已保存的资产组下的所有图片*/
-(void)getSavedPhotosComplection:(YLAssetsSuccessBlock)successBlock
                           error:(ALAssetsFailureBlock)errorBlock;

/**获取已保存的资产组下的指定数量的图片*/
-(void)getSavedPhotosWithCount:(NSUInteger)count
                   complection:(YLAssetsSuccessBlock)successBlock
                         error:(ALAssetsFailureBlock)errorBlock;

/**重置信息*/
- (void)reset;

/**获得指定资源指定类型的图片*/
- (UIImage *)imageForPhoto:(YLAssertPhoto *)photo
                      type:(YLAssetRepresentationType)type;

/**选择指定图片，如果已经包含了，则移除；如果未包含，则添加到selectedPhotos，达到最大值后弹窗提示*/
- (BOOL)selectPhoto:(YLAssertPhoto *)photo;


/**发起发送图片的通知  是否压缩*/
-(void)postSendImages:(NSArray *)images compress:(BOOL)compress;

@end

//资产操作者


/*
 AdjustmentXMP
 http://www.cnblogs.com/sohobloo/p/3988990.html
 https://gist.github.com/klazuka/5439717
 */