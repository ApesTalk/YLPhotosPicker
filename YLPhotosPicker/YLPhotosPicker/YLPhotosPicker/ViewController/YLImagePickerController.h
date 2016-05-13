//
//  YLImagePickerController.h
//  YouLanAgents
//
//  Created by TK-001289 on 15/5/21.
//  Copyright (c) 2015年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLImagePickerController : UIImagePickerController

@end

/*
 程序中有多处需要选择照片或者拍照的地方，为了统一导航的样式，特此创建这个类，选择照片或者拍照请使用此类而不要直接用UIImagePickerController
  
 注意：保持状态条颜色统一的做法！
 */