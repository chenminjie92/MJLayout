//
//  MJLayout.h
//  MJLayout
//
//  Created by chenminjie on 2020/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    /// 填充式布局
    fill      = 0,
    /// 瀑布流
    column = 1,
    /// 标签布局
    label     = 2,
    /// 绝对定位
    absolute  = 3
    
} MJLayoutType;

@protocol  MJLayoutDelegate <NSObject, UICollectionViewDelegate>

@optional
//指定是什么布局，如没有指定则为BaseLayout(基础布局)
- (MJLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;

//自定义每个section的背景view，需要继承UICollectionReusableView，返回类
- (nullable Class)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout registerBackView:(NSInteger)section;

//背景是否延伸覆盖到headerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout attachToTop:(NSInteger)section;

//背景是否延伸覆盖到footerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout attachToBottom:(NSInteger)section;


/******** 提取出UICollectionViewLayoutAttributes的一些属性 ***********/
//设置每个item的zIndex，不指定默认为0
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath;
//设置每个item的CATransform3D，不指定默认为CATransform3DIdentity
- (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath;
//设置每个item的alpha，不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout alphaOfItem:(NSIndexPath*)indexPath;

/******** waterfall布局需要的代理 ***********/
//在waterfall布局中指定一行有几列，不指定默认为1列
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section;

/******** absolute绝对定位布局需要的代理 ***********/
//在absolute绝对定位布局中指定每个item的frame，不指定默认为CGRectZero
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout rectOfItem:(NSIndexPath*)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout stickyHeaderYOffsetInSection:(NSInteger)section;

@end

@interface MJLayout : UICollectionViewFlowLayout

//代理
@property (nonatomic, weak) id <MJLayoutDelegate> delegate;
//宽度是否向下取整，默认YES，用于填充布局
@property (nonatomic,assign) BOOL isFloor;
/// 存放每一个cell的属性
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*> *allItemAttributes;
/// 存放每组的attributes
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*> *sectionItemAttributes;
/// 存放每一组的高度
@property (nonatomic, strong) NSMutableArray<NSNumber *> *allSectionHeights;
/// 存放所有的headerAttributes
@property (nonatomic, strong) NSMutableDictionary *headerAttributes;
/// 存放所有的footerAttributes
@property (nonatomic, strong) NSMutableDictionary *footerAttributes;
/// 存放所有的装饰视图
@property (nonatomic, strong) NSMutableDictionary *decorationAttributes;

@end

NS_ASSUME_NONNULL_END
