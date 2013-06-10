//
//  DVPlayerSeekBar.m
//  DVQueuePlayerDemo
//
//  Created by Mikhail Grushin on 10.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVPlayerSeekBar.h"
#import <QuartzCore/QuartzCore.h>

@interface DVPlayerSeekBar()

@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) CALayer *progressLayer;

@end

@implementation DVPlayerSeekBar

-(CALayer *)backgroundLayer
{
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    }
    
    return _backgroundLayer;
}

-(CALayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
    return _progressLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        [self.layer addSublayer:self.backgroundLayer];
        [self.layer addSublayer:self.progressLayer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - Accessors

@synthesize progress = _progress;

-(void)setProgress:(CGFloat)progress
{
    _progress = MIN(MAX(0.f, progress), 1.f);
    
    if (progress < 0.02f)
        _progress = 0.f;
    else if (progress > 0.98f)
        _progress = 1.f;
    
    CGFloat length = progress*self.bounds.size.width;
    CGRect frame = self.progressLayer.frame;
    frame.size.width = length;
    
    self.progressLayer.frame = frame;
}

#pragma mark - Positioning and Layout

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (layer == self.layer) [self layoutSublayers];
}

-(void)layoutSublayers
{
    self.backgroundLayer.frame = self.bounds;
    _backgroundLayer.cornerRadius = self.bounds.size.height/2.f;
    
    self.progressLayer.frame = CGRectMake(0.f, 0.f,
                                          self.progress*self.backgroundLayer.bounds.size.width,
                                          self.backgroundLayer.bounds.size.height);
    _progressLayer.cornerRadius = self.bounds.size.height/2.f;
}

#pragma mark - Handle Gestures

-(void)tapGesture:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapPoint = [tapRecognizer locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, tapPoint) &&
        tapRecognizer.state == UIGestureRecognizerStateEnded) {
        self.progress = tapPoint.x/self.bounds.size.width;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)panGesture:(UIPanGestureRecognizer *)panRecognizer
{
    static float oldValue = 0.f;
    
    CGFloat offsetX = [panRecognizer translationInView:self].x;
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGFloat location = [panRecognizer locationInView:self].x;
            float value = [self progressWithX:location];
            if (ABS(self.progress - value) > 0.1f) {
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                self.progress = value;
                [CATransaction commit];
            }
            
            oldValue = self.progress;
            
            [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            self.progress = oldValue + [self progressWithX:offsetX];
            [CATransaction commit];
            
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
            break;
            
        default:
            break;
    }
}

#pragma mark - Utility

-(CGFloat)progressWithX:(CGFloat)x
{
    return x/self.bounds.size.width;
}

@end
