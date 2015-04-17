//
//  SKPullRefreshView.m
//  test
//
//  Created by StevenKuo on 2015/4/11.
//  Copyright (c) 2015年 StevenKuo. All rights reserved.
//

#import "SKPullRefreshView.h"

@interface SKPullRefreshView()
@property (assign, nonatomic) CGFloat connectLineLengthValue;
@end
@implementation SKPullRefreshView

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)inScrollView
{
	if (!inScrollView) {
		return nil;
	}
	
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        ball = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 50.0) / 2.0, 50.0, 50.0, 50.0)];
        ball.layer.cornerRadius = 25.0;
        ball.backgroundColor = [UIColor colorWithRed:0.50 green:0.59 blue:0.78 alpha:1.00];
        [self addSubview:ball];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
		[indicatorView startAnimating];
		indicatorView.alpha = 0.0;
        [ball addSubview:indicatorView];
        
        connectLineBottomWidthValue = 10;
        connectLineTopWidthValue = -20.0;
		
		scrollView = inScrollView;
		
		[inScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
    return self;
}

- (void)setConnectLineLengthValue:(CGFloat)inConnectLineLengthValue
{
	if (!dragFinish) {
		[UIView animateWithDuration:0.25 animations:^{
			if (inConnectLineLengthValue >= 35.0) {
				indicatorView.alpha = 1.0;
			}
			else {
				indicatorView.alpha = 0.0;
			}
		}];

	}

	connectLineLengthValue = inConnectLineLengthValue;
}

