//
//  YLPhotoGroupsViewController.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotoGroupsViewController.h"
#import "YLPhotosPickerConfig.h"
#import "YLPhotoGroupCell.h"
#import "YLAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YLPhotosCollectionViewController.h"

@interface YLPhotoGroupsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *groupList;
    UITableView *table;
}
@end

@implementation YLPhotoGroupsViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"相册";
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancelBtnAction)];
    
    self.navigationItem.rightBarButtonItem = barCancel;
    
    
    table = [[UITableView alloc] initWithFrame:self.view.bounds];
    table.showsVerticalScrollIndicator = NO;
    table.tableFooterView = [[UIView alloc]init];
    table.estimatedRowHeight = UITableViewAutomaticDimension;
    [table registerClass:[YLPhotoGroupCell class] forCellReuseIdentifier:@"YLPhotoGroupCell"];
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    
    YLAssetManager *manager = [YLAssetManager manager];
    [manager getAssetGroupList:^(NSArray *array) {
        groupList = array;
        [table reloadData];
        
        YLPhotosCollectionViewController *photosVc = [[YLPhotosCollectionViewController alloc]init];
        if(groupList.count>0){
            photosVc.currentGroup = [groupList firstObject];
        }
        [self.navigationController pushViewController:photosVc animated:NO];
    }];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YLPhotoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YLPhotoGroupCell"];
    ALAssetsGroup *group = groupList[indexPath.row];
    cell.posterImageView.image = [UIImage imageWithCGImage:[group posterImage]];
    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger assestsCount = [group numberOfAssets];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@(%li)",name,assestsCount];
    return cell;
}

#pragma mark---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YLPhotoGroupCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YLPhotosCollectionViewController *photosVc = [[YLPhotosCollectionViewController alloc]initWithGroup:groupList[indexPath.row]];
    [self.navigationController pushViewController:photosVc animated:YES];
}

#pragma mark---other methods
- (void)cancelBtnAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[YLAssetManager manager]reset];
    }];
}

@end
