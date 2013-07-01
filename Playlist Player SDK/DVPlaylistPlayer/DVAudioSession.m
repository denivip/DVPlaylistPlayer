//
//  DVAudioSession.m
//  Playlist Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVAudioSession.h"
#import <AudioToolbox/AudioSession.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static void audioRouteChangeListenerCallback(void *inUserData,
                                             AudioSessionPropertyID inPropertyID,
                                             UInt32 inPropertyValueSize,
                                             const void *inPropertyValue);

static void audioVolumeChangeListenerCallback(void *inUserData,
                                              AudioSessionPropertyID inPropertyID,
                                              UInt32 inPropertyValueSize,
                                              const void *inPropertyValue);

@implementation DVAudioSession

+ (instancetype)defaultSession
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    if (self = [super init]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        if (! [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]) {
            self.error = error;
            return self;
        }
        
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if (&AVAudioSessionModeMoviePlayback != NULL) { // ios 6 only
            error = nil;
            if (! [audioSession setMode:AVAudioSessionModeMoviePlayback error:&error]) {
                self.error = error;
                return self;
            }
        }
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
        
        error = nil;
        if (! [audioSession setActive:YES error:&error]) {
            self.error = error;
            return self;
        }
        
        OSStatus s;
        
        s = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                            audioRouteChangeListenerCallback,
                                            (__bridge void *)self);
        if (s != kAudioSessionNoError) {
            self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:s userInfo:nil];
            return self;
        }
        
        s = AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                            audioVolumeChangeListenerCallback,
                                            (__bridge void *)self);
        if (s != kAudioSessionNoError) {
            self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:s userInfo:nil];
            return self;
        }
    }
    
    return self;
}

#pragma mark - Public

- (BOOL)isMuted
{
    CFStringRef route;
    UInt32 routeSize = sizeof(CFStringRef);
    BOOL muted = NO;
    
    OSStatus s = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route);
    if (s != kAudioSessionNoError) {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:s userInfo:nil];
        return muted;
    }
    
    if (route == NULL || !CFStringGetLength(route)) {
        muted = YES;
    }
    
    if (route != NULL) {
        CFRelease(route);
    }
    
    return muted;
}

- (void)setMuted:(BOOL)muted
{
    
}

+ (NSSet *)keyPathsForValuesAffectingMuted
{
    return [NSSet setWithObject:@"isMuted"];
}

- (float)volume
{
    return [[MPMusicPlayerController applicationMusicPlayer] volume];
}

- (void)setVolume:(float)volume
{
    [MPMusicPlayerController applicationMusicPlayer].volume = volume;
}

@end

static void audioRouteChangeListenerCallback(void *inUserData,
                                             AudioSessionPropertyID inPropertyID,
                                             UInt32 inPropertyValueSize,
                                             const void *inPropertyValue)
{
    if (inPropertyID == kAudioSessionProperty_AudioRouteChange) {
        DVAudioSession *owner = (__bridge DVAudioSession *)inUserData;
        [owner willChangeValueForKey:@"muted"];
        [owner didChangeValueForKey:@"muted"];
    }
}


static void audioVolumeChangeListenerCallback(void *inUserData,
                                              AudioSessionPropertyID inPropertyID,
                                              UInt32 inPropertyValueSize,
                                              const void *inPropertyValue)
{
    if (inPropertyID == kAudioSessionProperty_CurrentHardwareOutputVolume) {
        DVAudioSession *owner = (__bridge DVAudioSession *)inUserData;
        [owner willChangeValueForKey:@"volume"];
        [owner didChangeValueForKey:@"volume"];
    }
}