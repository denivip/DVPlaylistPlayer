//
//  DVPlayerUIView.m
//  DVPlaylistPlayerDemo
//
//  Created by Mikhail Grushin on 10.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVPlayerUIView.h"
#import "DVPlayerSeekBar.h"
#import "DVPlayerVolumeBar.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE 14.f
#define BUTTONS_HORIZONTAL_SIZE_MULT 2.f
#define BUTTONS_VERTICAL_SIZE_MULT 1.5f
#define BUTTONS_BETWEEN_SPACE 6.f
#define BUTTONS_CORNER_RADIUS 6.f

@interface DVPlayerUIView()

@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) UILabel *volumeLabel;

@end

@implementation DVPlayerUIView

-(CALayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.frame = self.bounds;
        _backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.f
                                                             alpha:.7f].CGColor;
        _backgroundLayer.borderWidth = 2.f;
        _backgroundLayer.borderColor = [UIColor whiteColor].CGColor;
        _backgroundLayer.cornerRadius = 8.f;
    }
    
    return _backgroundLayer;
}

-(DVPlayerSeekBar *)seekBar
{
    if (!_seekBar) {
        _seekBar = [[DVPlayerSeekBar alloc] initWithFrame:CGRectZero];
        _seekBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return _seekBar;
}

-(DVPlayerVolumeBar *)volumeBar
{
    if (!_volumeBar) {
        _volumeBar = [[DVPlayerVolumeBar alloc] initWithFrame:CGRectZero];
    }
    
    return _volumeBar;
}

-(UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.backgroundColor = [UIColor lightGrayColor];
        _playButton.layer.cornerRadius = BUTTONS_CORNER_RADIUS;
        _playButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:FONT_SIZE];
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
        [_playButton setTitle:@"Pause" forState:UIControlStateSelected];
        [_playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        [_playButton sizeToFit];
        
        CGRect frame = _playButton.frame;
        frame.size = CGSizeMake(frame.size.width*BUTTONS_HORIZONTAL_SIZE_MULT,
                                frame.size.height*BUTTONS_VERTICAL_SIZE_MULT);
        _playButton.frame = frame;
    }
    
    return _playButton;
}

-(UIButton *)stopButton
{
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopButton.backgroundColor = [UIColor lightGrayColor];
        _stopButton.layer.cornerRadius = BUTTONS_CORNER_RADIUS;
        _stopButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:FONT_SIZE];
        [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_stopButton sizeToFit];
        
        CGRect frame = _stopButton.frame;
        frame.size = CGSizeMake(frame.size.width*BUTTONS_HORIZONTAL_SIZE_MULT,
                                frame.size.height*BUTTONS_VERTICAL_SIZE_MULT);
        _stopButton.frame = frame;
    }
    
    return _stopButton;
}

-(UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _prevButton.backgroundColor = [UIColor lightGrayColor];
        _prevButton.layer.cornerRadius = BUTTONS_CORNER_RADIUS;
        _prevButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:FONT_SIZE];
        [_prevButton setTitle:@"Prev" forState:UIControlStateNormal];
        [_prevButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_prevButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_prevButton sizeToFit];
        
        CGRect frame = _prevButton.frame;
        frame.size = CGSizeMake(frame.size.width*BUTTONS_HORIZONTAL_SIZE_MULT,
                                frame.size.height*BUTTONS_VERTICAL_SIZE_MULT);
        _prevButton.frame = frame;
    }
    
    return _prevButton;
}

-(UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.backgroundColor = [UIColor lightGrayColor];
        _nextButton.layer.cornerRadius = BUTTONS_CORNER_RADIUS;
        _nextButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:FONT_SIZE];
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_nextButton sizeToFit];
        
        CGRect frame = _nextButton.frame;
        frame.size = CGSizeMake(frame.size.width*BUTTONS_HORIZONTAL_SIZE_MULT,
                                frame.size.height*BUTTONS_VERTICAL_SIZE_MULT);
        _nextButton.frame = frame;
    }
    
    return _nextButton;
}

-(UIButton *)muteButton
{
    if (!_muteButton) {
        _muteButton = [[UIButton alloc] init];
        _muteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _muteButton.backgroundColor = [UIColor colorWithRed:174.f/255
                                                      green:174.f/255
                                                       blue:174.f/255
                                                      alpha:1.f];
        [_muteButton setImage:[UIImage imageNamed:@"volume"] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"noVolume"] forState:UIControlStateSelected];
        _muteButton.imageView.layer.cornerRadius = 2.f;
        _muteButton.layer.cornerRadius = 2.f;
        
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(_muteButton.imageView.image.size.width/2.f,
                                _muteButton.imageView.image.size.height/2.f);
        _muteButton.frame = frame;
    }
    
    return _muteButton;
}

-(UIButton *)durationButton
{
    if (!_durationButton) {
        _durationButton = [[UIButton alloc] init];
        _durationButton.backgroundColor = [UIColor clearColor];
        _durationButton.titleLabel.backgroundColor = [UIColor colorWithRed:116.f/255
                                                                     green:171.f/255
                                                                      blue:216.f/255
                                                                     alpha:1.f];
        _durationButton.titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _durationButton.titleLabel.layer.borderWidth = 1.f;
        _durationButton.titleLabel.textColor = [UIColor whiteColor];
        _durationButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10.f];
        _durationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_durationButton setTitle:@"00:00:00" forState:UIControlStateNormal];
        [_durationButton sizeToFit];
        
        self.duration = 0.f;
    }
    
    return _durationButton;
}

