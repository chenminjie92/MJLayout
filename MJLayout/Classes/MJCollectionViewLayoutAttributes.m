//
//  MJCollectionViewLayoutAttributes.m
//  MJLayout
//
//  Created by chenminjie on 2020/11/7.
//

#import "MJCollectionViewLayoutAttributes.h"

@implementation MJCollectionViewLayoutAttributes

@synthesize orginalFrame = _orginalFrame;

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath orginalFrmae:(CGRect)orginalFrame{
    MJCollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    [layoutAttributes setValue:[NSValue valueWithCGRect:orginalFrame] forKey:@"orginalFrame"];
    layoutAttributes.frame = orginalFrame;
    
    return layoutAttributes;
}

-(CGRect)orginalFrame
{
    if ([self.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _orginalFrame;
    }else{
        return self.frame;
    }
}

@end
