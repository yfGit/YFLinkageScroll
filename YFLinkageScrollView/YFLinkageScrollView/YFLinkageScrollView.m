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
/** 滑块 */
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
    if (_sliderWidthScale > 0 && _sliderView) {
        _sliderView.sliderWidth = _sliderView.sliderWidth / (_tagScale + _sliderWidthScale) * (_tagScale + sliderWidthScale);
        _sliderWidthScale = sliderWidthScale;
    }
}

- (void)setSliderColor:(UIColor *)sliderColor
{
    _sliderColor = sliderColor;
    _sliderScroll.backgroundColor = sliderColor;
}

- (void)setDelegate:(id<YFLinkageScrollViewDelegate>)delegate
{
    _delegate = delegate;
    if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
        [self.delegate yfScrollViewChangeCurrentIndex:0 item:_ctItemArr[0]];
    }
}

- (void)setRotateVisibleCount:(CGFloat)rotateVisibleCount
{
    _rotateVisibleCount = rotateVisibleCount;
    _tagHorVisibleCount = rotateVisibleCount;
    if (_tagHorVisibleCount > _tagArr.count)
        _tagHorVisibleCount = _tagArr.count;
}

- (YFTagScroll *)tagScroll
{
    if (!_tagScroll) {
        _tagScroll = [[YFTagScroll alloc] init];
        _lastFrame = CGRectZero;
    }
    return _tagScroll;
}

#pragma mark - *************************** Observe ***************************
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[YFContentScroll class]]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            NSNumber *value = change[@"new"];
            CGPoint offset = value.CGPointValue;
            float index = (offset.x / _ctScroll.frame.size.width);
            static int idx = 0;
            if (index == (int)index && idx != (int)index) {
                if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
                    [self.delegate yfScrollViewChangeCurrentIndex:self.currentIndex item:_ctItemArr[self.currentIndex]];
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
    if (CGRectEqualToRect(rect, _lastFrame)) return;

    // 方向
    UIInterfaceOrientation status = [UIApplication sharedApplication].statusBarOrientation;
    if (status == UIInterfaceOrientationPortrait) {
        _tagVisibleCount = _tagVerVisibleCount;
    }else if (status == UIInterfaceOrientationLandscapeLeft || status == UIInterfaceOrientationLandscapeRight) {
        _tagVisibleCount = _tagHorVisibleCount;
    }

    _tagItemWidth               = rect.size.width / _tagVisibleCount;
    self.tagScroll.tagItemWidth = _tagItemWidth;
    self.tagScroll.currentIdx   = self.currentIndex;
    self.tagScroll.frame        = rect;
    _lastFrame                  = rect;
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _tagEdge)) {
        [self changTagFrame:_tagEdge];
    }

    if (_sliderType != YFSliderTypeNone){   // 滑块
        if (_sliderView) {
            [_sliderView removeFromSuperview];
            _sliderView = nil;
        }
        [self configSliderWithType:_sliderType slierView:_customSlider];
    }

    CGRect ctFrame = CGRectMake(0,
                                CGRectGetMaxY(_sliderScroll ? _sliderScroll.frame : self.tagScroll.frame),
                                self.frame.size.width,
                                self.frame.size.height-CGRectGetMaxY(_sliderScroll ? _sliderScroll.frame : self.tagScroll.frame));
    _ctScroll.frame = ctFrame;
    _isRotate = YES;
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
    _sliderColor = [UIColor clearColor];
    _tagEdge = tagEdge;

    _animDuration = 0.5;
    _sliderWidthScale = 0.1;

    _tagArr = [NSMutableArray arrayWithArray:tagArr];
    _sliderType                     = type;
    _tagVisibleCount                = visibleCount;
    _tagVerVisibleCount             = visibleCount;
    _tagHorVisibleCount             = visibleCount*2;
    if (_tagHorVisibleCount > _tagArr.count)
        _tagHorVisibleCount = _tagArr.count;

    _tagItemWidth                   = self.tagScroll.frame.size.width / _tagVisibleCount;
    self.tagScroll.tagItemWidth     = _tagItemWidth;
    _tagScale                       = tagScale;
    self.tagScroll.tagScale         = tagScale;

    [self configTagData]; // 取色

    NSArray *tagItemWidthArr = [self.tagScroll configTagArray:tagArr tagScale:tagScale configTagItemBlock:block];
    _tagItemWidthArr = [NSMutableArray arrayWithArray:tagItemWidthArr];
    [self addSubview:self.tagScroll];

    [self configNormal];    // 默认
    [self configTagAction]; // 标签

    if (type != YFSliderTypeNone) {
        _sliderType = type;
        if (customSlider) {
            _customSlider = customSlider;
            _customFrame  = _customSlider.frame;
        }
    }
    _ctItemArr = [NSMutableArray arrayWithArray:contentArr];
    [self configContentScroll:contentArr];
}