-(UIButton *)elapsedButton
{
    if (!_elapsedButton) {
        _elapsedButton = [[UIButton alloc] init];
        _elapsedButton.backgroundColor = [UIColor clearColor];
        _elapsedButton.titleLabel.backgroundColor = [UIColor colorWithRed:116.f/255
                                                                    green:171.f/255
                                                                     blue:216.f/255
                                                                    alpha:1.f];
        _elapsedButton.titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _elapsedButton.titleLabel.layer.borderWidth = 1.f;
        _elapsedButton.titleLabel.textColor = [UIColor whiteColor];
        _elapsedButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10.f];
        _elapsedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_elapsedButton setTitle:@"00:00:00" forState:UIControlStateNormal];
        [_elapsedButton sizeToFit];
        
        self.elapsed = 0.f;
    }
    
    return _elapsedButton;
}

-(UILabel *)volumeLabel
{
    if (!_volumeLabel) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.textColor = [UIColor whiteColor];
        _volumeLabel.backgroundColor = [UIColor clearColor];
        _volumeLabel.textAlignment = NSTextAlignmentCenter;
        _volumeLabel.text = @"100";
        [_volumeLabel sizeToFit];
        _volumeLabel.text = [NSString stringWithFormat:@"%i", ((NSInteger)self.volumeBar.volume*100)];
    }
    
    return _volumeLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        [self.layer addSublayer:self.backgroundLayer];
        [self addSubview:self.playButton];
        [self addSubview:self.stopButton];
        [self addSubview:self.prevButton];
        [self addSubview:self.nextButton];
        [self addSubview:self.muteButton];
        [self addSubview:self.seekBar];
        [self addSubview:self.volumeBar];
        [self addSubview:self.durationButton];
        [self addSubview:self.elapsedButton];
        [self addSubview:self.volumeLabel];
    }
    return self;
}

-(void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    [self.durationButton setTitle:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:duration]]
                         forState:UIControlStateNormal];
}

-(void)setElapsed:(NSTimeInterval)elapsed
{
    _elapsed = elapsed;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    [self.elapsedButton setTitle:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:elapsed]]
                        forState:UIControlStateNormal];
}

-(void)setVolume:(CGFloat)volume
{
    _volume = MIN(MAX(0.f, volume), 1.f);
    
    self.volumeLabel.text = [NSString stringWithFormat:@"%i", (NSInteger)(volume*100)];
}

-(void)layoutSubviews {
    self.backgroundLayer.frame = self.bounds;
    self.seekBar.frame = CGRectMake(50.f,
                                    10.f,
                                    self.bounds.size.width - 100.f,
                                    12.f);
    
    self.elapsedButton.frame = CGRectMake(CGRectGetMinX(self.seekBar.frame) - self.elapsedButton.bounds.size.width - 2.f,
                                          self.seekBar.frame.origin.y,
                                          self.elapsedButton.bounds.size.width,
                                          self.seekBar.bounds.size.height);
    self.elapsedButton.titleLabel.layer.cornerRadius = self.elapsedButton.bounds.size.height/4.f;
    
    self.durationButton.frame = CGRectMake(CGRectGetMaxX(self.seekBar.frame)+2.f,
                                           self.seekBar.frame.origin.y,
                                           self.durationButton.bounds.size.width,
                                           self.seekBar.bounds.size.height);
    self.durationButton.titleLabel.layer.cornerRadius = self.durationButton.bounds.size.height/4.f;
    
    self.volumeBar.frame = CGRectMake(self.seekBar.frame.origin.x,
                                      self.bounds.size.height - 20.f,
                                      self.seekBar.frame.size.width,
                                      10.f);
    
    self.volumeLabel.center = CGPointMake(CGRectGetMaxX(self.volumeBar.frame) + 6.f + CGRectGetMidX(self.volumeLabel.bounds),
                                          self.volumeBar.center.y);
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds),
                                 CGRectGetMidY(self.bounds));
    
    self.playButton.center = CGPointMake(center.x - self.playButton.bounds.size.width/2 - BUTTONS_BETWEEN_SPACE/2,
                                         center.y);
    
    self.prevButton.center = CGPointMake(self.playButton.center.x - BUTTONS_BETWEEN_SPACE - self.prevButton.bounds.size.width,
                                         center.y);
    
    self.stopButton.center = CGPointMake(self.playButton.center.x + BUTTONS_BETWEEN_SPACE + self.stopButton.bounds.size.width,
                                         center.y);
    
    self.nextButton.center = CGPointMake(self.stopButton.center.x + self.nextButton.bounds.size.width + BUTTONS_BETWEEN_SPACE,
                                         center.y);
    
    self.muteButton.center = CGPointMake(self.volumeBar.frame.origin.x - self.muteButton.bounds.size.width/2.f - 6.f,
                                         self.volumeBar.center.y);
}

@end
