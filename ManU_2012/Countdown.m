//
//  Countdown.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Countdown.h"


@implementation Countdown
-(id) spawn:(CCLayer *)layer {
    if ((self=[super init])) {
        _winSize = [CCDirector sharedDirector].winSize;
        
        NSLog(@"Spawn timer");
        
        parentLayer = layer;
        
        _timerLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:250];
        _timerLabel.position = ccp(512, 384);
        [_timerLabel retain];
        
        NSString *boopPath = [NSString stringWithFormat:@"%@/boop.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *boopURL = [NSURL fileURLWithPath:boopPath];
        NSString* error;
        boopPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:boopURL error:&error];
        boopPlayer.numberOfLoops = 0;
        
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:1.0f paused:YES];
    }
    return self;
}

-(void) tick:(ccTime) dt{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [boopPlayer play];
    });
    seconds--;
    [_timerLabel setString:[NSString stringWithFormat:@"%d", seconds]];
    if(seconds == 0)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"StartGame"
         object:nil ];
        [self stopCountdown];
    }
    
}

-(void)startCountdown {
    seconds = 6;
    [_timerLabel setString:@"5"];
    [parentLayer addChild:_timerLabel z:0 tag:77777];
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
}

-(void)stopCountdown {
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [parentLayer removeChildByTag:77777 cleanup:NO];
}

-(void)dealloc
{
    [_timerLabel release];
    [super dealloc];
}
@end
