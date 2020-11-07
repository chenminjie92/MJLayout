//
//  MJLayout.m
//  MJLayout
//
//  Created by chenminjie on 2020/11/7.
//

#import "MJLayout.h"
#import "MJCollectionViewLayoutAttributes.h"

@interface MJLayout ()

@end

@implementation MJLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.isFloor = YES;
    }
    return self;
}

#pragma mark - 所有cell和view的布局属性
-(NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.allItemAttributes.count >0 ? self.allItemAttributes : [super layoutAttributesForElementsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    return self.decorationAttributes[@(indexPath.section)] != nil ? self.decorationAttributes[@(indexPath.section)] : [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
      attribute = self.headerAttributes[@(indexPath.section)];
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
      attribute = self.footerAttributes[@(indexPath.section)];
    }
    return attribute;
    
}
#pragma mark - 当尺寸有所变化时，重新刷新
// 当尺寸有所变化时，重新刷新
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //TODO: 做了修改处理购物车头部复用问题
    return YES;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    //外部调用relaodData或者增删cell后重修修改所有布局
    [super invalidateLayoutWithContext:context];
}

#pragma mark - 懒加载
-(NSMutableArray<UICollectionViewLayoutAttributes *> *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [[NSMutableArray alloc] init];
    }
    return _allItemAttributes;
}
-(NSMutableArray<UICollectionViewLayoutAttributes *> *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [[NSMutableArray alloc] init];
    }
    return _sectionItemAttributes;
}
-(NSMutableArray<NSNumber *> *)allSectionHeights {
    if (!_allSectionHeights) {
        _allSectionHeights = [[NSMutableArray alloc] init];
    }
    return _allSectionHeights;
}
-(NSMutableDictionary *)headerAttributes {
    if (!_headerAttributes) {
        _headerAttributes = [[NSMutableDictionary alloc] init];
    }
    return _headerAttributes;
}
-(NSMutableDictionary *)footerAttributes {
    
    if (!_footerAttributes) {
        _footerAttributes = [[NSMutableDictionary alloc] init];
    }
    return _footerAttributes;
}
-(NSMutableDictionary *)decorationAttributes {
    if (!_decorationAttributes) {
        _decorationAttributes = [[NSMutableDictionary alloc] init];
    }
    return _decorationAttributes;
}

-(id<MJLayoutDelegate>)delegate {
    return (id <MJLayoutDelegate>)self.collectionView.delegate;
}
@end
