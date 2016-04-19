# YFLinkageScroll

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS-red.svg)

多 UIScrollView 联动

###效果:

<p align="left" >
  <img src="ver.gif" alt="KYAnimatedPageControl" title="KYAnimatedPageControl" width = "280">
  <img src="style.gif" alt="KYAnimatedPageControl" title="KYAnimatedPageControl" width = "280">
</p>
<img src="hor.gif" alt="KYAnimatedPageControl" title="KYAnimatedPageControl" width = "400">


###下面是实现的效果: 全可自定义
1. 按钮(颜色,大小缩放)<p></p>
```
YFTagItemConfigration block = ^UIButton *(UIButton *itemBtn, NSUInteger index){
        if (index == 0) {  // 选中状态
            [itemBtn setTitleColor:[UIColor colorWithRed:0.4 green:0.0 blue:1.0 alpha:0.3] forState:UIControlStateNormal];
        }else {            // 默认状态
            [itemBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        }
        itemBtn.titleLabel.font = [UIFont systemFontOfSize:15]; // 大小按缩放比例
        return itemBtn;
    };
```
2. 滑块类型: 自定义颜色高,宽度跟btn.titile宽度+参数<p></p>
```
/** slider宽度, 默认取title字符宽度, 这个值为基本上增加 1.0+sliderWidthScale */
@property (nonatomic, assign) CGFloat sliderWidthScale;
typedef NS_ENUM(NSUInteger, YFSliderType) {
    YFSliderTypeNone,           // 没有
    YFSliderTypeTop,            // 上面
    YFSliderTypeMid,            // 中间
    YFSliderTypeBottom,         // 下面
    YFSliderTypeBottomAlone     // 下面独立
};
```
3. 内容(UIViewcontroller, UIView)
