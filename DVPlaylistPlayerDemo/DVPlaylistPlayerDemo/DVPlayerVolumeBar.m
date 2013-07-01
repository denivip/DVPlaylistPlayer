//
//  DVPlayerVolumeBar.m
//  DVPlaylistPlayerDemo
//
//  Created by Mikhail Grushin on 10.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVPlayerVolumeBar.h"
#import <QuartzCore/QuartzCore.h>

@interface DVPlayerVolumeBar()

@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) CALayer *volumeLayer;
@property (nonatomic) float volumeBeforeMute;

@end

@implementation DVPlayerVolumeBar

-(CALayer *)backgroundLayer
{
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    }
    
    return _backgroundLayer;
}

-(CALayer *)volumeLayer
{
    if (!_volumeLayer) {
        _volumeLayer = [CALayer layer];
        _volumeLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
    return _volumeLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.layer addSublayer:self.backgroundLayer];
        [self.layer addSublayer:self.volumeLayer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - Accessors

@synthesize volume = _volume;

-(void)setVolume:(CGFloat)volume
{
    _volume = MIN(MAX(0.f, volume), 1.f);
    
    if (volume < 0.02f)
        _volume = 0.f;
    else if (volume > 0.98f)
        _volume = 1.f;
    
    //    CGFloat ratio = volume*self.bounds.size.width;
    CGRect frame = CGRectMake(0.f, 0.f,
                              self.volume*self.backgroundLayer.bounds.size.width,
                              self.backgroundLayer.bounds.size.height);
    self.volumeLayer.frame = frame;
    
    if (_volume && self.volumeBeforeMute) {
        self.volumeBeforeMute = 0.f;
        _isMuted = NO;
    }
}

- (void)mute {
    self.volumeBeforeMute = self.volume;
    self.volume = 0.f;
    
    _isMuted = YES;
}

- (void)unmute {
    self.volume = self.volumeBeforeMute;
    self.volumeBeforeMute = 0.f;
    
    _isMuted = NO;
}

#pragma mark - Positioning and Layout

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (layer == self.layer)
        [self layoutSublayers];
}

-(void)layoutSublayers
{
    self.backgroundLayer.frame = self.bounds;
    self.backgroundLayer.cornerRadius = self.bounds.size.height/2.f;
    
    self.volumeLayer.frame = CGRectMake(0.f, 0.f,
                                        self.volume*self.backgroundLayer.bounds.size.width,
                                        self.backgroundLayer.bounds.size.height);
    self.volumeLayer.cornerRadius = self.bounds.size.height/2.f;
}

#pragma mark - Gesture Handlers

-(void)tapGesture:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapPoint = [tapRecognizer locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, tapPoint) &&
        tapRecognizer.state == UIGestureRecognizerStateEnded) {
        self.volume = tapPoint.x/self.bounds.size.width;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)panGesture:(UIPanGestureRecognizer *)panRecognizer
{
    static float oldValue = 0.f;
    
    CGFloat offsetX = [panRecognizer translationInView:self].x;
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGFloat locationX = [panRecognizer locationInView:self].x;
            float value = [self volumeWithX:locationX];
            if (ABS(self.volume - value) > 0.1f) {
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                self.volume = value;
                [CATransaction commit];
            }
            
            oldValue = self.volume;
            
            [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            self.volume = oldValue + [self volumeWithX:offsetX];
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

-(CGFloat)volumeWithX:(CGFloat)x
{
    return x/self.bounds.size.width;
}

@end
