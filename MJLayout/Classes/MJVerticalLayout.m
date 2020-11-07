//
//  MJVerticalLayout.m
//  MJLayout
//
//  Created by chenminjie on 2020/11/7.
//

#import "MJVerticalLayout.h"
#import "MJCollectionViewLayoutAttributes.h"

@implementation MJVerticalLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    [self.allSectionHeights removeAllObjects];
    [self.headerAttributes removeAllObjects];
    [self.footerAttributes removeAllObjects];
    [self.decorationAttributes removeAllObjects];
    
    CGFloat totalWidth = self.collectionView.frame.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat headerH = 0;
    CGFloat footerH = 0;
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    // 列间距
    CGFloat minimumLineSpacing = 0;
    CGFloat minimumInteritemSpacing = 0;
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    self.allSectionHeights = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int index = 0; index < sectionCount; index++) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            headerH = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:index].height;
        } else {
            headerH = self.headerReferenceSize.height;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            footerH = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:index].height;
        } else {
            footerH = self.footerReferenceSize.height;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            edgeInsets = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
        } else {
            edgeInsets = self.sectionInset;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:index];
        } else {
            minimumLineSpacing = self.minimumLineSpacing;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index];
        } else {
            minimumInteritemSpacing = self.minimumInteritemSpacing;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:registerBackView:)]) {
            Class className = [self.delegate collectionView:self.collectionView layout:self registerBackView:index];
            if (className != nil) {
                [self registerClass:className forDecorationViewOfKind:NSStringFromClass(className)];
            }
        }
       
        x = edgeInsets.left;
        y = [self maxHeightWithSection:index];
        
        // 添加页首属性
        if (headerH > 0) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            UICollectionViewLayoutAttributes* headerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
            headerAttr.frame = CGRectMake(0, y, self.collectionView.frame.size.width, headerH);
            [headerAttr setValue:[NSValue valueWithCGRect:headerAttr.frame] forKey:@"orginalFrame"];
            [self.allItemAttributes addObject:headerAttr];
            self.headerAttributes[@(index)] = headerAttr;
        }
        
        y += headerH ;
        CGFloat itemStartY = y;
        CGFloat lastY = y;
        
        MJLayoutType layoutType = fill;
        if (itemCount > 0) {
            y += edgeInsets.top;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:typeOfLayout:)]) {
                layoutType = [self.delegate collectionView:self.collectionView layout:self typeOfLayout:index];
            }
            NSInteger columnCount = 1;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:columnCountOfSection:)]) {
                columnCount = [self.delegate collectionView:self.collectionView layout:self columnCountOfSection:index];
            }
            // 定义一个列高数组 记录每一列的总高度
            CGFloat *columnHeight = (CGFloat *) malloc(columnCount * sizeof(CGFloat));
            CGFloat itemWidth = 0.0;
            if (layoutType == column) {
                for (int i=0; i<columnCount; i++) {
                    columnHeight[i] = y;
                }
                itemWidth = (totalWidth - edgeInsets.left - edgeInsets.right - minimumInteritemSpacing * (columnCount - 1)) / columnCount;
            }
            CGFloat maxYOfFill = y;
            NSMutableArray* arrayOfFill = [NSMutableArray new];     //储存填充式布局的数组
            NSMutableArray* arrayOfAbsolute = [NSMutableArray new]; //储存绝对定位布局的数组
            for (int i=0; i<itemCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:index];
                CGSize itemSize = CGSizeZero;
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                    itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                } else {
                    itemSize = self.itemSize;
                }
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                NSInteger preRow = self.allItemAttributes.count - 1;
                switch (layoutType) {
#pragma mark 标签布局处理
                    case label: {
                        //找上一个cell
                        if(preRow >= 0){
                            if(i > 0) {
                                UICollectionViewLayoutAttributes *preAttr = self.allItemAttributes[preRow];
                                x = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                if (x + itemSize.width > totalWidth - edgeInsets.right) {
                                    x = edgeInsets.left;
                                    y += itemSize.height + minimumLineSpacing;
                                }
                            }
                        }
                        if (itemSize.width > (totalWidth-edgeInsets.left-edgeInsets.right)) {
                            itemSize.width = (totalWidth-edgeInsets.left-edgeInsets.right);
                        }
                        attributes.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
                    }
                        break;
#pragma mark 列布局处理
                    case column: {
                        CGFloat max = CGFLOAT_MAX;
                        NSInteger column = 0;
                        for (int i = 0; i < columnCount; i++) {
                            if (columnHeight[i] < max) {
                                max = columnHeight[i];
                                column = i;
                            }
                        }
                        CGFloat itemX = edgeInsets.left + (itemWidth+minimumInteritemSpacing)*column;
                        CGFloat itemY = columnHeight[column];
                        attributes.frame = CGRectMake(itemX, itemY, itemWidth, itemSize.height);
                        columnHeight[column] += (itemSize.height + minimumLineSpacing);
                    }
                        break;
#pragma mark 填充布局处理
                    case fill: {
                        if (arrayOfFill.count == 0) {
                            attributes.frame = CGRectMake(self.isFloor?floor(edgeInsets.left):edgeInsets.left, self.isFloor?floor(maxYOfFill):maxYOfFill, self.isFloor?floor(itemSize.width):itemSize.width, self.isFloor?floor(itemSize.height):itemSize.height);
                            [arrayOfFill addObject:attributes];
                        } else {
                            NSMutableArray *arrayXOfFill = [NSMutableArray new];
                            [arrayXOfFill addObject:self.isFloor?@(floor(edgeInsets.left)):@(edgeInsets.left)];
                            NSMutableArray *arrayYOfFill = [NSMutableArray new];
                            [arrayYOfFill addObject:self.isFloor?@(floor(maxYOfFill)):@(maxYOfFill)];
                            for (UICollectionViewLayoutAttributes* attr in arrayOfFill) {
                                if (![arrayXOfFill containsObject:self.isFloor?@(floor(attr.frame.origin.x)):@(attr.frame.origin.x)]) {
                                    [arrayXOfFill addObject:self.isFloor?@(floor(attr.frame.origin.x)):@(attr.frame.origin.x)];
                                }
                                if (![arrayXOfFill containsObject:self.isFloor?@(floor(attr.frame.origin.x+attr.frame.size.width)):@(attr.frame.origin.x+attr.frame.size.width)]) {
                                    [arrayXOfFill addObject:self.isFloor?@(floor(attr.frame.origin.x+attr.frame.size.width)):@(attr.frame.origin.x+attr.frame.size.width)];
                                }
                                if (![arrayYOfFill containsObject:self.isFloor?@(floor(attr.frame.origin.y)):@(attr.frame.origin.y)]) {
                                    [arrayYOfFill addObject:self.isFloor?@(floor(attr.frame.origin.y)):@(attr.frame.origin.y)];
                                }
                                if (![arrayYOfFill containsObject:self.isFloor?@(floor(attr.frame.origin.y+attr.frame.size.height)):@(attr.frame.origin.y+attr.frame.size.height)]) {
                                    [arrayYOfFill addObject:self.isFloor?@(floor(attr.frame.origin.y+attr.frame.size.height)):@(attr.frame.origin.y+attr.frame.size.height)];
                                }
                            }
                            [arrayXOfFill sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                return [obj1 floatValue] > [obj2 floatValue];
                            }];
                            [arrayYOfFill sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                return [obj1 floatValue] > [obj2 floatValue];
                            }];
                            BOOL qualified = YES;
                            for (NSNumber* yFill in arrayYOfFill) {
                                for (NSNumber* xFill in arrayXOfFill) {
                                    qualified = YES;
                                    CGFloat attrX = self.isFloor?(floor([xFill floatValue])==floor(edgeInsets.left)?floor([xFill floatValue]):(floor([xFill floatValue])+minimumInteritemSpacing)):([xFill floatValue]==edgeInsets.left?[xFill floatValue]:[xFill floatValue]+minimumInteritemSpacing);
                                    CGFloat attrY = self.isFloor?(floor([yFill floatValue])==floor(maxYOfFill)?(floor([yFill floatValue])):(floor([yFill floatValue])+floor(minimumLineSpacing))):([yFill floatValue]==maxYOfFill?([yFill floatValue]):([yFill floatValue])+floor(minimumLineSpacing));
                                    attributes.frame = CGRectMake(attrX, attrY, self.isFloor?floor(itemSize.width):itemSize.width, self.isFloor?floor(itemSize.height):itemSize.height);
                                    if (floor(attributes.frame.origin.x)+floor(attributes.frame.size.width) > floor(totalWidth)-floor(edgeInsets.right)) {
                                        qualified = NO;
                                        break;
                                    }
                                    for (UICollectionViewLayoutAttributes* attr in arrayOfFill) {
                                        if (CGRectIntersectsRect(attributes.frame, attr.frame)) {
                                            qualified = NO;
                                            break;
                                        }
                                    }
                                    if (qualified == NO) {
                                        continue;
                                    } else {
                                        CGPoint leftPt = CGPointMake(attributes.frame.origin.x - minimumInteritemSpacing, attributes.frame.origin.y);
                                        CGRect leftRect = CGRectZero;
                                        for (UICollectionViewLayoutAttributes* attr in arrayOfFill) {
                                            if (CGRectContainsPoint(attr.frame, leftPt)) {
                                                leftRect = attr.frame;
                                                break;
                                            }
                                        }
                                        if (CGRectEqualToRect(leftRect, CGRectZero)) {
                                            break;
                                        } else {
                                            if (attributes.frame.origin.x - (leftRect.origin.x + leftRect.size.width) >= minimumInteritemSpacing) {
                                                break;
                                            } else if (floor(leftRect.origin.x) + floor(leftRect.size.width) <= leftPt.x) {
                                                break;
                                            } else {
                                                CGRect rc = attributes.frame;
                                                rc.origin.x = leftRect.origin.x + leftRect.size.width + minimumInteritemSpacing;
                                                attributes.frame = rc;
                                                for (UICollectionViewLayoutAttributes* attr in arrayOfFill) {
                                                    if (CGRectIntersectsRect(attributes.frame, attr.frame)) {
                                                        qualified = NO;
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if (qualified == YES) {
                                    break;
                                }
                            }
                            if (qualified == YES) {
                                //NSLog(@"第%d个,合格的矩形区域=%@",i,NSStringFromCGRect(attributes.frame));
                            }
                            [arrayOfFill addObject:attributes];
                        }
                    }
                        break;
#pragma mark 绝对定位布局处理
                    case absolute: {
                        CGRect itemFrame = CGRectZero;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:rectOfItem:)]) {
                            itemFrame = [self.delegate collectionView:self.collectionView layout:self rectOfItem:indexPath];
                        }
                        CGFloat absolute_x = edgeInsets.left+itemFrame.origin.x;
                        CGFloat absolute_y = y+itemFrame.origin.y;
                        CGFloat absolute_w = itemFrame.size.width;
                        if ((absolute_x+absolute_w>self.collectionView.frame.size.width-edgeInsets.right)&&(absolute_x<self.collectionView.frame.size.width-edgeInsets.right)) {
                            absolute_w -= (absolute_x+absolute_w-(self.collectionView.frame.size.width-edgeInsets.right));
                        }
                        CGFloat absolute_h = itemFrame.size.height;
                        attributes.frame = CGRectMake(absolute_x, absolute_y, absolute_w, absolute_h);
                        [arrayOfAbsolute addObject:attributes];
                    }
                        break;
                    default: {
                        //NSLog(@"%@",NSStringFromCGRect(attributes.frame));
                    }
                        break;
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:transformOfItem:)]) {
                    attributes.transform3D = [self.delegate collectionView:self.collectionView layout:self transformOfItem:indexPath];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:zIndexOfItem:)]) {
                    attributes.zIndex = [self.delegate collectionView:self.collectionView layout:self zIndexOfItem:indexPath];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:alphaOfItem:)]) {
                    attributes.alpha = [self.delegate collectionView:self.collectionView layout:self alphaOfItem:indexPath];
                }
                attributes.indexPath = indexPath;
                if (layoutType == column) {
                    CGFloat max = 0;
                    for (int i = 0; i < columnCount; i++) {
                        if (columnHeight[i] > max) {
                            max = columnHeight[i];
                        }
                    }
                    lastY = max;
                } else if (layoutType == fill) {
                    if (i==itemCount-1) {
                        for (UICollectionViewLayoutAttributes* attr in arrayOfFill) {
                            if (maxYOfFill < attr.frame.origin.y+attr.frame.size.height) {
                                maxYOfFill = attr.frame.origin.y+attr.frame.size.height;
                            }
                        }
                    }
                    lastY = maxYOfFill;
                } else if (layoutType == absolute) {
                    if (i==itemCount-1) {
                        for (UICollectionViewLayoutAttributes* attr in arrayOfAbsolute) {
                            if (lastY < attr.frame.origin.y+attr.frame.size.height) {
                                lastY = attr.frame.origin.y+attr.frame.size.height;
                            }
                        }
                    }
                } else {
                    lastY = attributes.frame.origin.y + attributes.frame.size.height;
                }
            }
            free(columnHeight);
        }
        if (layoutType == column) {
            if (itemCount > 0) {
                lastY -= minimumLineSpacing;
            }
        }
        if (itemCount > 0) {
            lastY += edgeInsets.bottom;
        }
        
