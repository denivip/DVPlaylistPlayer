//
//  DVPlayerVolumeBar.h
//  DVPlaylistPlayerDemo
//
//  Created by Mikhail Grushin on 10.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVPlayerVolumeBar : UIControl

@property (nonatomic) CGFloat volume; //0...1
@property (nonatomic, readonly) BOOL isMuted;

- (void)mute;
- (void)unmute;

@end
