//
//  SKPullRefreshView.h
//  test
//
//  Created by StevenKuo on 2015/4/11.
//  Copyright (c) 2015年 StevenKuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol SKPullRefreshView <NSObject>

- (void)dragAnimatioinFinish;

@end

@interface SKPullRefreshView : UIView
{
    
    UIView *ball;
    UIActivityIndicatorView *indicatorView;
	UIScrollView *scrollView;
	
	UIColor *mainColor;
    
	CGFloat bottomYOffset;
    CGFloat leftXOffset;
    CGFloat curveOffset;
	
	CGFloat tempVerticalValue;
	CGFloat tempLeftXOffset;
	CGFloat tempCurveOffsert;
	
	CGFloat ballViewStartY;
	
    CADisplayLink *display;
    BOOL dragFinish;
	BOOL startRestore;
    BOOL waittingRestore;

}

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)inScrollView backgroundColor:(UIColor *)color;
- (void)restore;
- (void)resetStateAfterRestore;

@property (weak, nonatomic) id <SKPullRefreshView> delegate;
@property (readonly, nonatomic) BOOL waittingRestore;
@end
