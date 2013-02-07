//
//  Countdown.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Countdown : CCLayer {
    CCLabelTTF *_timerLabel;
    int seconds;
    CGSize _winSize;
    CCLayer *parentLayer;
    AVAudioPlayer *boopPlayer;
}
-(id) spawn: (CCLayer*) layer;
-(void)pauseTimer;
-(void)startCountdown;
-(void)stopCountdown;
-(void)clear;

@end
