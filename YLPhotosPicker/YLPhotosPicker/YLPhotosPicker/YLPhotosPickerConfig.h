//
//  YLPhotosPickerConfig.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/22.
//  Copyright © 2016年 YL. All rights reserved.
//

#ifndef YLPhotosPickerConfig_h
#define YLPhotosPickerConfig_h

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kContentColor HEXCOLOR(0x999999)
#define kTitleColor HEXCOLOR(0x333333)
#define kHightlightColor HEXCOLOR(0x179834)

#define kYLPhotosPickerSendImagesNotificationName @"kYLPhotosPickerSendImagesNotificationName"

#endif /* YLPhotosPickerConfig_h */
