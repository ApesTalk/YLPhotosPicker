//
//  YLAssetManager.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YLAssertPhoto.h"
#import "YLPhotosPickerConfig.h"

@interface YLAssetManager ()
@property(nonatomic,strong)ALAssetsLibrary *assetsLibrary;///< 资产操作
@property (nonatomic, copy) NSMutableArray  *selectedPhotos;     ///< 已经选择了的图片数组
@property (nonatomic, copy) NSMutableArray  *assetGroups;        ///< 资产分组数据
@property (nonatomic, copy) NSMutableArray  *currentGroupPhotos; ///< 当前Group下的图片数组
@end

@implementation YLAssetManager
+ (instancetype)manager
{
    static YLAssetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YLAssetManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    if(self = [super init]){
        _maxSelectCount = 1;
        _selectedPhotos = [NSMutableArray array];
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return self;
}

/** 获得所有资产组 即相册*/
-(void)getAssetGroupList:(YLAssetsSuccessBlock)successBlock
{
    _assetGroups = [NSMutableArray array];
    
    //该方法会将枚举到的资产组一个个通过block回调返回
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //设置资产过滤器 只获取图片分组
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        if(group==nil){
            successBlock(_assetGroups);
            *stop = YES;
        }else
        {
            //相册一个个倒序
            [_assetGroups insertObject:group atIndex:0];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"getAssetGroupList: Error : %@", [error description]);
    }];
}

/**传入资产分组 获取该组下面的所有图片*/
-(void)getPhotosInGroup:(ALAssetsGroup *)group
            complection:(YLAssetsSuccessBlock)successBlock
{
    [self getPhotosInGroup:group withCount:NSUIntegerMax complection:successBlock];
}

-(void)getPhotosInGroup:(ALAssetsGroup *)group
              withCount:(NSUInteger)count
            complection:(YLAssetsSuccessBlock)successBlock
{
    NSUInteger limit = MAX(count, 1);
    _currentGroupPhotos = [NSMutableArray array];
    
    //设置图片过滤器  只获取图片
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    //该方法会将枚举到的图片资源一个个通过block回调返回
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result==nil){
            successBlock(_currentGroupPhotos);
            *stop = YES;
        }else{
            //相册中的图片倒序
            if(_currentGroupPhotos.count < limit){
                YLAssertPhoto *photo = [[YLAssertPhoto alloc]initWithAsset:result selected:NO];
                [_currentGroupPhotos insertObject:photo atIndex:0];
            }
        }
    }];
}

/**获取已保存的资产组下的所有图片*/
-(void)getSavedPhotosComplection:(YLAssetsSuccessBlock)successBlock
                           error:(ALAssetsFailureBlock)errorBlock
{
    [self getSavedPhotosWithCount:NSUIntegerMax complection:successBlock error:errorBlock];
}

-(void)getSavedPhotosWithCount:(NSUInteger)count
                   complection:(YLAssetsSuccessBlock)successBlock
                         error:(ALAssetsFailureBlock)errorBlock
{
    //该方法将匹配的资产组一个个通过block回调返回
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group==nil){
            *stop = YES;
        }else{
            //得到已保存的资产组
            if([[group valueForProperty:ALAssetsGroupPropertyType]intValue]==ALAssetsGroupSavedPhotos){
                //确认是已保存的资产组
                //获得该资产组下的所有图片
                [self getPhotosInGroup:group withCount:count complection:successBlock];
            }else{
                *stop = YES;
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"getSavedPhotosComplection: Error : %@", [error description]);
        errorBlock(error);
    }];
}

- (void)reset
{
    //这里只能删除数据，不能设置为nil，因为manager是单例
    [_selectedPhotos removeAllObjects];
    [_assetGroups removeAllObjects];
    [_currentGroupPhotos removeAllObjects];
}

- (UIImage *)imageForPhoto:(YLAssertPhoto *)photo type:(YLAssetRepresentationType)type
{
    CGImageRef iRef = nil;
    
    ALAsset *asset = photo.asset;
    if (type == YLAssetRepresentationTypeThumbnail)
        iRef = [asset thumbnail];
    else if (type == YLAssetRepresentationTypeAspectRatioThumbnail)
        iRef = [asset aspectRatioThumbnail];
    else if (type == YLAssetRepresentationTypeFullScreenImage)
        iRef = [asset.defaultRepresentation fullScreenImage];
    else if (type == YLAssetRepresentationTypeFullResolution)
    {
        NSString *strXMP = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]])
        {
            iRef = [asset.defaultRepresentation fullResolutionImage];
            return [UIImage imageWithCGImage:iRef scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        }
        else
        {
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            
            CIImage *image = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgimage = [context createCGImage:image fromRect:[image extent]];
            UIImage *iImage = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            return iImage;
        }
    }
    return [UIImage imageWithCGImage:iRef];
}


- (BOOL)selectPhoto:(YLAssertPhoto *)photo
{
    if([self.selectedPhotos containsObject:photo]){
        [self.selectedPhotos removeObject:photo];
        return NO;
    }else{
        if(self.selectedPhotos.count < self.maxSelectCount){
            [self.selectedPhotos addObject:photo];
            return YES;
        }else{
            //达到上限，弹窗提示
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:[NSString stringWithFormat:@"最多只能选择%li张照片",self.maxSelectCount]
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
}


-(void)postSendImages:(NSArray *)images compress:(BOOL)compress
{
    //TODO: 压缩处理
    if(images.count!=0){
        [[NSNotificationCenter defaultCenter]postNotificationName:kYLPhotosPickerSendImagesNotificationName object:images];
        [self.selectedPhotos removeObjectsInArray:images];
    }else{
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.selectedPhotos.count];
        for(YLAssertPhoto *photo in self.selectedPhotos){
            [array addObject:[self imageForPhoto:photo type:YLAssetRepresentationTypeFullScreenImage]];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kYLPhotosPickerSendImagesNotificationName object:array];
        [self reset];
    }
}

@end
