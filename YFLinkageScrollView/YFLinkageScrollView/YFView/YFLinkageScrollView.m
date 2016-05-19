//
//  YFLinkageScrollView.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/4/8.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "YFLinkageScrollView.h"
#import "UIColor+GetColor.h"

@interface YFLinkageScrollView ()<UIScrollViewDelegate>

#pragma mark - *************************** Property ***************************
#pragma mark  布局
/** tag数组, 改变标题数组 */
@property (nonatomic, strong) NSMutableArray *tagArr;
/** tagItem缩放比 */
@property (nonatomic, assign) CGFloat tagScale;
/** 存储tagTitle的字体属性 */
@property (nonatomic, strong) NSMutableArray *tagItemWidthArr;
/** 屏幕显示几个tagItem */
@property (nonatomic, assign) CGFloat tagVisibleCount;
/** 横屏显示几个tagItem */
@property (nonatomic, assign) CGFloat tagHorVisibleCount;
/** 竖屏显示几个tagItem */
@property (nonatomic, assign) CGFloat tagVerVisibleCount;
/** tag内嵌 */
@property (nonatomic, assign) UIEdgeInsets tagEdge;
/** YFTagScroll 返回的 tagItem宽度 */
@property (nonatomic, assign) float tagItemWidth;
/** YFTagScroll 返回的 是否自定义宽度, 固定不变 */
@property (nonatomic, assign) BOOL isCustomWidth;

/** 滑块contain, 如果是独立的 */
@property (nonatomic, strong) UIScrollView *sliderScroll;
/** 自定义slider */
@property (nonatomic, strong) UIView *customSlider;
/** 自定义sliderFrame */
@property (nonatomic, assign) CGRect customFrame;
/** 滑块容器, 有必要的话之前拉.h, 用于控制最宽masksToBounds */
@property (nonatomic, strong) YFSliderView *sliderView;
/** 滑块类型 */
@property (nonatomic, assign) YFSliderType sliderType;

/** 内容 */
@property (nonatomic, strong) NSMutableArray *ctItemArr;
/** currentIndex */
@property (nonatomic, assign) NSInteger currentIndex;

#pragma mark  记录

/** 旋转前的frame */
@property (nonatomic, assign) CGRect lastFrame;
/** 滑动时的上一个点 */
@property (nonatomic, assign) CGPoint lastPoint;
/** 滑动时的上一个按钮 */
@property (nonatomic, strong) UIButton *lastBtn;
/** 滑动时的下一个按钮 */
@property (nonatomic, strong) UIButton *nextBtn;

/** setCurrentIndex 直接跳转 */
@property (nonatomic, assign) BOOL isJump;
@property (nonatomic, assign) BOOL isRotate;
@property (nonatomic, assign) BOOL ctScrollAnim;
@property (nonatomic, assign) BOOL tagScrollAnim;
@property (nonatomic, assign) int moveCount;

#pragma mark  数据
/** tagItemNorlColorNormal */
@property (nonatomic, strong) UIColor *tagColorNor;
/** tagItemNorlColorSelect */
@property (nonatomic, strong) UIColor *tagColorSelect;
/** 每个标签x之间,每点所变化的R颜色值 */
@property (nonatomic, assign) CGFloat colorRedScale;
/** 每个标签x之间,每点所变化的G颜色值 */
@property (nonatomic, assign) CGFloat colorGreenScale;
/** 每个标签x之间,每点所变化的B颜色值 */
@property (nonatomic, assign) CGFloat colorBlueScale;
/** 每个标签x之间,每点所变化的A颜色值 */
@property (nonatomic, assign) CGFloat colorAlphaScale;
/** 每个标签x之间,每点所变化的按钮缩放 */
@property (nonatomic, assign) CGFloat btnScale;
/** 每个标签x之间,每点所变化的tagItem长度*/
@property (nonatomic, assign) CGFloat moveTagItemWidth;

@end
@implementation YFLinkageScrollView

