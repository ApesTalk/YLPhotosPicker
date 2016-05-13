//
//  YLPhotoGroupCell.h
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLPhotoGroupCell : UITableViewCell
@property (nonatomic,strong) UIImageView  *posterImageView; ///< 海报图
@property (nonatomic,strong) UILabel      *nameLabel;       ///< 相册名字

+(CGFloat)height;

@end
//相册列表cell