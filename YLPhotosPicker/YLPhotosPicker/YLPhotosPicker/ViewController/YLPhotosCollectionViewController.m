//
//  YLPhotosCollectionViewController.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotosCollectionViewController.h"
#import "YLPhotosPickerConfig.h"
#import "YLPhotoGroupCell.h"
#import "YLAssetManager.h"
#import "YLSelectImagesCollectionCell.h"
#import "YLAssertPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YLPhotosBrowserViewController.h"
#import "YLPhotosPickerToolBar.h"

@interface YLPhotosCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,YLPhotosBrowserDelegate>
{
    NSArray                *photos;
    UICollectionView       *myCollectionView;
    YLPhotosPickerToolBar  *toolBar;
}
@end

@implementation YLPhotosCollectionViewController
-(instancetype)initWithGroup:(ALAssetsGroup *)group
{
    if(self = [super init]){
        _currentGroup = group;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = [_currentGroup valueForProperty:ALAssetsGroupPropertyName];
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancelBtnAction)];
    
    self.navigationItem.rightBarButtonItem = barCancel;
    
    [self initCollectionView];
    [self initToolBar];
    
    [self loadData];
    [toolBar reload];
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    CGFloat itemSize = (kScreenWidth - 5 * 5) / 4.0;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
    
    myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44) collectionViewLayout:layout];
    myCollectionView.backgroundColor = [UIColor clearColor];
    myCollectionView.showsVerticalScrollIndicator = NO;
    [myCollectionView registerClass:[YLSelectImagesCollectionCell class] forCellWithReuseIdentifier:@"YLSelectImagesCollectionCell"];
    myCollectionView.delegate = self;
    myCollectionView.dataSource = self;
    [self.view addSubview:myCollectionView];
}

- (void)initToolBar
{
    toolBar = [[YLPhotosPickerToolBar alloc]initWithToolBarType:YLPhotosPickerToolBarTypePreview];
    toolBar.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
    [toolBar.previewBtn addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.sendBtn addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadData
{
    [[YLAssetManager manager]getPhotosInGroup:_currentGroup complection:^(NSArray *array) {
        [array enumerateObjectsUsingBlock:^(YLAssertPhoto *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           obj.isSelected = [[YLAssetManager manager].selectedPhotos containsObject:obj];
        }];
        photos = array;
        
        [myCollectionView reloadData];
    }];
}

#pragma mark---UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLSelectImagesCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YLSelectImagesCollectionCell" forIndexPath:indexPath];
    YLAssertPhoto *photo = [photos objectAtIndex:indexPath.row];
    [cell refreshWithPhoto:photo];
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLPhotosBrowserViewController *browserVc = [[YLPhotosBrowserViewController alloc]initWithPhotos:photos];
    browserVc.currentIndex = indexPath.row;
    browserVc.delegate = self;
    [self.navigationController pushViewController:browserVc animated:YES];
}

#pragma mark---YLPhotosBrowserDelegate
-(void)selectedPhotosChanged
{
    [photos enumerateObjectsUsingBlock:^(YLAssertPhoto *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = [[YLAssetManager manager].selectedPhotos containsObject:obj];
    }];
    [myCollectionView reloadData];
    [toolBar reload];
}

#pragma mark---other methods
-(void)selectImage:(UIButton *)sender
{
    NSInteger index = sender.tag;
    YLAssertPhoto *currentPhoto = photos[index];
    YLAssetManager *manager = [YLAssetManager manager];
    currentPhoto.isSelected = [manager selectPhoto:currentPhoto];
    [myCollectionView reloadData];
    [toolBar reload];
}

- (void)cancelBtnAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[YLAssetManager manager]reset];
    }];
}

- (void)preview
{
    YLPhotosBrowserViewController *browserVc = [[YLPhotosBrowserViewController alloc]initWithPhotos:[YLAssetManager manager].selectedPhotos];
    browserVc.delegate = self;
    [self.navigationController pushViewController:browserVc animated:YES];
}

- (void)sendImage
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[YLAssetManager manager]postSendImages:nil compress:YES];
    }];
}

@end
