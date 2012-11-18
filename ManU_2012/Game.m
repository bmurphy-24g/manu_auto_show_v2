//
//  Game.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Game.h"


@implementation Game

GKSession* _session;
NSString* player;

-(void)startGameWithSession:(GKSession *)session player:(NSString*)playerNum
{
    _session = session;
    player = playerNum;
}

-(void)sendXAccel:(float)x needsReliable:(BOOL)reliable{
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
	[archiver encodeFloat:x forKey: [player stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    if (reliable)
    	[_session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
    else
        [_session sendDataToAllPeers: dataToSend withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

@end
