//
//  shapeView.h
//  testUIBezierPath
//
//  Created by Codeliu on 15/11/2.
//  Copyright © 2015年 Resory. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CuteViewDelegate <NSObject>

- (void)backMeWithHeaderCenterY:(CGFloat)centerY;

@end
@interface LHCuteView : UIView
@property(nonatomic,strong)id <CuteViewDelegate>cuteDelegate;
@property (nonatomic, strong) UIImageView *headerImage;
- (void)handlePanAction:(UIPanGestureRecognizer *)pan;

@end
