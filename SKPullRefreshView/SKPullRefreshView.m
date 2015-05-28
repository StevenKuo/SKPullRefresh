//
//  SKPullRefreshView.m
//  test
//
//  Created by StevenKuo on 2015/4/11.
//  Copyright (c) 2015年 StevenKuo. All rights reserved.
//

#import "SKPullRefreshView.h"

@interface SKPullRefreshView()
@property (assign, nonatomic) CGFloat verticalValue;
@end
@implementation SKPullRefreshView

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)inScrollView
{
	NSAssert(inScrollView, @"have to give a scrollView");
	NSAssert(CGRectGetHeight(frame) >= 100.0, @"minmum of height is 100");
	
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
		
		ballViewStartY = CGRectGetHeight(frame) / 2.0 - 50.0;
		
        ball = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 50.0) / 2.0, ballViewStartY, 50.0, 50.0)];
        ball.layer.cornerRadius = 25.0;
        ball.backgroundColor = [UIColor colorWithRed:0.50 green:0.59 blue:0.78 alpha:1.00];
        [self addSubview:ball];
		
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
		[indicatorView startAnimating];
		indicatorView.alpha = 0.0;
        [ball addSubview:indicatorView];
        
        curveOffset = 10;
        leftXOffset = -20.0;
		
		scrollView = inScrollView;
		
		[inScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
    return self;
}

- (void)setVerticalValue:(CGFloat)inVerticalValue
{
	if (!dragFinish) {
		[UIView animateWithDuration:0.25 animations:^{
			if (inVerticalValue >= 35.0) {
				indicatorView.alpha = 1.0;
			}
			else {
				indicatorView.alpha = 0.0;
			}
		}];
		
	}
	
	verticalValue = inVerticalValue;
}

- (void)resetStateAfterRestore
{
	ball.frame = CGRectMake(CGRectGetMinX(ball.frame), ballViewStartY, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
	dragFinish = NO;
	startRestore = NO;
	bottomYOffset = 0.0;
	self.verticalValue = 0.0;
	curveOffset = 10;
	leftXOffset = -20.0;
	[self setNeedsDisplay];
	waittingRestore = NO;
}

- (void)_keepRestoreValue
{
	tempVerticalValue = self.verticalValue;
	self.verticalValue = 0;
	tempLeftXOffset = leftXOffset;
	leftXOffset = 0;
	tempCurveOffsert = curveOffset;
	curveOffset = 0;
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
    self.verticalValue = tempVerticalValue;
    leftXOffset = tempLeftXOffset;
    curveOffset = tempCurveOffsert;
    [self setNeedsDisplay];
    if (!display) {
        display = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValueForRestore:)];
        [display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)updateValueForRestore:(id)sender
{
    if (CGRectGetMinY(ball.frame) <= ballViewStartY) {
        if (display) {
            [display invalidate];
            display = nil;
        }
		[self resetStateAfterRestore];
		scrollView.scrollEnabled = YES;
        return;
    }
    if (curveOffset < 10.0) {
        curveOffset += 2.5;
    }
    if (leftXOffset > -20.0) {
        leftXOffset -=2.5;
    }
    if (self.verticalValue > 0) {
        self.verticalValue -= 5.0;
    }
    ball.frame = CGRectMake(CGRectGetMinX(ball.frame), CGRectGetMinY(ball.frame) - 5.0, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
	scrollView.contentOffset = CGPointMake(0.0, -(CGRectGetMinY(ball.frame) - ballViewStartY));
    [self setNeedsDisplay];
}

- (void)drag:(CGFloat)distance
{
    if (ballViewStartY + distance >= 100.0 + ballViewStartY - 10.0) {
        ball.frame = CGRectMake(CGRectGetMinX(ball.frame), 100.0 + ballViewStartY - 10.0, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
        return;
    }
    
    ball.frame = CGRectMake(CGRectGetMinX(ball.frame), ballViewStartY + distance, CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
	
    if (CGRectGetMinY(ball.frame) < ballViewStartY + 5.0) {
        return;
    }
        
    CGFloat moveDistance = (CGRectGetMinY(ball.frame) - (ballViewStartY + 5.0));
    if (moveDistance <= 0.0) {
        return;
    }
    
    bottomYOffset = moveDistance / 2.0;
    
    self.verticalValue = (moveDistance / 2.0) - 5.0 <= 0 ? 0.0 : (moveDistance / 2.0) - 5.0;
	
	curveOffset = 10.0 - (moveDistance / 4.0) <= 0.0 ? 0.0 : 10.0 - (moveDistance / 4.0);
	
	leftXOffset = -20.0 + (moveDistance / 5.0);
	
    [self setNeedsDisplay];
}

- (void)updateValueForDrag:(id)sender
{
    if (dragFinish) {
        [display invalidate];
        display = nil;
        [self setNeedsDisplay];
		waittingRestore = YES;
		[delegate dragAnimatioinFinish];
    }
    if (bottomYOffset <= -5.0) {
        dragFinish = YES;
        bottomYOffset = 5.0;
		[self _keepRestoreValue];
    }
    bottomYOffset -= 2.0;
    self.verticalValue += 2.0;
    leftXOffset +=0.8;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (dragFinish) {
        bottomYOffset = 0.0;
        self.verticalValue = 0;
        leftXOffset = 0;
        curveOffset = 0;
    }
    CGFloat leftX = (CGRectGetWidth(self.frame) - CGRectGetWidth(ball.frame)) / 2.0;
    CGFloat rightX = CGRectGetWidth(self.frame) - leftX;
    CGFloat bottomY = CGRectGetHeight(self.frame) / 2.0;
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
	
    
	CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, NULL, 0.0, bottomY);
	
	
    CGPathAddQuadCurveToPoint(path, NULL, 70.0, bottomY + bottomYOffset, leftX + leftXOffset, bottomY + bottomYOffset);
    CGPathAddQuadCurveToPoint(path, NULL, leftX + leftXOffset + 15.0, bottomY + bottomYOffset + 1, leftX + 15.0 - 10.0 + curveOffset, bottomY + bottomYOffset + self.verticalValue);
    CGPathAddLineToPoint(path, NULL, rightX - 15.0 + 10.0 - curveOffset, bottomY + bottomYOffset + self.verticalValue);
    CGPathAddQuadCurveToPoint(path, NULL, rightX - 15.0 - leftXOffset, bottomY + bottomYOffset + 1, rightX - leftXOffset, bottomY + bottomYOffset);
    CGPathAddQuadCurveToPoint(path, NULL, CGRectGetWidth(self.frame) - 70.0, bottomY + bottomYOffset, CGRectGetWidth(self.frame), bottomY);
	
	
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(self.frame), 0.0);
    
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.50 green:0.59 blue:0.78 alpha:1.00].CGColor);
    CGContextFillPath(ctx);
}

@synthesize delegate;
@synthesize verticalValue;
@synthesize waittingRestore;
@end