#pragma mark - *************************** Property ***************************
- (void)setSliderWidthScale:(CGFloat)sliderWidthScale
{
    if (self.sliderWidthScale > 0 && self.sliderView) {
        self.sliderView.sliderWidth = self.sliderView.sliderWidth / (self.tagScale + self.sliderWidthScale) * (self.tagScale + sliderWidthScale);
        _sliderWidthScale = sliderWidthScale;
    }
}

- (void)setSliderColor:(UIColor *)sliderColor
{
    _sliderColor = sliderColor;
    self.sliderScroll.backgroundColor = sliderColor;
}

- (void)setDelegate:(id<YFLinkageScrollViewDelegate>)delegate
{
    _delegate = delegate;
    if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
        [self.delegate yfScrollViewChangeCurrentIndex:0 item:self.ctItemArr[0]];
    }
}

- (void)setRotateVisibleCount:(CGFloat)rotateVisibleCount
{
    _rotateVisibleCount     = rotateVisibleCount;
    self.tagHorVisibleCount = rotateVisibleCount;
    if (self.tagHorVisibleCount > self.tagArr.count)
        self.tagHorVisibleCount = self.tagArr.count;
}

- (YFTagScroll *)tagScroll
{
    if (!_tagScroll) {
        _tagScroll     = [[YFTagScroll alloc] init];
        self.lastFrame = CGRectZero;
    }
    return _tagScroll;
}

#pragma mark - *************************** Observe ***************************
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[YFContentScroll class]]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            NSNumber *value = change[@"new"];
            CGPoint offset  = value.CGPointValue;
            float index     = (offset.x / self.ctScroll.frame.size.width);
            static int idx  = 0;
            if (index == (int)index && idx != (int)index) {
                if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
                    [self.delegate yfScrollViewChangeCurrentIndex:self.currentIndex item:self.ctItemArr[self.currentIndex]];
                }
                idx = (int)index;
            }
        }
    }
}

#pragma mark - **************************** Layout ****************************
- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect rect = CGRectMake(0, 0, self.frame.size.width, 40);
    if (CGRectEqualToRect(rect, self.lastFrame)) return;

    // 方向
    UIInterfaceOrientation status = [UIApplication sharedApplication].statusBarOrientation;
    if (status == UIInterfaceOrientationPortrait) {
        self.tagVisibleCount = self.tagVerVisibleCount;
    }else if (status == UIInterfaceOrientationLandscapeLeft || status == UIInterfaceOrientationLandscapeRight) {
        self.tagVisibleCount = self.tagHorVisibleCount;
    }

    self.tagItemWidth           = rect.size.width / self.tagVisibleCount;
    self.tagScroll.tagItemWidth = self.tagItemWidth;
    self.tagScroll.currentIdx   = self.currentIndex;
    self.tagScroll.frame        = rect;
    self.lastFrame              = rect;
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.tagEdge)) {
        [self changTagFrame:self.tagEdge];
    }

    if (self.sliderType != YFSliderTypeNone){   // 滑块
        if (self.sliderView) {
            [self.sliderView removeFromSuperview];
            self.sliderView = nil;
        }
        [self configSliderWithType:self.sliderType slierView:self.customSlider];
    }

    CGRect ctFrame = CGRectMake(0,
                                CGRectGetMaxY(self.sliderScroll ? self.sliderScroll.frame : self.tagScroll.frame),
                                self.frame.size.width,
                                self.frame.size.height-CGRectGetMaxY(self.sliderScroll ? self.sliderScroll.frame : self.tagScroll.frame));
    self.ctScroll.frame = ctFrame;
    self.isRotate       = YES;
    [self setCurrentIndex:self.currentIndex animated:NO TagAnimated:NO];
}

#pragma mark - ***************************** Init *****************************

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (CGRectEqualToRect(self.tagScroll.frame, CGRectZero))
            self.tagScroll.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    }
    return self;
}

- (void)configWithScrolltagArray:(NSArray *)tagArr
                    visibleCount:(float)visibleCount
                      sliderType:(YFSliderType)type
               contentScrollItem:(NSArray *)contentArr
{
    [self configWithScrolltagArray:tagArr tagScrollEdgeInset:UIEdgeInsetsZero tagScale:1.2 configTagItemBlock:nil visibleCount:visibleCount sliderType:type customSlider:nil contentScrollItem:contentArr];
}

