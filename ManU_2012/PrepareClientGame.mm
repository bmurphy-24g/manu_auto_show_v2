//
//  PrepareClientGame.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PrepareClientGame.h"
#import "StartScene.h"

#define NONE 666665
#define LEFT 666666
#define RIGHT 666667
#define UP 666668
#define DOWN 666669

@implementation PrepareClientGame
bool receivedGameOver = NO, exitPressed = NO, receivedStartOnePlayer = NO, receivedStartTwoPlayer = NO;
int currentStickState;
@synthesize playerImage, playerName, playerPosition, playerFirstName, playerLastName, playerNumber, cloudFileName;
-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"blank.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:0];
        receivedGameOver = NO;
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(777, 264, 246, 195)];
        //[newView addSubview:imageView];
        //[imageView setBackgroundColor:[UIColor whiteColor]];
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 701, 289, 67)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:exitButton];
        
        //219x106
        startOnePlayer = [[UIButton alloc] initWithFrame:CGRectMake(1024-219, 0, 219, 106)];
        [startOnePlayer setBackgroundImage:[UIImage imageNamed:@"1player_btn.png"] forState:UIControlStateNormal];
        [startOnePlayer addTarget:self action:@selector(onePlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //253x106
        startGameButton = [[UIButton alloc] initWithFrame:CGRectMake(1024-253, 0, 253, 106)];
        [startGameButton setBackgroundImage:[UIImage imageNamed:@"statgame_btn.png"] forState:UIControlStateNormal];
        [startGameButton addTarget:self action:@selector(startGamePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _matchmakingClient = [[MatchmakingClient alloc] init];
        _matchmakingClient.delegate = self;
		[_matchmakingClient startSearchingForServersWithSessionID:SESSION_ID];
        [_matchmakingClient.session setDataReceiveHandler:self withContext:nil];
        receivedPlayer = NO, receivedGameOver = NO, receivedScore = NO, receivedShots = NO, gameStarting = NO;
        receivedStartOnePlayer = NO; receivedStartTwoPlayer = NO;
        exitPressed = NO;
        
        bluetoothManager = [BluetoothManager sharedInstance];
        
        currentStickState = NONE;
        
        xAccelToSend = 0.0f;
	}
	return self;
}
-(IBAction)startGamePressed:(id)sender
{
    //[bluetoothManager setEnabled:YES];
    //[bluetoothManager setPowered:YES];
    [self sendName:@"TWO" needsReliable:YES :serverPeerID];
    [startGameButton removeFromSuperview];
}
-(IBAction)onePlayerPressed:(id)sender
{
    receivedStartOnePlayer = YES;
    receivedStartTwoPlayer = YES;
    
    [self sendName:@"ONE" needsReliable:YES :serverPeerID];
    [startOnePlayer removeFromSuperview];
}
+(CCScene*) scene:(UIImage *)img :(NSString *)name :(NSString *)position :(NSString *)number :(NSString *)firstName :(NSString *)lastName :(NSString *)fileName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PrepareClientGame *layer = [PrepareClientGame node];
	[layer initVariables:img :name :position :number :firstName :lastName :fileName];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(IBAction)exitButtonPressed:(id)sender
{
    NSLog(@"exit pressed");
    exitPressed = YES;
    [newView removeFromSuperview];
    [_matchmakingClient disconnectFromServer];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

-(void)initVariables :(UIImage*)newImage :(NSString*)newName :(NSString *)pos :(NSString *)num :(NSString *)fName :(NSString *)lName :(NSString *)file
{
    self.playerImage = newImage;
    self.playerPosition = pos;
    self.playerNumber = num;
    self.playerFirstName = fName;
    self.playerLastName = lName;
    self.cloudFileName = file;
    playerName = newName;
    NSLog(@"%@", self.cloudFileName);
    NSLog(@"%@", self.playerFirstName);
    NSLog(@"%@", self.playerLastName);
    NSLog(@"%@", self.playerPosition);
    NSLog(@"%@", self.playerNumber);
}

- (void)startAccelerometer {
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = 0.25;
}

- (void)stopAccelerometer {
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    NSLog(@"accelerometer %f", acceleration.x);
    [self sendXAccel:acceleration.x needsReliable:YES];
}

-(void)sendXAccel:(float)x needsReliable:(BOOL)reliable{
    NSLog(@"Should be sending %f", x);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
	[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    if (reliable)
    	[_matchmakingClient.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
    else
        [_matchmakingClient.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

-(void)sendImage:(UIImage*)imageToSend needsReliable:(BOOL)reliable:(NSString*)peer{
    NSLog(@"Should be sending image to %@", peer);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = UIImageJPEGRepresentation(imageToSend, 10);
    [archiver encodeDataObject:data];
	//[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    NSMutableArray* peerArray;
    peerArray = [NSMutableArray arrayWithCapacity:1];
    peerArray[0] = peer;
    if (reliable)
    {
    	//[_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
        [_matchmakingClient.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingClient.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

-(void)sendName:(NSString*)nameToSend needsReliable:(BOOL)reliable:(NSString*)peer{
    //[bluetoothManager setEnabled:YES];
    //[bluetoothManager setPowered:YES];
    NSLog(@"Should be sending %@", nameToSend);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = [nameToSend dataUsingEncoding:NSASCIIStringEncoding];
    [archiver encodeDataObject:data];
    [archiver finishEncoding];
    NSMutableArray* peerArray;
    peerArray = [NSMutableArray arrayWithCapacity:1];
    peerArray[0] = peer;
    if (reliable)
    {
    	//[_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
        [_matchmakingClient.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingClient.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

- (void)dealloc
{
    NSLog(@"client game dealloc");
    [newView removeFromSuperview];
    _matchmakingClient.delegate = nil;
    [super dealloc];
}

#pragma mark - MatchmakingClientDelegate

//Update lists of available servers
- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID
{
    NSLog(@"%@",peerID);
    [_matchmakingClient connectToServerWithPeerID:peerID];
}

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID
{
	//[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client didConnectToServer:(NSString *)peerID
{
    NSLog(@"Connected to server!");
    serverPeerID = peerID;
}

- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID
{
	NSLog(@"Disconnected from server...");
    //[bluetoothManager setEnabled:NO];
    //[bluetoothManager setPowered:NO];
    if(!receivedGameOver && !exitPressed)
    {
        [newView removeFromSuperview];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
    }
    
}

- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client
{
	//_quitReason = QuitReasonNoNetwork;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"Game: connection request from peer %@", peerID);
#endif
    
	[session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
    
	// Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: session failed %@", error);
#endif
}

#pragma mark - GKSession Data Receive Handler



- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    if(!receivedPlayer && serverPeerID == peerID)
    {
        receivedPlayer = YES;
        NSData* decodedData = [unarchiver decodeDataObject];
        NSString* player = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
        playerPref = player;
        serverPeerID = peerID;
        NSLog(@"String received: %@", player);
        [self sendImage:self.playerImage needsReliable:YES :peerID];
        NSString* name = @"";
        name = [NSString stringWithFormat:@"%@ ", self.playerFirstName];
        if([self.playerLastName length] > 0)
            name = [NSString stringWithFormat:@"%@%@", name, [self.playerLastName substringToIndex:1]];
        [self sendName:name needsReliable:YES :peerID];
        //[self sendName:self.playerName needsReliable:YES :peerID];
    }
    else if (!receivedStartOnePlayer && serverPeerID == peerID && [playerPref isEqualToString:@"1"])
    {
        NSLog(@"SHould show start one player");
        receivedStartOnePlayer = YES;
        [newView addSubview:startOnePlayer];
    }
    else if (!receivedStartTwoPlayer && serverPeerID == peerID && [playerPref isEqualToString:@"1"])
    {
        NSLog(@"SHould show start game button");
        receivedStartTwoPlayer = YES;
        [startOnePlayer removeFromSuperview];
        [newView addSubview:startGameButton];
    }
    else if (!gameStarting && serverPeerID == peerID)
    {
        NSLog(@"game starting...");
        gameStarting = YES;
        
        //[self startAccelerometer];
        
        iCadeReaderView *control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
        [newView addSubview:control];
        control.active = YES;
        control.delegate = self;
        [control release];
        sendICadeTimer = [NSTimer alloc];
        sendICadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.33
                                         target:self
                                       selector:@selector(sendICadeDataToServer)
                                       userInfo:nil
                                        repeats:YES];
    }
    else if (!receivedGameOver && serverPeerID == peerID)
    {
        NSLog(@"game stopping...");
        [self stopAccelerometer];
        receivedGameOver = YES;
        [sendICadeTimer invalidate];
    }
    else if (!receivedScore && serverPeerID == peerID)
    {
        NSLog(@"Received score");
        NSData* decodedData = [unarchiver decodeDataObject];
        NSString* scoreReceived = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
        score = scoreReceived;
        receivedScore = YES;
    }
    else if (!receivedShots && serverPeerID == peerID)
    {
        NSLog(@"Received shots...");
        receivedShots = YES;
        NSData* decodedData = [unarchiver decodeDataObject];
        NSString* shotsReceived = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
        shotsOnGoal = shotsReceived;
        [newView removeFromSuperview];
        [_matchmakingClient disconnectFromServer];
        receivedGameOver = YES;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[FinalShareScene scene:self.cloudFileName :self.playerFirstName :self.playerLastName :self.playerNumber :self.playerPosition :score :shotsOnGoal :self.playerImage] withColor:ccWHITE]];
        
    }
    [unarchiver release];
}

- (BOOL) connectedToInternet
{
    NSString *TheUrl = @"http://www.google.com";
    NSURL *url = [NSURL URLWithString:TheUrl];
    NSError* error = nil;
    NSString* text = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    return ( text != NULL ) ? YES : NO;
}

-(void)sendICadeDataToServer
{
    [self sendXAccel:xAccelToSend needsReliable:NO];
}

- (void)setState:(BOOL)state forButton:(iCadeState)button {
    switch (button) {
        case iCadeJoystickUp:
            if(currentStickState == UP)
            {
                currentStickState = NONE;
                xAccelToSend = 0.0f;
                [self sendXAccel:0.0f needsReliable:NO];
            }
            else
            {
                currentStickState = UP;
                xAccelToSend = -0.3f;
                [self sendXAccel:-0.3f needsReliable:NO];
            }
            break;
        case iCadeJoystickRight:
            if(currentStickState == RIGHT)
                currentStickState = NONE;
            else
            {
                currentStickState = RIGHT;
                NSLog(@"RIGHT");
            }
            break;
        case iCadeJoystickDown:
            if(currentStickState == DOWN)
            {
                currentStickState = NONE;
                xAccelToSend = 0.0f;
                [self sendXAccel:0.0f needsReliable:NO];
            }
            else
            {
                currentStickState = DOWN;
                xAccelToSend = 0.3f;
                [self sendXAccel:0.3f needsReliable:NO];
                NSLog(@"DOWN");
            }
            break;
        case iCadeJoystickLeft:
            if(currentStickState == LEFT)
                currentStickState = NONE;
            else
            {
                currentStickState = LEFT;
                NSLog(@"LEFT");
            }
            break;
            
        default:
            break;
    }
    if(currentStickState == NONE)
        NSLog(@"NONE");
}

- (void)buttonDown:(iCadeState)button {
    [self setState:YES forButton:button];
}

- (void)buttonUp:(iCadeState)button {
    [self setState:NO forButton:button];
}
@end
