//
//  GKHelper.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GKHelper.h"


@implementation GKHelper
@synthesize label, timerLink;
GKPeerPickerController *picker;
GKSession* session;
BOOL isFirstPlayer;
int scoreForServer, scoreForClient;

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker
		   sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    session = [[GKSession alloc] initWithSessionID:@"ManU_2012" displayName:nil sessionMode:GKSessionModePeer];
    session.delegate = self;
    
    [session setDataReceiveHandler: self withContext:nil];
    //session.available = YES;
    return session;
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    isFirstPlayer = YES;
    label.text = @"server";
}

-(void) connectToPeer
{
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    /*NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if ([unarchiver containsValueForKey:@"x"])
    {
        float x =[unarchiver decodeFloatForKey:@"x"];
        float newX = 0;
        
        if ((isOtherPartyAnIpad && screenSizeX == 768) || (!isOtherPartyAnIpad && screenSizeX == 320))
            newX = screenSizeX - x;
        else // different screen config
        {
            if (isOtherPartyAnIpad) // other is iPad, ours not, needs division
                newX = screenSizeX  - x / (768.0/320.0);
            else // other is not iPad, ours is, needs multiplication
                newX = screenSizeX  - x * (768.0/320.0);
        }
        pad2.center = CGPointMake( newX, pad2.center.y );
    }
    else if ([unarchiver containsValueForKey:@"bx"] && !isFirstPlayer) // ball coordinates; only need to be displayed in the second player
    {
        if ((isOtherPartyAnIpad && screenSizeX == 768) || (!isOtherPartyAnIpad && screenSizeX == 320))
            ball.center = CGPointMake(screenSizeX-[unarchiver decodeFloatForKey:@"bx"], screenSizeY-[unarchiver decodeFloatForKey:@"by"]+yTranslationBecauseOfVisibleStatusBar-10);
        else // different screen config
        {
            if (isOtherPartyAnIpad) // other is iPad, ours not, needs division,
            {
                float newY =  screenSizeY- [unarchiver decodeFloatForKey:@"by"] / (1024.0/480.0);
                newY = newY - 480/2; newY = newY/1.333; newY = newY + 480/2;
                ball.center = CGPointMake(screenSizeX-[unarchiver decodeFloatForKey:@"bx"] / (768.0/320.0),
                                          newY
                                          +yTranslationBecauseOfVisibleStatusBar-10);
            }
            else // other is not iPad, ours is, needs multiplication
            {   float newY =  screenSizeY- [unarchiver decodeFloatForKey:@"by"] * (1024.0/480.0);
                newY = newY - 1024/2; newY = newY*1.333; newY = newY + 1024/2;
                ball.center = CGPointMake(screenSizeX-[unarchiver decodeFloatForKey:@"bx"] * (768.0/320.0),
                                          newY
                                          +yTranslationBecauseOfVisibleStatusBar* 2-10);
            }
        }
    }
    else if ([unarchiver containsValueForKey:@"sx"]) // score
        label.text = [NSString stringWithFormat:@"You: %.0f, other: %.0f", [unarchiver decodeFloatForKey:@"sx"], [unarchiver decodeFloatForKey:@"sy"]];
    else if ([unarchiver containsValueForKey:@"ix"]) // iPad
        isOtherPartyAnIpad = YES;*/
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)currSession {
	[session setDataReceiveHandler:self withContext:NULL];
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
    [self sendXYPair:1.0f newY:1.0f keyPrefix:@"i" needsReliable:YES];
}

-(void)sendXYPair:(float)x newY:(float)y keyPrefix:(NSString*)prefix needsReliable:(BOOL)reliable
{
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
	[archiver encodeFloat:x forKey: [prefix stringByAppendingString:@"x"]];
    [archiver encodeFloat:y forKey:[prefix stringByAppendingString:@"y"]];
	[archiver finishEncoding];
    if (reliable)
    	[session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
    else
        [session sendDataToAllPeers: dataToSend withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
    
    if ([prefix isEqualToString:@"s"]) label.text = [NSString stringWithFormat:@"You: %i, other: %i", scoreForServer, scoreForClient];
}


@end