- (void)configWithScrolltagArray:(NSArray *)tagArr
              tagScrollEdgeInset:(UIEdgeInsets)tagEdge
                        tagScale:(CGFloat)tagScale
              configTagItemBlock:(YFTagItemConfigration)block
                    visibleCount:(float)visibleCount
                      sliderType:(YFSliderType)type
                    customSlider:(UIView *)customSlider
               contentScrollItem:(NSArray *)contentArr
{
    self.sliderColor      = [UIColor clearColor];
    self.tagEdge          = tagEdge;

    self.animDuration     = 0.5;
    self.sliderWidthScale = 0.1;

    self.tagArr = [NSMutableArray arrayWithArray:tagArr];
    self.sliderType                     = type;
    self.tagVisibleCount                = visibleCount;
    self.tagVerVisibleCount             = visibleCount;
    self.tagHorVisibleCount             = visibleCount*2;
    if (self.tagHorVisibleCount > self.tagArr.count)
        self.tagHorVisibleCount = self.tagArr.count;

    self.tagItemWidth           = self.tagScroll.frame.size.width / self.tagVisibleCount;
    self.tagScroll.tagItemWidth = self.tagItemWidth;
    self.tagScale               = tagScale;
    self.tagScroll.tagScale     = tagScale;

    [self configTagData]; // 取色

    NSArray *tagItemWidthArr = [self.tagScroll configTagArray:tagArr tagScale:tagScale configTagItemBlock:block];
    self.tagItemWidthArr     = [NSMutableArray arrayWithArray:tagItemWidthArr];
    [self addSubview:self.tagScroll];

    [self configNormal];    // 默认
    [self configTagAction]; // 标签

    if (type != YFSliderTypeNone) {
        self.sliderType = type;
        if (customSlider) {
            self.customSlider = customSlider;
            self.customFrame  = self.customSlider.frame;
        }
    }
    self.ctItemArr = [NSMutableArray arrayWithArray:contentArr];
    [self configContentScroll:contentArr];
}

#pragma mark - **************************** setup *****************************
- (void)changTagFrame:(UIEdgeInsets)tagScrollEdge
{
    CGRect rect      = self.tagScroll.frame;
    rect.origin.x    += ABS(tagScrollEdge.left);
    rect.origin.y    += ABS(tagScrollEdge.top);
    rect.size.width  -= ABS(tagScrollEdge.left)+ABS(tagScrollEdge.right);
    rect.size.height += tagScrollEdge.bottom;

    // 对应的width也要改变(contentSize, slider位置)
    self.tagScroll.tagItemWidth = rect.size.width / self.tagVisibleCount;
    self.tagItemWidth           = rect.size.width / self.tagVisibleCount;
    self.tagScroll.frame        = rect;
}

- (void)configNormal
{
    self.tagScrollAnim = YES;
    self.ctScrollAnim  = YES;
}

- (void)configTagData
{
    __weak typeof(self) weakSelf = self;
    self.tagScroll.infoBlock = ^(UIColor *tagColorNor, UIColor *tagColorSelect) {

        weakSelf.tagColorNor     = tagColorNor;
        weakSelf.tagColorSelect  = tagColorSelect;
        weakSelf.colorRedScale   = ([tagColorSelect red]-[tagColorNor red])     / weakSelf.tagItemWidth;
        weakSelf.colorBlueScale  = ([tagColorSelect blue]-[tagColorNor blue])   / weakSelf.tagItemWidth;
        weakSelf.colorGreenScale = ([tagColorSelect green]-[tagColorNor green]) / weakSelf.tagItemWidth;
        weakSelf.colorAlphaScale = ([tagColorSelect alpha]-[tagColorNor alpha]) / weakSelf.tagItemWidth;
        weakSelf.btnScale        = (weakSelf.tagScale - 1.0) / weakSelf.tagItemWidth;
    };
}


