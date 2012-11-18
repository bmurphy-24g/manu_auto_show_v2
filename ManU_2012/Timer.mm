//
//  Timer.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"


@implementation Timer

-(id) spawn:(CCLayer *)layer {
    if ((self=[super init])) {
        _winSize = [CCDirector sharedDirector].winSize;
        
        NSLog(@"Spawn timer");
        
        parentLayer = layer;
        _timerLabel = [CCLabelTTF labelWithString:@"01:30" fontName:@"Arial" fontSize:42];
        _timerLabel.position = ccp(512, 118);
        [_timerLabel retain];
        
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:1.0f paused:YES];
    }
    return self;
}

bool gameIsOver = false;
-(void) tick:(ccTime) dt{
    if(seconds <= 0)
    {
        
        seconds = 60;
        if(minutes <=0 )
        {
            //Game Over!
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"GameOver"
             object:nil ];
            seconds = 0;
            minutes = 0;
            [self stopTimer];
            [_timerLabel setString: [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
            gameIsOver = true;
        }
        minutes--;
        
    }
    if(seconds == 30 && minutes == 0)
    {
        NSLog(@"Speed it up!");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SpeedUp"
         object:nil ];
    }
    seconds--;
    if(!gameIsOver)
        [_timerLabel setString: [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
}

-(void)stopTimer
{
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [self hide];
}

-(void)startTimer {
    gameIsOver = false;
    seconds = 30;
    minutes = 1;
    [self show];
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
    
}

-(void)show {
    [_timerLabel setString:@"01:30"];
    [parentLayer addChild: _timerLabel z:0 tag:96666];
}

-(void)hide {
    [parentLayer removeChildByTag:96666 cleanup:NO];
}

-(void)dealloc
{
    NSLog(@"Timer Dealloc");
    //[[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(tick:) forTarget:self];
    [_timerLabel release];
    [super dealloc];
}

@end
