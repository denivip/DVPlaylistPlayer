//
//  DVPlaylistPlayer.h
//  Playlist Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DVQueuePlayerState) {
    DVQueuePlayerStateStop,
    DVQueuePlayerStatePause,
    DVQueuePlayerStateBuffering,
    DVQueuePlayerStatePlaying
};

@protocol DVPlaylistPlayerDataSource, DVPlaylistPlayerDelegate;

@interface DVPlaylistPlayer : NSObject

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, weak) id<DVPlaylistPlayerDataSource> dataSource;
@property (nonatomic, weak) id<DVPlaylistPlayerDelegate> delegate;
@property (nonatomic, readonly, strong) UIView *playerView;
@property (nonatomic) float volume;
@property (nonatomic, readonly, getter = isMuted) BOOL muted;
@property (nonatomic, readonly) DVQueuePlayerState state;
@property (nonatomic, readonly) NSInteger currentItemIndex;

- (void)playMediaAtIndex:(NSInteger)index;
- (void)resume;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)mute;
- (void)unmute;

- (void)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block;

@end

@protocol DVPlaylistPlayerDataSource <NSObject>

@required
- (NSUInteger)numberOfPlayerItems;
- (AVPlayerItem *)queuePlayer:(DVPlaylistPlayer *)queuePlayer playerItemAtIndex:(NSInteger)index;

@end

@protocol DVPlaylistPlayerDelegate <NSObject>

@optional
- (void)queuePlayerDidStartPlaying:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidResumePlaying:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidPausePlaying:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidStopPlaying:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidCompletePlaying:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidMoveToNext:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidMoveToPrevious:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerBuffering:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidMute:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidUnmute:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerDidChangeVolume:(DVPlaylistPlayer *)queuePlayer;
- (void)queuePlayerFailedToPlay:(DVPlaylistPlayer *)queuePlayer withError:(NSError *)error;

@end