#pragma mark - **************************** setup *****************************
- (void)changTagFrame:(UIEdgeInsets)tagScrollEdge
{
    CGRect rect = self.tagScroll.frame;
    rect.origin.x += ABS(tagScrollEdge.left);
    rect.origin.y += ABS(tagScrollEdge.top);
    rect.size.width -= ABS(tagScrollEdge.left)+ABS(tagScrollEdge.right);
    rect.size.height += tagScrollEdge.bottom;
    self.tagScroll.frame = rect;
}

- (void)configNormal
{
    _tagScrollAnim = YES;
    _ctScrollAnim = YES;
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
    _sliderView = [[YFSliderView alloc] initWithType:type
                                        containWidth:_tagItemWidth
                                           tagHeight:4
                                       containHeight:(_sliderType == YFSliderTypeBottomAlone) ? customSlider ? customSlider.frame.size.height : 4 : self.tagScroll.frame.size.height
                                           andSlider:customSlider scale:_tagScale
                                         customFrame:_customFrame];
    if (_sliderType == YFSliderTypeBottomAlone) {
        if (_sliderScroll) {
            [_sliderScroll removeFromSuperview];
            _sliderScroll = nil;
        }
        _sliderScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tagScroll.frame.origin.x,
                                                                       CGRectGetMaxY(self.tagScroll.frame),
                                                                       self.tagScroll.frame.size.width,
                                                                       customSlider ? customSlider.frame.size.height : 4)];
        [self addSubview:_sliderScroll];
        _sliderScroll.contentSize = self.tagScroll.contentSize;
        _sliderScroll.showsVerticalScrollIndicator = NO;
        _sliderScroll.showsHorizontalScrollIndicator = NO;
        _sliderScroll.userInteractionEnabled = NO;
        _sliderScroll.backgroundColor = _sliderColor;
        [_sliderScroll addSubview:_sliderView];

    }else {
        [self.tagScroll addSubview:_sliderView];
    }
    _isCustomWidth = _sliderView.isCustomWidth;
    if (!_isCustomWidth) {
        _sliderView.sliderWidth = size.width*(_tagScale+_sliderWidthScale);
    }
}

