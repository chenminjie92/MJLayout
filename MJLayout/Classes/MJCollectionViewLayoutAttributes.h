//
//  MJCollectionViewLayoutAttributes.h
//  MJLayout
//
//  Created by chenminjie on 2020/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

// 此属性只是header会单独设置，其他均直接返回其frame属性
@property (nonatomic, assign, readonly) CGRect orginalFrame;

@end

NS_ASSUME_NONNULL_END