#pragma mark 添加背景图
        CGFloat backHeight = lastY-itemStartY+([self isAttachToTop:index]?headerH:0)+([self isAttachToBottom:index]?footerH:0);
        if (backHeight < 0) {
            backHeight = 0;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:registerBackView:)]) {
            Class className = [self.delegate collectionView:self.collectionView layout:self registerBackView:index];
            if (className != nil) {
                UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes  layoutAttributesForDecorationViewOfKind:NSStringFromClass(className) withIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
                attr.frame = CGRectMake(0, [self isAttachToTop:index]?itemStartY-headerH:itemStartY, self.collectionView.frame.size.width, backHeight);
                attr.zIndex = -1000;
                [self.allItemAttributes addObject:attr];
                self.decorationAttributes[@(index)] = attr;
            }
        }
        
        // 添加页脚属性
        if (footerH > 0) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            UICollectionViewLayoutAttributes *footerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
            footerAttr.frame = CGRectMake(0, lastY, self.collectionView.frame.size.width, footerH);
            [self.allItemAttributes addObject:footerAttr];
            self.footerAttributes[@(index)] = footerAttr;
            lastY += footerH;
        }
        self.allSectionHeights[index] = [NSNumber numberWithFloat:lastY];
    }

}

#pragma mark - CollectionView的滚动范围
- (CGSize)collectionViewContentSize
{
    if (self.allSectionHeights.count <= 0) {
        return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    }
    CGFloat footerH = 0.0f;
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        footerH = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:self.allSectionHeights.count-1].height;
    } else {
        footerH = self.footerReferenceSize.height;
    }
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        edgeInsets = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:self.allSectionHeights.count-1];
    } else {
        edgeInsets = self.sectionInset;
    }
    return CGSizeMake(self.collectionView.frame.size.width, [self.allSectionHeights[self.allSectionHeights.count-1] floatValue]);// + edgeInsets.bottom + footerH);
    
}

/**
 每个区的初始Y坐标
 @param section 区索引
 @return Y坐标
 */
- (CGFloat)maxHeightWithSection:(NSInteger)section {
    if (section>0) {
        return [self.allSectionHeights[section-1] floatValue];
    } else {
        return 0;
    }
}

- (BOOL)isAttachToTop:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:attachToTop:)]) {
        return [self.delegate collectionView:self.collectionView layout:self attachToTop:section];
    }
    return NO;
}

- (BOOL)isAttachToBottom:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:attachToBottom:)]) {
        return [self.delegate collectionView:self.collectionView layout:self attachToBottom:section];
    }
    return NO;
}

@end
