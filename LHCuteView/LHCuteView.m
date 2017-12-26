//
//  shapeView.m
//  testUIBezierPath
//
//  Created by Codeliu on 15/11/2.
//  Copyright © 2015年 Resory. All rights reserved.
//

#import "LHCuteView.h"

#define KWIDTH    ([[UIScreen mainScreen] bounds].size.width)                  // 屏幕宽度
#define KHEIGHT   ([[UIScreen mainScreen] bounds].size.height)                 // 屏幕长度
#define MIN_HEIGHT          150                                                // 图形最小高度

@interface LHCuteView ()

@property (nonatomic, assign) CGFloat mHeight;
@property (nonatomic, assign) CGFloat curveX;
@property (nonatomic, assign) CGFloat curveY;
@property (nonatomic, strong) UIView *curveView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL isAnimating;


@end

@implementation LHCuteView

static NSString *kX = @"curveX";
static NSString *kY = @"curveY";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self addObserver:self forKeyPath:kX options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:kY options:NSKeyValueObservingOptionNew context:nil];
        [self configShapeLayer];
        [self configCurveView];
        [self configAction];
        [self changeShape];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kX];
    [self removeObserver:self forKeyPath:kY];
}

- (void)drawRect:(CGRect)rect
{
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kX] || [keyPath isEqualToString:kY]) {
        [self updateShapeLayerPath];
    }
}

#pragma mark -
#pragma mark - Configuration

- (void)configAction
{
    _mHeight = 150;                       // 手势移动时相对高度
    _isAnimating = NO;                    // 是否处于动效状态
    
    // 手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:pan];
    
    // CADisplayLink默认每秒运行60次calculatePath是算出在运行期间_curveView的坐标，从而确定_shapeLayer的形状
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES;
}

- (void)configShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_shapeLayer];
    
    _headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _headerImage.layer.cornerRadius = 40;
    _headerImage.clipsToBounds = YES;
    _headerImage.backgroundColor = [UIColor blueColor];
    [self addSubview:_headerImage];
    _headerImage.center = CGPointMake(KWIDTH / 2, 105);

}
- (void)changeShape
{
    // 更新_shapeLayer形状
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:CGPointMake(0, 0)];
    [tPath addLineToPoint:CGPointMake( KWIDTH,0)];
    [tPath addLineToPoint:CGPointMake(KWIDTH,  150)];

    [tPath addQuadCurveToPoint:CGPointMake(0, 150) controlPoint:CGPointMake(KWIDTH / 2, 60)];
    [tPath closePath];
    _shapeLayer.path = tPath.CGPath;
    
    _shapeLayer.fillColor = [UIColor colorWithRed:0.85f green:0.96f blue:0.86f alpha:1.00f].CGColor;
}
- (void)configCurveView
{
    self.curveX = KWIDTH/2.0;
    self.curveY = MIN_HEIGHT;
    _curveView = [[UIView alloc] initWithFrame:CGRectMake(_curveX, 60, 0.1, 0.1)];
    _curveView.backgroundColor = [UIColor blackColor];
    [self addSubview:_curveView];
}

#pragma mark - Action

- (void)handlePanAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    NSLog(@"%f",point.y);

    if (point.y < 0) {
        return;
    }
    if(!_isAnimating)
    {
        if(pan.state == UIGestureRecognizerStateChanged)
        {
            // 手势移动时，_shapeLayer跟着手势向下扩大区域
            
            _mHeight = point.y + 60;

            self.curveX = KWIDTH/2.0;
            self.curveY = _mHeight > 240 ? 240 : _mHeight;
            _curveView.frame = CGRectMake(_curveX,
                                          self.curveY,
                                          _curveView.frame.size.width,
                                          _curveView.frame.size.height);
            _headerImage.center = CGPointMake(KWIDTH / 2, 105 + (self.curveY - 60) / 2);
            
            [self.cuteDelegate backMeWithHeaderCenterY:105 + (self.curveY - 60) / 2];
        }
        else if (pan.state == UIGestureRecognizerStateCancelled ||
                 pan.state == UIGestureRecognizerStateEnded ||
                 pan.state == UIGestureRecognizerStateFailed)
        {
            // 手势结束时,_shapeLayer返回原状并产生弹簧动效
            _isAnimating = YES;
            _displayLink.paused = NO;           //开启displaylink,会执行方法calculatePath.
            
            // 弹簧动效
            [UIView animateWithDuration:1
                                  delay:0.0
                 usingSpringWithDamping:0.3
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 _curveView.frame = CGRectMake(KWIDTH/2, 60, 0.1, 0.1);
                                 _headerImage.center = CGPointMake(KWIDTH / 2, 105);
                                 NSLog(@"%f",_headerImage.center.y);

                                 [self.cuteDelegate backMeWithHeaderCenterY:105];

                             } completion:^(BOOL finished) {
                                 
                                 if(finished)
                                 {
                                     _displayLink.paused = YES;
                                     _isAnimating = NO;
                                     [self.cuteDelegate backMeWithHeaderCenterY:1000];

                                 }
                                 
                             }];
        }
    }
}

- (void)updateShapeLayerPath
{
    // 更新_shapeLayer形状
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:CGPointMake(0, 0)];
    [tPath addLineToPoint:CGPointMake(KWIDTH, 0)];
    [tPath addLineToPoint:CGPointMake(KWIDTH,  MIN_HEIGHT)];
    [tPath addQuadCurveToPoint:CGPointMake(0, MIN_HEIGHT)
                  controlPoint:CGPointMake(_curveX, _curveY)];
    [tPath closePath];
    _shapeLayer.path = tPath.CGPath;
}




- (void)calculatePath
{
    // 由于手势结束时,r5执行了一个UIView的弹簧动画,把这个过程的坐标记录下来,并相应的画出_shapeLayer形状
    CALayer *layer = _curveView.layer.presentationLayer;
    self.curveX = layer.position.x ;
    self.curveY = layer.position.y;
}

@end
