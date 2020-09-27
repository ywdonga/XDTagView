//
//  UIView+XDTag.m
//  XDTagViewDemo
//
//  Created by MAC on 2020/9/24.
//

#import "UIView+XDTag.h"
#import <objc/runtime.h>

#define kButtonClickBlock @"kButtonClickBlock"
#define kStyleModel @"kStyleModel"

#define kButtonBackColor @"kButtonBackColor"
#define kButtonBackSelectColor @"kButtonBackSelectColor"

@implementation XDTagStyleModel

- (instancetype)init{
    self = [super init];
    if (self) {
        /// 默认XDTagSelectTypeNot
        self.selectType = XDTagSelectTypeMultiple;
        /* 标题字体 */
        self.titleFont = [UIFont systemFontOfSize:12];
        /* 文字颜色 */
        self.titleColor = UIColor.blackColor;//文字颜色
        self.titleSelectColor = UIColor.redColor;//选中文字颜色
        /* 默认背景 */
        self.backColor = UIColor.grayColor;//背景颜色
        self.backSelectColor = UIColor.blueColor;//选中背景颜色
        /* 边框 */
        self.borderColor = UIColor.blackColor;//边框颜色
        self.borderSelectColor = UIColor.redColor;//选中变宽颜色
        self.borderWide = 1.0;//边框宽度
        self.borderSelectWide = 1.0;//选中变宽宽度
        /* 圆角 */
        self.round = YES;//圆角为高度的一半
        self.cornerRadius = 5.0;//自定义圆角 当round=NO时才生效
        /* 边距 */
        self.itemPadding = UIEdgeInsetsMake(4, 10, 4, 10);//单个item的内边距
        self.parentPadding = UIEdgeInsetsMake(20, 20, 20, 20);//整个父视图的内边距
        self.letterSpacing = 5.0;//左右间距
        self.lineSpacing = 8.0;//上下间距
    }
    return self;
}

@end

@interface XDTagButton : UIButton

@property(nonatomic, strong) XDTagStyleModel *styleModel;//样式

@end

@implementation XDTagButton

+ (instancetype)creatWithStyle:(XDTagStyleModel *)styleModel{
    XDTagButton *tagButton = [self buttonWithType:UIButtonTypeCustom];
    tagButton.titleLabel.font = styleModel.titleFont;
    [tagButton setTitleColor:styleModel.titleColor forState:UIControlStateNormal];
    [tagButton setTitleColor:styleModel.titleSelectColor forState:UIControlStateSelected];
    tagButton.backgroundColor = styleModel.backColor;
    tagButton.layer.borderColor = styleModel.borderColor.CGColor;
    tagButton.layer.borderWidth = styleModel.borderWide;
    tagButton.contentEdgeInsets = styleModel.itemPadding;
    tagButton.layer.masksToBounds = YES;
    return tagButton;
}

- (void)drawRect:(CGRect)rect{
    self.layer.cornerRadius = self.styleModel.round?rect.size.height*0.5:self.styleModel.cornerRadius;
}

- (void)setSelected:(BOOL)selected{
    super.selected = selected;
    self.backgroundColor = selected?self.styleModel.backSelectColor:self.styleModel.backColor;
    self.layer.borderColor = selected?self.styleModel.borderSelectColor.CGColor:self.styleModel.borderColor.CGColor;
    self.layer.borderWidth = selected?self.styleModel.borderSelectWide:self.styleModel.borderWide;

}

- (void)setStyleModel:(XDTagStyleModel *)styleModel{
    objc_setAssociatedObject(self, kStyleModel, styleModel, OBJC_ASSOCIATION_RETAIN);
}

- (XDTagStyleModel *)styleModel{
    XDTagStyleModel *styleModel = objc_getAssociatedObject(self, kStyleModel);
    if(!styleModel){
        styleModel = [[XDTagStyleModel alloc] init];
    }
    return styleModel;
}

@end

@interface UIView (XDTag)

@property(nonatomic, copy) void(^tapBackBlock)(NSArray<NSNumber *> *selectIndexs);//item点击事件回调，多选时返回多个，单选时返回一个
@property(nonatomic, strong) XDTagStyleModel *styleModel;//样式