- (void)configSliderWithType:(YFSliderType)type slierView:(UIView *)customSlider
{
    UIButton *btn = [self viewWithTag:kTagPadding];
    CGSize size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.tagScroll.frame.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font} context:nil].size;
    self.sliderView = [[YFSliderView alloc] initWithType:type
                                        containWidth:self.tagItemWidth
                                           tagHeight:4
                                       containHeight:(self.sliderType == YFSliderTypeBottomAlone) ? customSlider ? customSlider.frame.size.height : 4 : self.tagScroll.frame.size.height
                                           andSlider:customSlider scale:self.tagScale
                                         customFrame:self.customFrame];
    if (self.sliderType == YFSliderTypeBottomAlone) {
        if (self.sliderScroll) {
            [self.sliderScroll removeFromSuperview];
            self.sliderScroll = nil;
        }
        self.sliderScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tagScroll.frame.origin.x,
                                                                       CGRectGetMaxY(self.tagScroll.frame),
                                                                       self.tagScroll.frame.size.width,
                                                                       customSlider ? customSlider.frame.size.height : 4)];
        [self addSubview:self.sliderScroll];
        self.sliderScroll.contentSize     = self.tagScroll.contentSize;
        self.sliderScroll.backgroundColor = self.sliderColor;
        self.sliderScroll.showsVerticalScrollIndicator   = NO;
        self.sliderScroll.showsHorizontalScrollIndicator = NO;
        self.sliderScroll.userInteractionEnabled         = NO;
        [self.sliderScroll addSubview:self.sliderView];

    }else {
        [self.tagScroll addSubview:self.sliderView];
    }
    self.isCustomWidth = self.sliderView.isCustomWidth;
    if (!self.isCustomWidth) {
        self.sliderView.sliderWidth = size.width*(self.tagScale+self.sliderWidthScale);
    }
}

- (void)configContentScroll:(NSArray *)itemArr
{
    if (self.ctScroll || self.tagArr.count != itemArr.count) return;

    self.ctScroll = [[YFContentScroll alloc] init];
    [self.ctScroll configItemArr:itemArr];
    self.ctScroll.delegate = self;

    [self addSubview:self.ctScroll];
    [self.ctScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - **************************** Action ****************************
- (void)configTagAction
{
    __weak typeof(self) weakSelf = self;
    self.tagScroll.delegate = self;
    self.tagScroll.tagSelectBlock = ^(UIButton *btn, NSInteger idx) {

        UIButton *lastBtn     = (UIButton *)[weakSelf viewWithTag:weakSelf.currentIndex+kTagPadding];

        weakSelf.currentIndex = (int)(btn.tag-kTagPadding);

        weakSelf.lastPoint    = CGPointMake(weakSelf.currentIndex*weakSelf.ctScroll.frame.size.width, 0);

        [UIView animateWithDuration:weakSelf.animDuration animations:^{
            if ( !weakSelf.isCustomWidth && weakSelf.sliderView) {
                weakSelf.sliderView.sliderWidth = [weakSelf.tagItemWidthArr[weakSelf.currentIndex] floatValue] * (weakSelf.tagScale+weakSelf.sliderWidthScale);
            }
            [lastBtn setTitleColor:weakSelf.tagColorNor forState:UIControlStateNormal];
            lastBtn.transform = CGAffineTransformIdentity;
            [btn setTitleColor:weakSelf.tagColorSelect forState:UIControlStateNormal];
            btn.transform = CGAffineTransformMakeScale(weakSelf.tagScale, weakSelf.tagScale);
        }];

        // tag
        [weakSelf tagScrollMove];
        // slider
        if (weakSelf.sliderView) {
            [UIView animateWithDuration:weakSelf.animDuration animations:^{
                weakSelf.sliderView.transform = CGAffineTransformMakeTranslation(weakSelf.currentIndex*weakSelf.tagItemWidth, 0);
            }];
        }
        // ctScroll
        [weakSelf.ctScroll setContentOffset:CGPointMake(weakSelf.ctScroll.frame.size.width*weakSelf.currentIndex, 0) animated:NO];
    };
}

#pragma mark - ***************************** CRUD *****************************

/**
 *  对应的属性改变
 *  增加新的item, 改变contentSize
 */
- (void)addTagTitle:(NSString *)title contentItem:(id)item
{
    if (!title || !item) return;

    [self.tagArr addObject:title];
    [self.ctItemArr addObject:item];

    NSNumber *num = [self.tagScroll addTitle:title];
    [self.tagItemWidthArr addObject:num];

    if (self.sliderScroll)
        self.sliderScroll.contentSize = self.tagScroll.contentSize;

    [self.ctScroll addContent:item];
}
/**
 *  插入会设置为移动到新插入的位置
 */
- (void)addTagTitle:(NSString *)title contentItem:(id)item atIndex:(NSInteger)index
{
    if (!title || !item || self.tagArr.count < index) return;
    [self.tagArr insertObject:title atIndex:index];
    [self.ctItemArr insertObject:item atIndex:index];

    UIButton *btn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];
    [btn setTitleColor:self.tagColorNor forState:UIControlStateNormal];
    btn.transform = CGAffineTransformIdentity;

    NSNumber *num = [self.tagScroll addTitle:title atIndex:index];
    [self.tagItemWidthArr insertObject:num atIndex:index];

    if (self.sliderScroll)
        self.sliderScroll.contentSize = self.tagScroll.contentSize;

    [self.ctScroll addContent:item atIndex:index];

    if (index == self.currentIndex) { // 没有改变位置,手动调
        if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
            [self.delegate yfScrollViewChangeCurrentIndex:index item:self.ctItemArr[index]];
        }
    }
    self.isRotate = YES;
    [self setCurrentIndex:index animated:NO TagAnimated:NO];
}

