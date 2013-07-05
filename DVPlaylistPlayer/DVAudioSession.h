//
//  DVAudioSession.h
//  Playlist Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVAudioSession : NSObject

+ (instancetype)defaultSession;
@property (nonatomic, assign, getter = isMuted) BOOL muted;
@property (nonatomic, assign) float volume;
@property (nonatomic, strong) NSError *error;

@end