- (void)_resetStateAfterRestore
{
	ball.frame = CGRectMake(CGRectGetMinX(ball.frame), 50.0, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
	dragFinish = NO;
	startRestore = NO;
	basicCurveValue = 0.0;
	self.connectLineLengthValue = 0.0;
	connectLineBottomWidthValue = 10;
	connectLineTopWidthValue = -20.0;
	[self setNeedsDisplay];
}

- (void)_keepConnectValue
{
	pullConnectLineLengthValue = self.connectLineLengthValue;
	self.connectLineLengthValue = 0;
	pullConnectLineTopWidthValue = connectLineTopWidthValue;
	connectLineTopWidthValue = 0;
	pullConnectLineBottomWidthValue = connectLineBottomWidthValue;
	connectLineBottomWidthValue = 0;
	[self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (startRestore) {
		return;
	}
	UIScrollView *scroll = (UIScrollView *)object;
	if (scroll.contentOffset.y >= 0.0) {
		return;
	}
	if (scroll.contentOffset.y < -100.0) {
		scroll.scrollEnabled = NO;
		scroll.contentOffset = CGPointMake(0.0, -100.0);
		if (!display) {
			display = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValueForDrag:)];
			[display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		}
		return;
	}
	[self drag:-scroll.contentOffset.y];
	
}

- (void)restore
{
	startRestore = YES;
    dragFinish = NO;
    self.connectLineLengthValue = pullConnectLineLengthValue;
    connectLineTopWidthValue = pullConnectLineTopWidthValue;
    connectLineBottomWidthValue = pullConnectLineBottomWidthValue;
    [self setNeedsDisplay];
    if (!display) {
        display = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValueForRestore:)];
        [display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)updateValueForRestore:(id)sender
{
    if (CGRectGetMinY(ball.frame) <= 50.0) {
        if (display) {
            [display invalidate];
            display = nil;
        }
		[self _resetStateAfterRestore];
		scrollView.scrollEnabled = YES;
        return;
    }
    if (connectLineBottomWidthValue < 10.0) {
        connectLineBottomWidthValue += 2.5;
    }
    if (connectLineTopWidthValue > -20.0) {
        connectLineTopWidthValue -=2.5;
    }
    if (self.connectLineLengthValue > 0) {
        self.connectLineLengthValue -= 5.0;
    }
    ball.frame = CGRectMake(CGRectGetMinX(ball.frame), CGRectGetMinY(ball.frame) - 5.0, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
	scrollView.contentOffset = CGPointMake(0.0, -(CGRectGetMinY(ball.frame) - 50.0));
    [self setNeedsDisplay];
}

- (void)drag:(CGFloat)distance
{
    if (50.0 + distance >= 140.0) {
        ball.frame = CGRectMake(CGRectGetMinX(ball.frame), 140.0, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
        return;
    }
    
    ball.frame = CGRectMake(CGRectGetMinX(ball.frame), 50.0 + distance, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
    
    if (CGRectGetMinX(ball.frame) < 55.0) {
        return;
    }
        
    CGFloat moveDistance = (CGRectGetMinY(ball.frame) - 55.0);
    if (moveDistance <= 0.0) {
        return;
    }
    
    basicCurveValue = moveDistance / 2.0;
    
    self.connectLineLengthValue = (moveDistance / 2.0) - 5.0 <= 0 ? 0.0 : (moveDistance / 2.0) - 5.0;
    
    if (10.0 - (moveDistance / 4.0) <= 0.0) {
        connectLineBottomWidthValue = 0.0;
    }
    else if (10.0 - (moveDistance / 4.0) >= 10.0) {
        connectLineBottomWidthValue = 10.0;
    }
    else {
        connectLineBottomWidthValue = 10.0 - (moveDistance / 4.0);
    }
    
    if (-20.0 + (moveDistance / 5.0) <= -20.0) {
        connectLineTopWidthValue = -20.0;
    }
    else if (-20.0 + (moveDistance / 5.0) >= 0) {
        connectLineTopWidthValue = 0.0;
    }
    else {
        connectLineTopWidthValue = -20.0 + (moveDistance / 5.0);
    }
    [self setNeedsDisplay];
}

- (void)updateValueForDrag:(id)sender
{
    if (dragFinish) {
        [display invalidate];
        display = nil;
        [self setNeedsDisplay];
		[delegate dragAnimatioinFinish];
    }
    if (basicCurveValue <= -5.0) {
        dragFinish = YES;
        basicCurveValue = 5.0;
		[self _keepConnectValue];
    }
    basicCurveValue -= 2.0;
    self.connectLineLengthValue += 2.0;
    connectLineTopWidthValue +=0.8;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (dragFinish) {
        basicCurveValue = 0.0;
        self.connectLineLengthValue = 0;
        connectLineTopWidthValue = 0;
        connectLineBottomWidthValue = 0;
    }
    
    CGFloat firstPoint = (CGRectGetWidth(self.frame) - CGRectGetWidth(ball.frame)) / 2.0;
    CGFloat secondePoint = CGRectGetWidth(self.frame) - firstPoint;
    CGFloat begin = CGRectGetHeight(self.frame) / 2.0;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, NULL, 0.0, begin);
    CGPathAddQuadCurveToPoint(path, NULL, 70.0, begin + basicCurveValue, firstPoint + connectLineTopWidthValue, begin + basicCurveValue);
    CGPathAddQuadCurveToPoint(path, NULL, firstPoint + 15.0 + connectLineTopWidthValue, begin + basicCurveValue + 1, firstPoint + 15.0 - 10.0 + connectLineBottomWidthValue, begin + basicCurveValue + self.connectLineLengthValue);
    CGPathAddLineToPoint(path, NULL, secondePoint - 15.0 + 10.0 - connectLineBottomWidthValue, begin + basicCurveValue + self.connectLineLengthValue);
    CGPathAddQuadCurveToPoint(path, NULL, secondePoint - 15.0 - connectLineTopWidthValue, begin + basicCurveValue + 1, secondePoint - connectLineTopWidthValue, begin + basicCurveValue);
    CGPathAddQuadCurveToPoint(path, NULL, CGRectGetWidth(self.frame) - 70.0, begin + basicCurveValue, CGRectGetWidth(self.frame), begin);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(self.frame), 0.0);
    
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.50 green:0.59 blue:0.78 alpha:1.00].CGColor);
    CGContextFillPath(ctx);
}

@synthesize delegate;
@synthesize connectLineLengthValue;
@end
