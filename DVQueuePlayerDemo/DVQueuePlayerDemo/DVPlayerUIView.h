//
//  DVPlayerUIView.h
//  DVQueuePlayerDemo
//
//  Created by Mikhail Grushin on 10.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVPlayerVolumeBar.h"
#import "DVPlayerSeekBar.h"

@interface DVPlayerUIView : UIView

@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) DVPlayerVolumeBar *volumeBar;
@property (nonatomic, strong) DVPlayerSeekBar *seekBar;

@property (nonatomic, strong) UIButton *durationButton;
@property (nonatomic, strong) UIButton *elapsedButton;
@property (nonatomic) NSTimeInterval elapsed;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) CGFloat volume;

@property (nonatomic) BOOL playingAD;

@end
