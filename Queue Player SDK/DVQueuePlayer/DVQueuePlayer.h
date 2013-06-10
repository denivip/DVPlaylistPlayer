//
//  DVQueuePlayer.h
//  Queue Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DVQueuePlayerState) {
    DVQueuePlayerStateStop,
    DVQueuePlayerStatePlaying
};

@protocol DVQueuePlayerDataSource, DVQueuePlayerDelegate;

@interface DVQueuePlayer : NSObject

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, weak) id<DVQueuePlayerDataSource> dataSource;
@property (nonatomic, weak) id<DVQueuePlayerDelegate> delegate;
@property (nonatomic, readonly, strong) UIView *playerView;
@property (nonatomic) float volume;
@property (nonatomic, readonly, getter = isMuted) BOOL muted;
@property (nonatomic) DVQueuePlayerState state;
@property (nonatomic, readonly) NSUInteger currentItemIndex;

- (void)playMediaWithIndex:(NSUInteger)index;
- (void)resume;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)mute;
- (void)unmute;

- (void)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block;

@end

@protocol DVQueuePlayerDataSource <NSObject>

@required
- (NSUInteger)numberOfPlayerItems;
- (AVPlayerItem *)queuePlayer:(DVQueuePlayer *)queuePlayer playerItemForIndex:(NSUInteger)index;

@end

@protocol DVQueuePlayerDelegate <NSObject>

@optional
- (void)queuePlayer:(DVQueuePlayer *)queuePlayer didUpdateProgress:(DVProgress)progress;

@end