- (void)configContentScroll:(NSArray *)itemArr
{
    if (_ctScroll || _tagArr.count != itemArr.count) return;

    _ctScroll = [[YFContentScroll alloc] init];
    [_ctScroll configItemArr:itemArr];
    _ctScroll.delegate = self;

    [self addSubview:_ctScroll];
    [_ctScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - **************************** Action ****************************
- (void)configTagAction
{
    __weak typeof(self) weakSelf = self;
    self.tagScroll.delegate = self;
    self.tagScroll.tagSelectBlock = ^(UIButton *btn, NSInteger idx) {

        UIButton *lastBtn = (UIButton *)[weakSelf viewWithTag:weakSelf.currentIndex+kTagPadding];

        weakSelf.currentIndex = (int)(btn.tag-kTagPadding);

        weakSelf.lastPoint = CGPointMake(weakSelf.currentIndex*weakSelf.ctScroll.frame.size.width, 0);

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

    [_tagArr addObject:title];
    [_ctItemArr addObject:item];

    NSNumber *num = [self.tagScroll addTitle:title];
    [_tagItemWidthArr addObject:num];

    if (_sliderScroll)
        _sliderScroll.contentSize = self.tagScroll.contentSize;

    [_ctScroll addContent:item];
}
/**
 *  插入会设置为移动到新插入的位置
 */
- (void)addTagTitle:(NSString *)title contentItem:(id)item atIndex:(NSInteger)index
{
    if (!title || !item || _tagArr.count < index) return;
    [_tagArr insertObject:title atIndex:index];
    [_ctItemArr insertObject:item atIndex:index];

    UIButton *btn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];
    [btn setTitleColor:_tagColorNor forState:UIControlStateNormal];
    btn.transform = CGAffineTransformIdentity;

    NSNumber *num = [self.tagScroll addTitle:title atIndex:index];
    [_tagItemWidthArr insertObject:num atIndex:index];

    if (_sliderScroll)
        _sliderScroll.contentSize = self.tagScroll.contentSize;

    [_ctScroll addContent:item atIndex:index];

    if (index == self.currentIndex) { // 没有改变位置,手动调
        if ([self.delegate respondsToSelector:@selector(yfScrollViewChangeCurrentIndex:item:)]) {
            [self.delegate yfScrollViewChangeCurrentIndex:index item:_ctItemArr[index]];
        }
    }
    _isRotate = YES;
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
    if (index >= _tagArr.count || _tagArr.count < 2 || index < 0) return;

    NSInteger idx = self.currentIndex;  // 防止contentSize改变而调用代理, 使self.currentIndex改变, contentSize默认为0时,改变时不会调用代理
    
    [_tagArr removeObjectAtIndex:index];
    [_ctItemArr removeObjectAtIndex:index];
    [_tagItemWidthArr removeObjectAtIndex:index];
    
    [self.tagScroll removeItemAtIndex:index];

    if (_sliderScroll)
        _sliderScroll.contentSize = self.tagScroll.contentSize;
    
    [_ctScroll removeItemAtIndex:index];

    // 调整位置
    _isRotate = YES;
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

    [_tagArr removeObjectsAtIndexes:indexSet];
    [_ctItemArr removeObjectsAtIndexes:indexSet];
    [_tagItemWidthArr removeObjectsAtIndexes:indexSet];

    [self.tagScroll removeItemAtIndexs:indexs];
    if (_sliderScroll)
        _sliderScroll.contentSize = self.tagScroll.contentSize;
    [_ctScroll removeItemAtIndexs:indexs];

    // 调整位置, 原来的位置
    _isRotate = YES;
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
    if (index1 == index2 || _tagArr.count <= index1 || _tagArr.count <= index2) return;

    [_tagArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [_ctItemArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [_tagItemWidthArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];

    [self.tagScroll exchangeAtIndex:index1 withIndex:index2];
    [_ctScroll exchangeAtIndex:index1 withIndex:index2];

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
    if (tagArr.count != contentArr.count || _ctItemArr == contentArr || tagArr.count == 0 || !tagArr) return;

    NSString *str = _tagArr[self.currentIndex];

    _tagArr = [NSMutableArray arrayWithArray:tagArr];
    _ctItemArr = [NSMutableArray arrayWithArray:contentArr];

    _tagItemWidthArr = [self.tagScroll updataTagArr:tagArr];
    if (_sliderScroll)
        _sliderScroll.contentSize = self.tagScroll.contentSize;
    [_ctScroll updataContentItem:contentArr];

    _isRotate = YES;
    if ([_tagArr containsObject:str])
        [self setCurrentIndex:[_tagArr indexOfObject:str] animated:NO TagAnimated:NO];
    else
        [self setCurrentIndex:0 animated:NO TagAnimated:NO];

}


#pragma mark - ********************* ScrollView Delegate **********************

// 实时响应
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_sliderScroll) {
        _sliderScroll.contentOffset = self.tagScroll.contentOffset;
    }
    if (scrollView == _ctScroll) {
        CGPoint point = scrollView.contentOffset;

        // 代理
        if (point.x < 0)
            [self yfScrollViewOutOfVaule:point.x];
        else if (point.x > (scrollView.contentSize.width-scrollView.frame.size.width))
            [self yfScrollViewOutOfVaule:point.x-(scrollView.contentSize.width-scrollView.frame.size.width)];

        if (_isJump) return;

        if (!_isJump) {
            self.currentIndex = (int)(point.x / _ctScroll.frame.size.width);
        }
        CGFloat tagPotX = point.x / _ctScroll.contentSize.width * _tagScroll.contentSize.width;

        // bug点 左滑
        if (_ctScroll.contentOffset.x == self.currentIndex*_ctScroll.frame.size.width) return;

        if (point.x >= 0 && point.x <= (_tagArr.count-1)*_ctScroll.frame.size.width) {

            UIButton *currentBtn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];

            // slider
            if (_sliderView) {
                _sliderView.transform = CGAffineTransformMakeTranslation(tagPotX, 0);
            }
            float movePadding = 0;
            if (point.x >= _lastPoint.x) {  // 左滑
                _lastBtn = currentBtn;
                _nextBtn = (UIButton *)[self viewWithTag:currentBtn.tag+1];
                if (self.currentIndex <= _tagItemWidthArr.count-2) {
                    movePadding = ([_tagItemWidthArr[self.currentIndex+1] floatValue] - [_tagItemWidthArr[self.currentIndex] floatValue]) / _tagItemWidth;
                }
            }else {                         // 右滑
                _nextBtn = currentBtn;
                _lastBtn = (UIButton *)[self viewWithTag:currentBtn.tag+1];
                if (self.currentIndex <= _tagItemWidthArr.count-2) {
                    movePadding = ([_tagItemWidthArr[self.currentIndex] floatValue] - [_tagItemWidthArr[self.currentIndex+1] floatValue]) / _tagItemWidth;
                }
            }

            // slider  tagScroll上的offSet变化 * item每个点所的变化 * 缩放
            if (self.currentIndex <= _tagItemWidthArr.count-2 && [_tagItemWidthArr[self.currentIndex] floatValue] != [_tagItemWidthArr[self.currentIndex+1] floatValue] && !_isCustomWidth ) {

                _sliderView.sliderWidth += movePadding * ABS(point.x/_ctScroll.contentSize.width * _tagScroll.contentSize.width -_lastPoint.x/ _ctScroll.contentSize.width * _tagScroll.contentSize.width) * (_tagScale+_sliderWidthScale);
            }

            _lastPoint = point;
            
            // 按钮  tagScroll上的offSet变化 * item每个点所的变化 * 缩放
            // 缩放前的originX
            CGFloat originX = (_lastBtn.tag-kTagPadding)*_tagItemWidth;

            if (_lastBtn && !_isJump) {
                _lastBtn.transform = CGAffineTransformMakeScale(_tagScale-ABS(tagPotX-originX)*_btnScale, _tagScale-ABS(tagPotX-originX)*_btnScale);

                UIColor *color = [UIColor colorWithRed:[_tagColorSelect red]   - ABS(tagPotX-originX)*_colorRedScale
                                                 green:[_tagColorSelect green] - ABS(tagPotX-originX)*_colorGreenScale
                                                  blue:[_tagColorSelect blue]  - ABS(tagPotX-originX)*_colorBlueScale
                                                 alpha:[_tagColorSelect alpha] - ABS(tagPotX-originX)*_colorAlphaScale];
                [_lastBtn setTitleColor:color forState:UIControlStateNormal];
            }

            if (_nextBtn && !_isJump) {

                _nextBtn.transform = CGAffineTransformMakeScale(1.0+ABS(tagPotX-originX)*_btnScale, 1.0+ABS(tagPotX-originX)*_btnScale);

                UIColor *color = [UIColor colorWithRed:[_tagColorNor red]   + ABS(tagPotX-originX)*_colorRedScale
                                                 green:[_tagColorNor green] + ABS(tagPotX-originX)*_colorGreenScale
                                                  blue:[_tagColorNor blue]  + ABS(tagPotX-originX)*_colorBlueScale
                                                 alpha:[_tagColorNor alpha] + ABS(tagPotX-originX)*_colorAlphaScale];
                [_nextBtn setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
}

// 动画结束, 移动scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_tagArr.count <= _tagVisibleCount ) return;
    if ( scrollView == _ctScroll ) {
        [self tagScrollMove];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    static int a = 0;
    if (_isJump && [scrollView isKindOfClass:[YFContentScroll class]]) {
        a++;
        if (a == _moveCount) {
            _isJump = NO;
            a = 0;
            _moveCount = 1;
        }
    }
}

#pragma mark - ***************************** move *****************************

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated TagAnimated:(BOOL)tagAnimated
{
    if (self.currentIndex == currentIndex && !_isRotate) return;
    _isRotate = NO;

    if (_isJump) return;

    _ctScrollAnim = animated;
    _tagScrollAnim = tagAnimated;

    UIButton *btn = [self viewWithTag:self.currentIndex+kTagPadding];

    self.currentIndex = currentIndex;

    _isJump = YES;

    UIButton *destBtn = [self viewWithTag:self.currentIndex+kTagPadding];

    [UIView animateWithDuration:_animDuration animations:^{
        if (!_isCustomWidth) {
            _sliderView.sliderWidth = [_tagItemWidthArr[self.currentIndex] floatValue] * (_tagScale+_sliderWidthScale);
        }
        btn.transform = CGAffineTransformIdentity;
        [btn setTitleColor:_tagColorNor forState:UIControlStateNormal];
        destBtn.transform = CGAffineTransformMakeScale(_tagScale, _tagScale);
        [destBtn setTitleColor:_tagColorSelect forState:UIControlStateNormal];
    }];
    /* animated YES, 调用代理EndAnima 1次, 调用DidScroll 18次;
     NO,  调用代理EndAnima 0次, 调用DidScroll 1 次;
     如果tag移动的目标区域在当前显示的地方 不调用 EndAnima
     边切几十次后 会造成 _isJump 不能被初始成NO
     */
    if (animated) {
        _moveCount = 1;
    }
    if ((!animated && !tagAnimated) || !animated) {
        _moveCount = 1;
        _isJump = NO;
    }
    _lastPoint = CGPointMake(self.currentIndex*_ctScroll.frame.size.width, 0);

    [self configNormal];

    if (_tagArr.count > _tagVisibleCount ) {
        [self tagScrollMove];
    };

    if (_sliderView) {
        [UIView animateWithDuration:_animDuration animations:^{
            _sliderView.transform = CGAffineTransformMakeTranslation(self.currentIndex*_tagItemWidth, 0);
        }];
    }
    [_ctScroll setContentOffset:CGPointMake(_ctScroll.frame.size.width*currentIndex, 0) animated:animated];
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
    int num = _tagVisibleCount / 2 - 0.5;
    if (self.currentIndex > num && self.currentIndex < _tagArr.count-1-num)
        return YES;
    else
        return NO;
}

- (void)tagScrollMove
{
    // 如果tagVisibleCount不会整数,整体画面是右边多出来
    if (_isMoveToVisible) {
        float padding = _tagVisibleCount - (int)_tagVisibleCount;
        UIButton *btn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding];
        UIButton *nextBtn;
        if (self.currentIndex+1 <= _tagArr.count-1) {
            nextBtn = (UIButton *)[self viewWithTag:self.currentIndex+kTagPadding+1];
        }
        CGRect frame = btn.frame;
        if (padding > 0) {
            if (nextBtn)
                frame.size.width -= CGRectGetMaxX(frame)-nextBtn.frame.origin.x;
            frame.size.width += padding*_tagItemWidth;
        }
        [_tagScroll scrollRectToVisible:frame animated:_tagScrollAnim];

    }else {
        BOOL isNeed = [self isNeedAutoScroll];
        if (isNeed)                                         // 移中
            [_tagScroll setContentOffset:CGPointMake(self.currentIndex*_tagItemWidth+_tagItemWidth/2-self.tagScroll.frame.size.width/2, 0) animated:_tagScrollAnim];
        else if (self.currentIndex <= _tagVisibleCount/2)   // 移zero
            [_tagScroll setContentOffset:CGPointZero animated:_tagScrollAnim];
        else                                                // 移最右
            [_tagScroll setContentOffset:CGPointMake(_tagScroll.contentSize.width-self.tagScroll.frame.size.width, 0) animated:_tagScrollAnim];
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
    if (_ctScroll) {
        [_ctScroll removeObserver:self forKeyPath:@"contentOffset"];
        _ctScroll = nil;
    }
    NSLog(@"%s",__func__);
}

@end
