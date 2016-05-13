//
//  YLSelectImagesView.m
//  YLPhotosPicker
//
//  Created by TK-001289 on 16/4/25.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLSelectImagesView.h"
#import "YLSelectImagesCollectionCell.h"
#import "YLAssetManager.h"
#import "YLAssertPhoto.h"

CGFloat const kSelectImageHeight = 150.f;
static CGFloat const kSelectImageWidth = 100.f;

@interface YLSelectImagesView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    NSArray *images;
}
@property (nonatomic, strong) UICollectionView *myCollectionView;
@end

@implementation YLSelectImagesView
-(instancetype)init
{
    if(self = [super init]){
        [self addSubview:self.myCollectionView];
        self.clipsToBounds = NO;
        [self loadData];
    }
    return self;
}

-(instancetype)initWithMaxShowCount:(NSUInteger)count
{
    if(self = [super init]){
        self.maxShowCount = count;
        [self addSubview:self.myCollectionView];
        self.clipsToBounds = NO;
        [self loadData];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.myCollectionView];
        self.clipsToBounds = NO;
        [self loadData];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.myCollectionView.frame = self.bounds;
}

-(void)loadData
{
    //可以像QQ那样指定显示多少图片
//    [[YLAssetManager manager]getSavedPhotosWithCount:self.maxShowCount complection:^(NSArray *array) {
//        images = array;
//        [_myCollectionView reloadData];
//    } error:^(NSError *error) {
//        
//    }];
    
    //显示所有图片
    [[YLAssetManager manager]getSavedPhotosComplection:^(NSArray *array) {
        images = array;
        [_myCollectionView reloadData];
    } error:^(NSError *error) {
        
    }];
}

-(UICollectionView *)myCollectionView
{
    if(!_myCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.itemSize = CGSizeMake(kSelectImageWidth, kSelectImageHeight-10);
        
        _myCollectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _myCollectionView.backgroundColor = [UIColor clearColor];
        _myCollectionView.showsVerticalScrollIndicator = NO;
        [_myCollectionView registerClass:[YLSelectImagesCollectionCell class] forCellWithReuseIdentifier:@"YLSelectImagesCollectionCell"];
        _myCollectionView.delegate = self;
        _myCollectionView.dataSource = self;
        _myCollectionView.clipsToBounds = NO;
    }
    return _myCollectionView;
}

#pragma mark---UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLSelectImagesCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YLSelectImagesCollectionCell" forIndexPath:indexPath];
    YLAssertPhoto *photo = [images objectAtIndex:indexPath.row];
    [cell refreshWithPhoto:photo];
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    cell.exclusiveTouch = YES;
    cell.imageView.tag = indexPath.row;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlerPan:)];
    [cell.imageView addGestureRecognizer:panGesture];
//    [panGesture requireGestureRecognizerToFail:_myCollectionView.panGestureRecognizer];
    panGesture.delegate = self;
    return cell;
}

#pragma mark---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLSelectImagesCollectionCell *cell = (YLSelectImagesCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self selectImage:cell.selectBtn];
}

#pragma mark---other methods
- (void)reloadData
{
    [self.myCollectionView reloadData];
}

-(void)selectImage:(UIButton *)sender
{
    NSInteger index = sender.tag;
    YLAssertPhoto *currentPhoto = images[index];
    YLAssetManager *manager = [YLAssetManager manager];
    currentPhoto.isSelected = [manager selectPhoto:currentPhoto];
    [_myCollectionView reloadData];
    
    if([_delegate respondsToSelector:@selector(selectedImageChanged)]){
        [_delegate selectedImageChanged];
    }
}

-(void)handlerPan:(UIPanGestureRecognizer *)gesture
{
    UIViewController *roootVc = [[[[UIApplication sharedApplication]delegate]window]rootViewController];
    
    //转换到根视图上的位置
    CGPoint point = [gesture translationInView:roootVc.view];
    
    CGFloat x = gesture.view.center.x;
    CGFloat y = gesture.view.center.y + point.y;
    
    YLSelectImagesCollectionCell *cell = (YLSelectImagesCollectionCell *)[_myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:gesture.view.tag inSection:0]];
    [cell showTips:y < 0];
    
    NSLog(@"point.x= %f point.y=%f",point.x,point.y);
    NSLog(@"x= %f y=%f",x,y);
    
    if(gesture.state==UIGestureRecognizerStateEnded){
        if(y < 0){
            //发送
            
            UIView *snipView = [gesture.view snapshotViewAfterScreenUpdates:NO];
            snipView.frame = gesture.view.frame;
            CGRect rect = CGRectMake(gesture.view.center.x, gesture.view.center.y, 0, 0);
            
            gesture.view.alpha = 0.f;
            [UIView animateWithDuration:1 animations:^{
                snipView.frame = rect;
            } completion:^(BOOL finished) {
                
                YLAssertPhoto *currentPhoto = images[gesture.view.tag];
                UIImage *currentImage = [[YLAssetManager manager]imageForPhoto:currentPhoto type:YLAssetRepresentationTypeFullScreenImage];
                [[YLAssetManager manager]postSendImages:@[currentImage] compress:YES];
                
                if([_delegate respondsToSelector:@selector(selectedImageChanged)]){
                    [_delegate selectedImageChanged];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    gesture.view.alpha = 1.f;
                    [_myCollectionView reloadData];
                });
            }];
            
            
        }else{
            //回归
            y = CGRectGetMidY(gesture.view.bounds);//imageview的一半高度
            gesture.view.center = CGPointMake(x, y);
            [gesture setTranslation:CGPointMake(0, 0) inView:roootVc.view];
        }
        return;
    }
    gesture.view.center = CGPointMake(x, y);
    [gesture setTranslation:CGPointMake(0, 0) inView:roootVc.view];
}

//两个手势是否可以同时响应
//http://blog.csdn.net/assholeu/article/details/16821151
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(otherGestureRecognizer==_myCollectionView.panGestureRecognizer){
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:_myCollectionView];
        if(ABS(translation.y) > ABS(translation.x)){
            //上下拖动
            return NO;
        }else{
            //左右拖动
        }
        return YES;
    }else{
        return NO;
    }
}

@end
