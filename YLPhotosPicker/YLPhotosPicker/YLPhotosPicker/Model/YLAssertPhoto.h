//
//  YLAssertPhoto.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ALAsset;

@interface YLAssertPhoto : NSObject
@property (nonatomic,strong) ALAsset  *asset;              ///< 对应的原始资产
@property (nonatomic,assign) BOOL      isSelected;         ///< 是否被选中

-(instancetype)initWithAsset:(ALAsset *)asset selected:(BOOL)selected;
-(long long)size;


@end

//对应相册中的每一张图片