/**
 *  删除
 *  当前个数为1个是不删除,
 *  总个数少于屏幕显示个数时不应该重新布局, 那样的话再增加不好弄屏幕该显示几个,需要记录,不变还能提醒用户可添加
 *  删除后跳转之前的选择项, 如果删除的是当前跳0
 *  自己控制渐变的效果, .h 属性 animDuration 可以设置0,没有渐变, 再改成def 0.5
 */
- (void)removeContentAtIndex:(NSInteger)index
{
    if (index >= self.tagArr.count || self.tagArr.count < 2 || index < 0) return;

    NSInteger idx = self.currentIndex;  // 防止contentSize改变而调用代理, 使self.currentIndex改变, contentSize默认为0时,改变时不会调用代理
    
    [self.tagArr removeObjectAtIndex:index];
    [self.ctItemArr removeObjectAtIndex:index];
    [self.tagItemWidthArr removeObjectAtIndex:index];
    
    [self.tagScroll removeItemAtIndex:index];

    if (self.sliderScroll)
        self.sliderScroll.contentSize = self.tagScroll.contentSize;
    
    [self.ctScroll removeItemAtIndex:index];

    // 调整位置
    self.isRotate = YES;
    if (index == idx) {
        [self setCurrentIndex:0 animated:NO TagAnimated:NO];
    }else if (index < idx) {
        [self setCurrentIndex:idx-1 animated:NO TagAnimated:NO];
    }
}

/**
 *  多删
 *
 *  ( 不想枚举判断了(浪费),传字符串,负数自己负责,如果可以直接报错的限制方法,请issue我 )
 */
- (void)removeContentAtIndexs:(NSArray<NSNumber *> *)indexs
{
    NSInteger index = self.currentIndex;
    UIButton *btn = (UIButton *)[self viewWithTag:kTagPadding+index];
    BOOL isHas = NO;

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < indexs.count; i++) {
        NSInteger idx = [indexs[i] unsignedIntegerValue];
        if (index == idx) {
            isHas = YES;
        }
        [indexSet addIndex:idx];
    }

    [self.tagArr removeObjectsAtIndexes:indexSet];
    [self.ctItemArr removeObjectsAtIndexes:indexSet];
    [self.tagItemWidthArr removeObjectsAtIndexes:indexSet];

    [self.tagScroll removeItemAtIndexs:indexs];
    if (self.sliderScroll)
        self.sliderScroll.contentSize = self.tagScroll.contentSize;
    [self.ctScroll removeItemAtIndexs:indexs];

    // 调整位置, 原来的位置
    self.isRotate = YES;
    if (isHas) {
        [self setCurrentIndex:0 animated:NO TagAnimated:NO];
    }else {
        [self setCurrentIndex:btn.tag-kTagPadding animated:NO TagAnimated:NO];
    }
}

