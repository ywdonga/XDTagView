//
//  UIView+XDTag.h
//  XDTagViewDemo
//
//  Created by MAC on 2020/9/24.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XDTagSelectTypeNot,//无选择，只是点击
    XDTagSelectTypeSingle,//单选
    XDTagSelectTypeMultiple,//多选
} XDTagSelectType;

NS_ASSUME_NONNULL_BEGIN

@interface XDTagStyleModel : NSObject

/// 默认XDTagSelectTypeNot
@property(nonatomic, assign) XDTagSelectType selectType;
/* 标题字体 */
@property(nonatomic, strong) UIFont *titleFont;
/* 文字颜色 */
@property(nonatomic, strong) UIColor *titleColor;//文字颜色
@property(nonatomic, strong) UIColor *titleSelectColor;//选中文字颜色
/* 默认背景 */
@property(nonatomic, strong) UIColor *backColor;//背景颜色
@property(nonatomic, strong) UIColor *backSelectColor;//选中背景颜色
/* 边框 */
@property(nonatomic, strong) UIColor *borderColor;//边框颜色
@property(nonatomic, strong) UIColor *borderSelectColor;//选中变宽颜色
@property(nonatomic, assign) CGFloat borderWide;//边框宽度
@property(nonatomic, assign) CGFloat borderSelectWide;//选中变宽宽度
/* 圆角 */
@property(nonatomic, assign) BOOL round;//圆角为高度的一半
@property(nonatomic, assign) CGFloat cornerRadius;//自定义圆角 当round=NO时才生效
/* 边距 */
@property(nonatomic, assign) UIEdgeInsets itemPadding;//单个item的内边距
@property(nonatomic, assign) UIEdgeInsets parentPadding;//整个父视图的内边距
@property(nonatomic, assign) CGFloat letterSpacing;//左右间距
@property(nonatomic, assign) CGFloat lineSpacing;//上下间距

@end

@interface UIView (XDTag)

- (CGFloat)updateTagWithTitles:(nullable NSArray <NSString *>*)titles maxWidth:(CGFloat)maxWidth selectBack:(void(^)(NSArray<NSNumber *> *selectIndexs))selectBackBlock;
- (CGFloat)updateTagWithTitles:(nullable NSArray <NSString *>*)titles maxWidth:(CGFloat)maxWidth selectBack:(void(^)(NSArray<NSNumber *> *selectIndexs))selectBackBlock style:(nullable XDTagStyleModel *)style;

@end

NS_ASSUME_NONNULL_END
