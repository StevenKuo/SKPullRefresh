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
    

}

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)inScrollView;
- (void)restore;

@property (weak, nonatomic) id <SKPullRefreshView> delegate;
@end