/**
 *  交换
 *  交换后currentIndex移动到之前对应的标签
 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2
{
    if (index1 == index2 || self.tagArr.count <= index1 || self.tagArr.count <= index2) return;

    [self.tagArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [self.ctItemArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [self.tagItemWidthArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];

    [self.tagScroll exchangeAtIndex:index1 withIndex:index2];
    [self.ctScroll exchangeAtIndex:index1 withIndex:index2];

    if (self.currentIndex == index1) {
        [self setCurrentIndex:index2 animated:NO TagAnimated:NO];
    }else if (self.currentIndex == index2) {
        [self setCurrentIndex:index1 animated:NO TagAnimated:NO];
    }
}

/**
 *  更新数据源
 *
 *  如果之前的标签内容存在, 移动到之前的, 不存在移动到0
 */
- (void)updateTagArr:(NSMutableArray *)tagArr contentArr:(NSMutableArray *)contentArr
{
    if (tagArr.count != contentArr.count || self.ctItemArr == contentArr || tagArr.count == 0 || !tagArr) return;

    NSString *str = self.tagArr[self.currentIndex];

    self.tagArr    = [NSMutableArray arrayWithArray:tagArr];
    self.ctItemArr = [NSMutableArray arrayWithArray:contentArr];

    self.tagItemWidthArr = [self.tagScroll updataTagArr:tagArr];
    if (self.sliderScroll)
        self.sliderScroll.contentSize = self.tagScroll.contentSize;
    [self.ctScroll updataContentItem:contentArr];

    self.isRotate = YES;
    if ([self.tagArr containsObject:str])
        [self setCurrentIndex:[self.tagArr indexOfObject:str] animated:NO TagAnimated:NO];
    else
        [self setCurrentIndex:0 animated:NO TagAnimated:NO];

}


#pragma mark - ********************* ScrollView Delegate **********************