@end

@implementation UIView (XDTag)

- (CGFloat)updateTagWithTitles:(nullable NSArray <NSString *>*)titles maxWidth:(CGFloat)maxWidth selectBack:(void(^)(NSArray<NSNumber *> *selectIndexs))selectBackBlock{
    return [self updateTagWithTitles:titles maxWidth:maxWidth selectBack:selectBackBlock style:nil];
}

- (CGFloat)updateTagWithTitles:(nullable NSArray <NSString *>*)titles maxWidth:(CGFloat)maxWidth selectBack:(void(^)(NSArray<NSNumber *> *selectIndexs))selectBackBlock style:(nullable XDTagStyleModel *)style{
    self.tapBackBlock = [selectBackBlock copy];
    XDTagStyleModel *styleModel = style?:self.styleModel;
    maxWidth = maxWidth-styleModel.parentPadding.left-styleModel.parentPadding.right;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[XDTagButton class]]){
            [obj removeFromSuperview];
        }
    }];
    if(!titles.count) return 0;
    __block UIView *lastView = nil;
    __weak __typeof(self)weakSelf = self;
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [XDTagButton creatWithStyle:styleModel];
        [button addTarget:weakSelf action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:obj forState:UIControlStateNormal];
        button.tag = idx;
        [button sizeToFit];
        CGFloat lastX, lastY;
        if(!lastView){
            lastX = styleModel.parentPadding.left;
            lastY = styleModel.parentPadding.top;
        }else if ((CGRectGetMaxX(lastView.frame) + styleModel.letterSpacing + button.frame.size.width) <= maxWidth){
            lastX = CGRectGetMaxX(lastView.frame)+styleModel.letterSpacing;
            lastY = lastView.frame.origin.y;
        }else{
            lastX = styleModel.parentPadding.left;
            lastY = CGRectGetMaxY(lastView.frame) + styleModel.lineSpacing;
        }
        button.frame = CGRectMake(lastX, lastY, MIN(maxWidth, button.frame.size.width), button.frame.size.height);
        [weakSelf addSubview:button];
        lastView = button;
    }];
    return CGRectGetMaxY(lastView.frame)+styleModel.parentPadding.bottom;
}

- (void)tagButtonClick:(XDTagButton *)button{
    if(self.styleModel.selectType == XDTagSelectTypeSingle){
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[XDTagButton class]]){
                XDTagButton *tagButton = (XDTagButton *)obj;
                tagButton.selected = NO;
            }
        }];
        button.selected = YES;
        !self.tapBackBlock?:self.tapBackBlock(@[@(button.tag)]);
    }else if (self.styleModel.selectType == XDTagSelectTypeMultiple){
        button.selected = !button.selected;
        NSMutableArray<NSNumber *> *selectTags = [NSMutableArray array];
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[XDTagButton class]]){
                XDTagButton *tagButton = (XDTagButton *)obj;
                if(tagButton.selected){
                    [selectTags addObject:@(tagButton.tag)];
                }
            }
        }];
        !self.tapBackBlock?:self.tapBackBlock(selectTags);
    }else{
        !self.tapBackBlock?:self.tapBackBlock(@[@(button.tag)]);
    }
}

- (void)setTapBackBlock:(void (^)(NSArray<NSNumber *> *selectIndexs))tapBackBlock{
    objc_setAssociatedObject(self, kButtonClickBlock, tapBackBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(NSArray<NSNumber *> *selectIndexs))tapBackBlock{
    return objc_getAssociatedObject(self, kButtonClickBlock);
}

- (void)setStyleModel:(XDTagStyleModel *)styleModel{
    objc_setAssociatedObject(self, kStyleModel, styleModel, OBJC_ASSOCIATION_RETAIN);
}

- (XDTagStyleModel *)styleModel{
    XDTagStyleModel *styleModel = objc_getAssociatedObject(self, kStyleModel);
    if(!styleModel){
        styleModel = [[XDTagStyleModel alloc] init];
    }
    return styleModel;
}

@end
