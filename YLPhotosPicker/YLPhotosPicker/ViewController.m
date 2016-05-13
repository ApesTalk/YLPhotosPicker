//
//  ViewController.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/22.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "ViewController.h"
#import "YLPhotosActionSheet.h"
#import "YLPhotosPickerConfig.h"

@interface ViewController ()<YLPhotosActionSheetDelegate>
{
    NSMutableArray *images;
    UIImageView *imageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:kTitleColor forState:UIControlStateNormal];
    [btn setTitle:@"选择图片" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectImages) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 100, 100, 50);
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 160, 200, 250)];
    imageView.hidden = YES;
    [self.view addSubview:imageView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedImagesPost:) name:kYLPhotosPickerSendImagesNotificationName object:nil];
}

-(void)selectImages
{
    [images removeAllObjects];
    [imageView stopAnimating];
    imageView.hidden = YES;
    
    YLPhotosActionSheet *actionSheet = [[YLPhotosActionSheet alloc]initWithMaxShowCount:10 maxSelectCount:9 delegate:self];
    [actionSheet showInView:self.view];
}


-(void)receivedImagesPost:(NSNotification *)notification
{
    if(!images){
        images = [NSMutableArray array];
    }else{
        [images removeAllObjects];
    }
    
    NSArray *objects = notification.object;
    [images addObjectsFromArray:objects];
    imageView.animationImages = images;
    imageView.animationDuration = images.count * 0.5;
    imageView.animationRepeatCount = 0;
    imageView.hidden = NO;
    [imageView startAnimating];
    
    for(UIImage *img in objects){
        NSLog(@"img:%@",img);
    }
}

#pragma mark---YLPhotosActionSheetDelegate
- (void)photosActionSheet:(YLPhotosActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex=%li",buttonIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
