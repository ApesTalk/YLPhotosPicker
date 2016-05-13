//
//  YLImagePickerController.m
//  YouLanAgents
//
//  Created by TK-001289 on 15/5/21.
//  Copyright (c) 2015年 YL. All rights reserved.
//

#import "YLImagePickerController.h"

@interface YLImagePickerController ()

@end

@implementation YLImagePickerController

-(instancetype)init
{
    if(self = [super init]){
        [self customBar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)customBar
{
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
