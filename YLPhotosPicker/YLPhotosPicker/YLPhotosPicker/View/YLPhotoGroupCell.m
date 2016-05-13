//
//  YLPhotoGroupCell.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotoGroupCell.h"
#import "YLPhotosPickerConfig.h"

static CGFloat const posterSize = 60.f;
static CGFloat const cellHeight = 80.f;

@implementation YLPhotoGroupCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        CGFloat x = 15.f;
        _posterImageView = [[UIImageView alloc]init];
        _posterImageView.frame = CGRectMake(10, 15, posterSize, posterSize);
        [self.contentView addSubview:_posterImageView];
        
        x += posterSize + 5;
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.frame = CGRectMake(x, (cellHeight - 21) * 0.5, kScreenWidth - x - 10, 21);
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = kTitleColor;
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

+(CGFloat)height
{
    return cellHeight;
}

@end