// 实时响应
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.sliderScroll) {
        self.sliderScroll.contentOffset = self.tagScroll.contentOffset;
    }
    if (scrollView == self.ctScroll) {
        CGPoint point = scrollView.contentOffset;

        // 代理
        if (point.x < 0)
            [self yfScrollViewOutOfVaule:point.x];
        else if (point.x > (scrollView.contentSize.width-scrollView.frame.size.width))
            [self yfScrollViewOutOfVaule:point.x-(scrollView.contentSize.width-scrollView.frame.size.width)];

        if (self.isJump) return;

        if (!self.isJump) {
            self.currentIndex = (int)(point.x / self.ctScroll.frame.size.width);
        }
        CGFloat tagPotX = point.x / self.ctScroll.contentSize.width * self.tagScroll.contentSize.width;

        // bug点 左滑
        if (self.ctScroll.contentOffset.x == self.currentIndex*self.ctScroll.frame.size.width) return;

        if (point.x >= 0 && point.x <= (self.tagArr.count-1)*self.ctScroll.frame.size.width) {

            UIButton *currentBtn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];

            // slider
            if (self.sliderView) {
                self.sliderView.transform = CGAffineTransformMakeTranslation(tagPotX, 0);
            }
            float movePadding = 0;
            if (point.x >= self.lastPoint.x) {  // 左滑
                self.lastBtn = currentBtn;
                self.nextBtn = (UIButton *)[self viewWithTag:currentBtn.tag+1];
                if (self.currentIndex <= self.tagItemWidthArr.count-2) {
                    movePadding = ([self.tagItemWidthArr[self.currentIndex+1] floatValue] - [self.tagItemWidthArr[self.currentIndex] floatValue]) / self.tagItemWidth;
                }
            }else {                         // 右滑
                self.nextBtn = currentBtn;
                self.lastBtn = (UIButton *)[self viewWithTag:currentBtn.tag+1];
                if (self.currentIndex <= self.tagItemWidthArr.count-2) {
                    movePadding = ([self.tagItemWidthArr[self.currentIndex] floatValue] - [self.tagItemWidthArr[self.currentIndex+1] floatValue]) / self.tagItemWidth;
                }
            }

            // slider  tagScroll上的offSet变化 * item每个点所的变化 * 缩放
            if (self.currentIndex <= self.tagItemWidthArr.count-2 && [self.tagItemWidthArr[self.currentIndex] floatValue] != [self.tagItemWidthArr[self.currentIndex+1] floatValue] && !self.isCustomWidth ) {

                self.sliderView.sliderWidth += movePadding * ABS(point.x/self.ctScroll.contentSize.width * self.tagScroll.contentSize.width -self.lastPoint.x/ self.ctScroll.contentSize.width * self.tagScroll.contentSize.width) * (self.tagScale+self.sliderWidthScale);
            }

            self.lastPoint = point;
            
            // 按钮  tagScroll上的offSet变化 * item每个点所的变化 * 缩放
            // 缩放前的originX
            CGFloat originX = (self.lastBtn.tag-kTagPadding)*self.tagItemWidth;

            if (self.lastBtn && !self.isJump) {
                self.lastBtn.transform = CGAffineTransformMakeScale(self.tagScale-ABS(tagPotX-originX)*self.btnScale, self.tagScale-ABS(tagPotX-originX)*self.btnScale);

                UIColor *color = [UIColor colorWithRed:[self.tagColorSelect red]   - ABS(tagPotX-originX)*self.colorRedScale
                                                 green:[self.tagColorSelect green] - ABS(tagPotX-originX)*self.colorGreenScale
                                                  blue:[self.tagColorSelect blue]  - ABS(tagPotX-originX)*self.colorBlueScale
                                                 alpha:[self.tagColorSelect alpha] - ABS(tagPotX-originX)*self.colorAlphaScale];
                [self.lastBtn setTitleColor:color forState:UIControlStateNormal];
            }

            if (self.nextBtn && !self.isJump) {

                self.nextBtn.transform = CGAffineTransformMakeScale(1.0+ABS(tagPotX-originX)*self.btnScale, 1.0+ABS(tagPotX-originX)*self.btnScale);

                UIColor *color = [UIColor colorWithRed:[self.tagColorNor red]   + ABS(tagPotX-originX)*self.colorRedScale
                                                 green:[self.tagColorNor green] + ABS(tagPotX-originX)*self.colorGreenScale
                                                  blue:[self.tagColorNor blue]  + ABS(tagPotX-originX)*self.colorBlueScale
                                                 alpha:[self.tagColorNor alpha] + ABS(tagPotX-originX)*self.colorAlphaScale];
                [self.nextBtn setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
}

// 动画结束, 移动scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.tagArr.count <= self.tagVisibleCount ) return;
    if ( scrollView == self.ctScroll ) {
        [self tagScrollMove];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    static int a = 0;
    if (self.isJump && [scrollView isKindOfClass:[YFContentScroll class]]) {
        a++;
        if (a == self.moveCount) {
            self.isJump = NO;
            a = 0;
            self.moveCount = 1;
        }
    }
}

#pragma mark - ***************************** move *****************************

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated TagAnimated:(BOOL)tagAnimated
{
    if (self.currentIndex == currentIndex && !self.isRotate) return;
    self.isRotate = NO;

    if (self.isJump) return;

    self.ctScrollAnim  = animated;
    self.tagScrollAnim = tagAnimated;

    UIButton *btn = [self viewWithTag:self.currentIndex+kTagPadding];

    self.currentIndex = currentIndex;

    self.isJump = YES;

    UIButton *destBtn = [self viewWithTag:self.currentIndex+kTagPadding];

    [UIView animateWithDuration:self.animDuration animations:^{
        if (!self.isCustomWidth) {
            self.sliderView.sliderWidth = [self.tagItemWidthArr[self.currentIndex] floatValue] * (self.tagScale+self.sliderWidthScale);
        }
        btn.transform = CGAffineTransformIdentity;
        [btn setTitleColor:self.tagColorNor forState:UIControlStateNormal];
        destBtn.transform = CGAffineTransformMakeScale(self.tagScale, self.tagScale);
        [destBtn setTitleColor:self.tagColorSelect forState:UIControlStateNormal];
    }];
    /* animated YES, 调用代理EndAnima 1次, 调用DidScroll 18次;
     NO,  调用代理EndAnima 0次, 调用DidScroll 1 次;
     如果tag移动的目标区域在当前显示的地方 不调用 EndAnima
     边切几十次后 会造成 self.isJump 不能被初始成NO
     */
    if (animated) {
        self.moveCount = 1;
    }
    if ((!animated && !tagAnimated) || !animated) {
        self.moveCount = 1;
        self.isJump    = NO;
    }
    self.lastPoint = CGPointMake(self.currentIndex*self.ctScroll.frame.size.width, 0);

    [self configNormal];

    if (self.tagArr.count > self.tagVisibleCount ) {
        [self tagScrollMove];
    };

    if (self.sliderView) {
        [UIView animateWithDuration:self.animDuration animations:^{
            self.sliderView.transform = CGAffineTransformMakeTranslation(self.currentIndex*self.tagItemWidth, 0);
        }];
    }
    [self.ctScroll setContentOffset:CGPointMake(self.ctScroll.frame.size.width*currentIndex, 0) animated:animated];
}

/**
 *  tag是否自动移动到中间
 *
 *  @param idx 当前被选中的tagItem Index
 *
 *  @return Yes 需要
 */
- (BOOL)isNeedAutoScroll
{
    /* 左边的按钮一半宽能显示几个且最后一个过半也算就是几个不用移中
     * 右边同样,过半的不用移
     */
    int num = self.tagVisibleCount / 2 - 0.5;
    if (self.currentIndex > num && self.currentIndex < self.tagArr.count-1-num)
        return YES;
    else
        return NO;
}

- (void)tagScrollMove
{
    // 如果tagVisibleCount不会整数,整体画面是右边多出来
    if (self.isMoveToVisible) {
        float padding = self.tagVisibleCount - (int)self.tagVisibleCount;
        UIButton *btn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];
        UIButton *nextBtn;
        if (self.currentIndex+1 <= self.tagArr.count-1) {
            nextBtn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding+1];
        }
        CGRect frame = btn.frame;
        if (padding > 0) {
            if (nextBtn)
                frame.size.width -= CGRectGetMaxX(frame)-nextBtn.frame.origin.x;
            frame.size.width += padding*self.tagItemWidth;
        }
        [self.tagScroll scrollRectToVisible:frame animated:self.tagScrollAnim];

    }else {
        BOOL isNeed = [self isNeedAutoScroll];
        if (isNeed)                                         // 移中
            [self.tagScroll setContentOffset:CGPointMake(self.currentIndex*self.tagItemWidth+self.tagItemWidth/2-self.tagScroll.frame.size.width/2, 0) animated:self.tagScrollAnim];
        else if (self.currentIndex <= self.tagVisibleCount/2)   // 移zero
            [self.tagScroll setContentOffset:CGPointZero animated:self.tagScrollAnim];
        else                                                // 移最右
            [self.tagScroll setContentOffset:CGPointMake(self.tagScroll.contentSize.width-self.tagScroll.frame.size.width, 0) animated:self.tagScrollAnim];
    }
}

#pragma mark - ***************** YFLinkageScrollViewDelegate ******************
- (void)yfScrollViewOutOfVaule:(CGFloat)offset
{
    if (offset < 0) {
        if ([self.delegate respondsToSelector:@selector(yfScrollViewOutOfLeft:)]) {
            [self.delegate yfScrollViewOutOfLeft:-offset];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(yfScrollViewOutOfRight:)]) {
            [self.delegate yfScrollViewOutOfRight:offset];
        }
    }
}

- (void)dealloc
{
    if (self.ctScroll) {
        [self.ctScroll removeObserver:self forKeyPath:@"contentOffset"];
        self.ctScroll = nil;
    }
}

@end
