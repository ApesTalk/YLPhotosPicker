//
//  YLAssertPhoto.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLAssertPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation YLAssertPhoto
-(instancetype)initWithAsset:(ALAsset *)asset selected:(BOOL)selected
{
    if(self = [super init]){
        self.asset = asset;
        self.isSelected = selected;
    }
    return self;
}

-(long long)size
{
    return [self.asset.defaultRepresentation size];
}

-(BOOL)isEqual:(id)object
{
    YLAssertPhoto *anotherPhoto = (YLAssertPhoto *)object;
    return [[self.asset valueForProperty:ALAssetPropertyAssetURL]isEqual:[anotherPhoto.asset valueForProperty:ALAssetPropertyAssetURL]];
}

@end
