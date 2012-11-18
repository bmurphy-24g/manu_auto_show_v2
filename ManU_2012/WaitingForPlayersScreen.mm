//
//  WaitingForPlayersScreen.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WaitingForPlayersScreen.h"

bool gameOverNaturally;
@implementation WaitingForPlayersScreen

int LEFT_PLAYER_TAG = 6221, RIGHT_PLAYER_TAG = 6223;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	WaitingForPlayersScreen *layer = [WaitingForPlayersScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
                
        //Still need to handle error
        NSError *error = nil;
        
        winSize = [CCDirector sharedDirector].winSize;
		
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        // 89x264 146x195
        playerOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(89, 263, 146, 195)];
        
        // 777x264
        playerTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(777, 263, 146, 195)];
        
        // 10x470
        playerOneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 469, 333, 45)];
        
        playerTwoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(700, 469, 333, 45)];
        
        // 524x157
        startGameButton = [[UIButton alloc] initWithFrame:CGRectMake(524, 157, 253, 106)];
        
        startOnePlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(524, 157, 253, 106)];
        
        NSString *singlePath = [NSString stringWithFormat:@"%@/whistle1.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *singleURL = [NSURL fileURLWithPath:singlePath];
        singleWhistlePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:singleURL error:&error];
        singleWhistlePlayer.numberOfLoops = 0;
        
        NSString *triplePath = [NSString stringWithFormat:@"%@/whistle3.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *tripleURL = [NSURL fileURLWithPath:triplePath];
        tripleWhistlePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tripleURL error:&error];
        tripleWhistlePlayer.numberOfLoops = 0;
        
        NSString *crowdPath = [NSString stringWithFormat:@"%@/cheer.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *crowdURL = [NSURL fileURLWithPath:crowdPath];
        crowdPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:crowdURL error:&error];
        crowdPlayer.numberOfLoops = 0;
        
        // 201x97 35x45
        smallPlayerOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(201, 97, 35, 45)];
        [smallPlayerOneImageView retain];
        
        // 785x97 35x45
        smallPlayerTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(785, 97, 35, 45)];
        [smallPlayerTwoImageView retain];
        
        //236x97 185x45
        smallPlayerOneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 97, 185, 45)];
        [smallPlayerOneNameLabel retain];
        
        //700x97 185x45 //822
        smallPlayerTwoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(586, 97, 185, 45)];
        [smallPlayerTwoNameLabel retain];
        
        playerOneImage = nil;
        [playerOneImage retain];
        playerTwoImage = nil;
        [playerTwoImage retain];
        
        countdown = [Countdown alloc];
        
        // init physics
        [self initPhysics];
        
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(update:) forTarget:self interval:0 paused:YES];
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:YES];
        
        ball = [Ball alloc];
        [ball spawn:self :world :groundBody];
        [self spawnPlayers];
        
        timer = [[Timer alloc] spawn:self];
        
        [countdown spawn:self];
        
        [self setUpWaitScreen];
	}
	return self;
}



#pragma mark Wait Screen

-(void)setUpWaitScreen
{
    playerOneImage = nil;
    playerOneName = @"";
    playerTwoImage = nil;
    playerTwoName = @"";
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    NSString *urlString = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/resources/ios_tracking.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:5.0f];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSLog(@"Talking to Kevin");
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        NSLog(@"Error");
    }
    NSLog(@"Finished talking to kevin");
    [request release];
    request = NULL;
    
    bg = [CCSprite spriteWithFile:@"begingame_background1.jpg"];
    bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:bg z:0 tag:420];

    [playerOneImageView setImage:[UIImage imageNamed:@"silhouette.png"]];
    [newView addSubview:playerOneImageView];
    
    [playerTwoImageView setImage:[UIImage imageNamed:@"silhouette.png"]];
    [newView addSubview:playerTwoImageView];
    
    [smallPlayerOneNameLabel setText:@""];
    [smallPlayerTwoNameLabel setText:@""];
    
    [playerOneNameLabel setBackgroundColor:[UIColor clearColor]];
    [playerOneNameLabel setTextColor:[UIColor whiteColor]];
    [playerOneNameLabel setMinimumScaleFactor:100];
    [playerOneNameLabel setText:@"Player 1"];
    [newView addSubview:playerOneNameLabel];
    
    [playerTwoNameLabel setBackgroundColor:[UIColor clearColor]];
    [playerTwoNameLabel setTextColor:[UIColor blackColor]];
    [playerTwoNameLabel setMinimumScaleFactor:100];
    [playerTwoNameLabel setText:@"Player 2"];
    [newView addSubview:playerTwoNameLabel];
    
    [startGameButton setBackgroundImage:[UIImage imageNamed:@"statgame_btn.png"] forState:UIControlStateNormal];
    [startGameButton addTarget:self action:@selector(startGamePressedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [startOnePlayerButton setBackgroundImage:[UIImage imageNamed:@"1player_btn.png"] forState:UIControlStateNormal];
    [startOnePlayerButton addTarget:self action:@selector(startOnePlayerPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_matchmakingServer == nil)
    {
        _matchmakingServer = [[MatchmakingServer alloc] init];
        _matchmakingServer.delegate = self;
        _matchmakingServer.maxClients = 2;
        [_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        [_matchmakingServer.session setDataReceiveHandler:self withContext:nil];
        NSLog(@"Started server...");
    }
    
    receivedPlayerOneImage = NO, receivedPlayerOneName = NO, receivedPlayerTwoImage = NO, receivedPlayerTwoName = NO, gameHasStarted = NO;
    receivedStartGame = NO;
    _leftScore_SERVER = 0, _rightScore_SERVER = 0;
    _leftShotsOnGoal_SERVER = 0, _rightShotsOnGoal_SERVER = 0;
    
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
    
    gameOverNaturally = NO;
    
    isSinglePlayerGame = NO;
}

bool isSinglePlayerGame = NO;
- (IBAction)startGamePressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Start Game Pressed");
    gameHasStarted = YES;
    [newView removeFromSuperview];
    [self setUpGame];
    
    [self sendToAll:@"Start" needsReliable:YES :@""];
}

-(IBAction)startOnePlayerPressedAction:(id)sender
{
    NSLog(@"One Player Pressed");
    isSinglePlayerGame = YES;
    gameHasStarted = YES;
    [newView removeFromSuperview];
    [self setUpGame];
    
    [self sendToAll:@"Start" needsReliable:YES :@""];
}

#pragma mark Game Scene

-(void) setUpGame
{
    [self removeChildByTag:420 cleanup:NO];
    NSLog(@"setUpGame");
    CGSize s = [CCDirector sharedDirector].winSize;
    winSize = s;
    
    bg = [CCSprite spriteWithFile:@"field.jpg"];
    bg.position = ccp(s.width/2, s.height/2);
    [self addChild:bg z:0 tag:666];
    
    //[startGameButton removeFromSuperview];
    //[startOnePlayerButton removeFromSuperview];
    [playerOneImageView removeFromSuperview];
    [playerTwoImageView removeFromSuperview];
    [playerOneNameLabel removeFromSuperview];
    [playerTwoNameLabel removeFromSuperview];
    //newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
    //[[[CCDirector sharedDirector] view] addSubview:newView];
    
    [[[CCDirector sharedDirector] view] addSubview:newView];
    
    [smallPlayerOneImageView setImage:playerOneImage];
    [newView addSubview:smallPlayerOneImageView];
    
    [smallPlayerTwoImageView setImage:playerTwoImage];
    [newView addSubview:smallPlayerTwoImageView];
    
    [smallPlayerOneNameLabel setTextColor:[UIColor whiteColor]];
    [smallPlayerOneNameLabel setBackgroundColor:[UIColor clearColor]];
    [smallPlayerOneNameLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    smallPlayerOneNameLabel.textAlignment = NSTextAlignmentLeft;
    smallPlayerOneNameLabel.text = playerOneName;
    [newView addSubview:smallPlayerOneNameLabel];
    
    [smallPlayerTwoNameLabel setTextColor:[UIColor whiteColor]];
    [smallPlayerTwoNameLabel setBackgroundColor:[UIColor clearColor]];
    [smallPlayerTwoNameLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    smallPlayerTwoNameLabel.textAlignment = NSTextAlignmentRight;
    smallPlayerTwoNameLabel.text = playerTwoName;
    [newView addSubview:smallPlayerTwoNameLabel];
    
    contactListener = new ContactListener(FixtureLeft, FixtureRight, ball.Fixture);
    world->SetContactListener(contactListener);
    
    //Set up sprites
    [self showSprites];
    
    [self spawnScoreboards];
    
    [ball addBall];
    
    CCNode *parent = [CCNode node];
    [self addChild:parent z:-1 tag:0];
    
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
    
    [countdown startCountdown];
    
    //Listen for game over message
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(gameOver)
     name:@"GameOver"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(countDownFinished)
     name:@"StartGame"
     object:nil];
    
    //[self addChild:[BoxDebugLayer debugLayerWithWorld:world ptmRatio:PTM_RATIO] z:10000];
}

int _leftScore_SERVER = 0, _rightScore_SERVER = 0;
int _leftShotsOnGoal_SERVER = 0, _rightShotsOnGoal_SERVER = 0;

int LEFT_PLAYER_SERVER = 666, RIGHT_PLAYER_SERVER = 667, NO_PLAYER_SERVER = 668;

int LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;

-(void)higherLeftScore{
    [crowdPlayer play];
    NSLog(@"higherLeftScore");
    if(LAST_PLAYER_TOUCH_SERVER == LEFT_PLAYER_SERVER)
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal_SERVER]];
    [_leftScoreLabel setString: [NSString stringWithFormat:@"%d",++_leftScore_SERVER]];
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
}
-(void)higherRightScore{
    [crowdPlayer play];
    NSLog(@"higherRightScore");
    if(LAST_PLAYER_TOUCH_SERVER == RIGHT_PLAYER_SERVER)
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal_SERVER]];
    [_rightScoreLabel setString: [NSString stringWithFormat:@"%d",++_rightScore_SERVER]];
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
}
-(void)higherLeftShotsOnGoal{
    NSLog(@"higherLeftShots");
    if(LAST_PLAYER_TOUCH_SERVER == RIGHT_PLAYER_SERVER)
    {
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal_SERVER]];
    }
    LAST_PLAYER_TOUCH_SERVER = LEFT_PLAYER_SERVER;
}
-(void)higherRightShotsOnGoal{
    
    if(LAST_PLAYER_TOUCH_SERVER == LEFT_PLAYER_SERVER)
    {
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal_SERVER]];
    }
    LAST_PLAYER_TOUCH_SERVER = RIGHT_PLAYER_SERVER;
}
-(void)gameOver{
    gameOverNaturally = YES;
    if(gameHasStarted)
    {
        [tripleWhistlePlayer play];
        //Handle game being over
        [ball gameOver];
        //Reset right player
        CGPoint p2 = ccp(924, 368);
        float32 angle = BodyRight->GetAngle();
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetLinearVelocity(b2Vec2(0, 0));
        BodyRight->SetTransform(b2Vec2(p2.x/PTM_RATIO, p2.y/PTM_RATIO), angle);
        
        //Reset left player
        CGPoint p1 = ccp(100, 368);
        angle = BodyLeft->GetAngle();
        BodyLeft->SetLinearDamping(0);
        BodyLeft->SetAngularDamping(0);
        BodyLeft->SetLinearVelocity(b2Vec2(0,0));
        BodyLeft->SetTransform(b2Vec2(p1.x/PTM_RATIO, p1.y/PTM_RATIO), angle);
        NSLog(@"Game Over received");
    }
    
    if([_matchmakingServer connectedClientCount] > 0)
    {
        [self sendToAll:@"Game Over" needsReliable:YES :@""];
        [self sendAssign:[NSString stringWithFormat:@"%d", _leftScore_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
        [self sendAssign:[NSString stringWithFormat:@"%d", _leftShotsOnGoal_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
        if(!isSinglePlayerGame && [_matchmakingServer connectedClientCount] > 1)
        {
            [self sendAssign:[NSString stringWithFormat:@"%d", _rightScore_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:1]];
            [self sendAssign:[NSString stringWithFormat:@"%d", _rightShotsOnGoal_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:1]];
        }
    }
    
    [smallPlayerOneImageView removeFromSuperview];
    [smallPlayerOneNameLabel removeFromSuperview];
    [smallPlayerTwoImageView removeFromSuperview];
    [smallPlayerTwoNameLabel removeFromSuperview];
    [ball removeBall];
    
    [self removeChildByTag:L_SCORE_LABEL cleanup:NO];
    [self removeChildByTag:L_SHOTS_LABEL cleanup:NO];
    [self removeChildByTag:R_SCORE_LABEL cleanup:NO];
    [self removeChildByTag:R_SHOTS_LABEL cleanup:NO];
    
    _leftScoreLabel = nil;
    _leftShotsOnGoalLabel = nil;
    _rightScoreLabel = nil;
    _rightShotsOnGoalLabel = nil;
    
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [_matchmakingServer endSession];
    [self hideSprites];
    [self removeChildByTag:666 cleanup:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GameOver" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StartGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LeftScores" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LeftShoots" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RightScores" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RightShoots" object:nil];
    
    contactListener = NULL;
    
    [self setUpWaitScreen];
}

-(void) update: (ccTime) dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
    //ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    //kmGLPushMatrix();
    
	world->Step(dt, velocityIterations, positionIterations);
}

-(void)sendToAll:(NSString*)message needsReliable:(BOOL)reliable:(NSString*)peer{
    NSLog(@"Should be sending %@", message);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = [message dataUsingEncoding:NSASCIIStringEncoding];
    [archiver encodeDataObject:data];
	//[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    if (reliable)
    {
    	[_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

-(void)sendAssign:(NSString*)assignPlayer needsReliable:(BOOL)reliable:(NSString*)peer{
    NSLog(@"Should be sending %@", assignPlayer);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = [assignPlayer dataUsingEncoding:NSASCIIStringEncoding];
    [archiver encodeDataObject:data];
	//[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    NSMutableArray* peerArray;
    peerArray = [NSMutableArray arrayWithCapacity:1];
    [peerArray addObject:peer];
    //peerArray[0] = peer;
    if (reliable)
    {
    	//[_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
        [_matchmakingServer.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingServer.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
    //[peerArray release];
}

#pragma mark - MatchmakingServerDelegate

int devicesConnected = 0;
- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
    NSLog(@"Client did connect!");
    NSLog(@"%d", [_matchmakingServer connectedClientCount]);
    if([_matchmakingServer connectedClientCount] == 1)
    {
        //devicesConnected++;
        NSLog(@"%@", peerID);
        [self sendAssign:@"1" needsReliable:YES :peerID];
    }
    else if ([_matchmakingServer connectedClientCount] == 2)
    {
        NSLog(@"%@", peerID);
        [self sendAssign:@"2" needsReliable:YES :peerID];
    }
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(int)peerID
{
    NSLog(@"Client disconnected");
    if(gameHasStarted)
    {
        [timer stopTimer];
        [countdown stopCountdown];
    }
    [self gameOver];
}

- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server
{
    NSLog(@"server session did end");
	_matchmakingServer.delegate = nil;
    [_matchmakingServer release];
	_matchmakingServer = nil;
}

#pragma mark - GKSession Data Receive Handler
float previousLeftAccel, previousRightAccel;
bool receivedPlayerOneImage = NO, receivedPlayerOneName = NO, receivedPlayerTwoImage = NO, receivedPlayerTwoName = NO, gameHasStarted = NO;
bool receivedStartGame = NO;
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
    //NSLog(@"Data received");
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        if(gameHasStarted)
        {
            //NSLog(@"FUCK THIS SHIT");
            if ([unarchiver containsValueForKey:@"1x"])
            {
                leftAccel =[unarchiver decodeFloatForKey:@"1x"];
            }
            else if ([unarchiver containsValueForKey:@"2x"])
            {
                rightAccel = [unarchiver decodeFloatForKey:@"2x"];
            }
        }
        else if([[_matchmakingServer connectedClients] objectAtIndex:0] == peerID) //Player 1
        {
            NSLog(@"Received data from player 1");
            NSData* decodedData = [unarchiver decodeDataObject];
            NSLog(@"Finished decoding");
            if(!receivedPlayerOneImage)
            {
                bg = [CCSprite spriteWithFile:@"begingame_background2.jpg"];
                bg.position = ccp(winSize.width/2, winSize.height/2);
                [self addChild:bg z:0];
                [newView removeFromSuperview];
                [[[CCDirector sharedDirector] view] addSubview:newView];
                receivedPlayerOneImage = YES;
                playerOneImage = [UIImage imageWithData:decodedData];
                //[playerOneImageView setImage:playerOneImage];
                playerOneImageView.image = playerOneImage;
                //[newView addSubview:playerOneImageView];
            }
            else if (!receivedPlayerOneName)
            {
                receivedPlayerOneName = YES;
                playerOneName = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                [playerOneNameLabel setText:playerOneName];
                //[newView addSubview:startOnePlayerButton];
                [self sendAssign:@"ONE" needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
            }
            else if (!receivedStartGame)
            {
                
                receivedStartGame = YES; 
                NSString* message = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                NSLog(@"!receivedStartGame: %@", message);
                if([message isEqualToString:@"ONE"])
                {
                    //Start one player
                    NSLog(@"One Player Pressed");
                    isSinglePlayerGame = YES;
                    gameHasStarted = YES;
                    [newView removeFromSuperview];
                    [self setUpGame];
                    
                    [self sendToAll:@"Start" needsReliable:YES :@""];
                }
                else if ([message isEqualToString:@"TWO"])
                {
                    //Start two player
                    NSLog(@"Start Game Pressed");
                    gameHasStarted = YES;
                    [newView removeFromSuperview];
                    [self setUpGame];
                    
                    [self sendToAll:@"Start" needsReliable:YES :@""];
                }
                [message release];
            }
        }
        else //Player 2
        {
            NSLog(@"Received data from player 2");
            NSData* decodedData = [unarchiver decodeDataObject];
            if(!receivedPlayerTwoImage)
            {
                bg = [CCSprite spriteWithFile:@"begingame_background3.jpg"];
                bg.position = ccp(winSize.width/2, winSize.height/2);
                [self addChild:bg z:0];
                [newView removeFromSuperview];
                [[[CCDirector sharedDirector] view] addSubview:newView];
                receivedPlayerTwoImage = YES;
                playerTwoImage = [UIImage imageWithData:decodedData];
                [playerTwoImageView setImage:playerTwoImage];
                [startOnePlayerButton removeFromSuperview];
                //[newView addSubview:startGameButton];
            }
            else if (!receivedPlayerTwoName)
            {
                receivedPlayerTwoName = YES;
                playerTwoName = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                [playerTwoNameLabel setText:playerTwoName];
                [self sendAssign:@"TWO" needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
            }
        }
        [unarchiver release];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught error...");
    }
    @finally {
        
    }
}

-(void) countDownFinished
{
    [singleWhistlePlayer play];
    
    [timer startTimer];
    [ball respawnLeft];
}

-(void) dealloc
{
    NSLog(@"DEALLOC");
    [[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(tick:) forTarget:self];
    if(BodyRight)
        world->DestroyBody(BodyRight);
    if(BodyLeft)
        world->DestroyBody(BodyLeft);
    if(BodyBall)
        world->DestroyBody(BodyBall);
    if(groundBody)
        world->DestroyBody(groundBody);
    
    
    [playerOneName release];
    [playerOneNameLabel release];
    [smallPlayerOneNameLabel release];
    [playerOneImageView release];
    [smallPlayerOneImageView release];
    if(!isSinglePlayerGame)
    {
        [playerTwoName release];
        [playerTwoNameLabel release];
        [smallPlayerTwoNameLabel release];
        [playerTwoImageView release];
        [smallPlayerTwoImageView release];
    }
    [startOnePlayerButton release];
    [startGameButton release];
    [newView release];
    if(world)
    {
	delete world;
	world = NULL;
    }
    
    
    
	
    if(m_debugDraw)
    {
	delete m_debugDraw;
	m_debugDraw = NULL;
    }
    if(contactListener)
    {
    delete contactListener;
    contactListener = NULL;
    }
    if(_mouseJoint)
    {
    delete _mouseJoint;
    _mouseJoint = NULL;
    }
    FixtureLeft = NULL;
    FixtureRight = NULL;
    BodyRight = NULL;
    BodyLeft = NULL;
    self.SpriteLeft = NULL;
    self.SpriteRight = NULL;
    player1 = NULL;
    player2 = NULL;
    player1Sprite = NULL;
    player1Body = NULL;
    player1Fixture = NULL;
    player2Sprite = NULL;
    body2 = NULL;
    spriteTexture_ = NULL;
    groundBody = NULL;
    _leftScoreLabel = NULL;
    _rightScoreLabel = NULL;
    _leftShotsOnGoalLabel = NULL;
    _rightShotsOnGoalLabel = NULL;
    BodyBall = NULL;
    
    
    if(timer)
    {
    [timer release];
    timer = NULL;
    }
    if(ball)
    {
    [ball release];
    [ball dealloc];
    ball = NULL;
    }
    if(countdown)
    {
    [countdown release];
    countdown = NULL;
    }
    
	[super dealloc];
}

-(void) initPhysics
{
	NSLog(@"initPhysics");
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	//world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// top
	groundBox.Set(b2Vec2(0,19.594f), b2Vec2(winSize.width/PTM_RATIO,19.594f));
	groundBody->CreateFixture(&groundBox,0);
	
	// bottom
	groundBox.Set(b2Vec2(0,4.4f), b2Vec2(winSize.width/PTM_RATIO,4.4f));
	groundBody->CreateFixture(&groundBox,0);
    
}

-(void) initSprites
{
    NSLog(@"initSprites");
	
    [ball addBall];
    
    [self spawnPlayers];
    
    [ball respawnCenter];
    
    //[self updateLeftPlayer:0.0f];
}

int L_SCORE_LABEL = 44444, R_SCORE_LABEL = 44445, L_SHOTS_LABEL = 44446, R_SHOTS_LABEL = 44447;

- (void)spawnScoreboards{
    _leftScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftScoreLabel.position = ccp(470, 648);
    [self addChild: _leftScoreLabel z:0 tag:L_SCORE_LABEL];
    
    _leftShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftShotsOnGoalLabel.position = ccp(174, 648);
    [self addChild: _leftShotsOnGoalLabel z:0 tag:L_SHOTS_LABEL];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherLeftScore)
     name:@"LeftScores"
     object:nil ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherLeftShotsOnGoal)
     name:@"LeftShoots"
     object:nil];
    
    
    _rightScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _rightScoreLabel.position = ccp(555, 648);
    [self addChild: _rightScoreLabel z:0 tag:R_SCORE_LABEL];
    
    _rightShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _rightShotsOnGoalLabel.position = ccp(994, 648);
    [self addChild: _rightShotsOnGoalLabel z:0 tag:R_SHOTS_LABEL];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherRightScore)
     name:@"RightScores"
     object:nil ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherRightShotsOnGoal)
     name:@"RightShoots"
     object:nil];
}

@synthesize SpriteLeft, SpriteRight, BodyRight, BodyLeft, BodyBall, FixtureLeft, FixtureRight;
#define PTM_RATIO 32

-(void) showSprites {
    [self addChild:self.SpriteLeft z:0 tag:LEFT_PLAYER_TAG];
    [self addChild:self.SpriteRight z:0 tag:RIGHT_PLAYER_TAG];
}

-(void) hideSprites {
    [self removeChildByTag:LEFT_PLAYER_TAG cleanup:NO];
    [self removeChildByTag:RIGHT_PLAYER_TAG cleanup:NO];
}

-(void) spawnPlayers
{
    NSLog(@"spawnPlayers");
    winSize = [CCDirector sharedDirector].winSize;
    
    BodyBall = ball.getBody;
    
    CGPoint p1 = ccp(100, 368);
    
    self.SpriteLeft = [PhysicsSprite spriteWithFile:@"player1.png"];
    //[self addChild:SpriteLeft z:0];
    self.SpriteLeft.position = ccp(p1.x, p1.y);
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef1;
    bodyDef1.type = b2_dynamicBody;
    bodyDef1.position.Set(p1.x/PTM_RATIO, p1.y/PTM_RATIO);
    bodyDef1.fixedRotation = YES;
    BodyLeft = world->CreateBody(&bodyDef1);
    
    //b2CircleShape circleShapePlayer1;
    //circleShapePlayer1.m_radius = 1.25;
    b2PolygonShape squareShapePlayer1;
    b2PolygonShape notSquareShapePlayer1;
    //squareShapePlayer2.SetAsBox(2.5, 3.47);
    b2Vec2 vertices[8];
    vertices[0].Set(0.1, -1.735);
    //vertices[1].Set(0.3, -1.5);
    vertices[1].Set(0.5, -1.3);
    vertices[2].Set(0.8, -0.8);
    vertices[3].Set(0.8, 0.8); //TOP RIGHT
    vertices[4].Set(0.5, 1.3); //TOP LEFT
    //vertices[5].Set(0.3, 1.5);
    vertices[5].Set(0.1, 1.735);
    vertices[6].Set(-0.8, 1.735);
    vertices[7].Set(-0.8, -1.735);
    int32 count = 8;
    notSquareShapePlayer1.Set(vertices, count);
    
    squareShapePlayer1.SetAsBox(0.8, 1.735);
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef1;
    fixtureDef1.shape = &notSquareShapePlayer1;
    fixtureDef1.density = 100.0f;
    fixtureDef1.friction = 0.0f;
    FixtureLeft = BodyLeft->CreateFixture(&fixtureDef1);
    
    [self.SpriteLeft setPhysicsBody:BodyLeft];
    
    CGPoint p2 = ccp(924, 368);
    
    self.SpriteRight = [PhysicsSprite spriteWithFile:@"player2.png"];
    //[self addChild:SpriteRight z:0];
    self.SpriteRight.position = ccp(p2.x, p2.y);
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef2;
    bodyDef2.type = b2_dynamicBody;
    //bodyDef2.position.Set(p2.x/PTM_RATIO - 1.25, p2.y/PTM_RATIO - 1.735);
    bodyDef2.position.Set(p2.x/PTM_RATIO, p2.y/PTM_RATIO);
    bodyDef2.fixedRotation = YES;
    BodyRight = world->CreateBody(&bodyDef2);
    
    // Define another box shape for our dynamic body.
    //b2CircleShape circleShapePlayer2;
    //circleShapePlayer2.m_radius = 2.5;
    
    b2PolygonShape squareShapePlayer2;
    b2PolygonShape notSquareShapePlayer2;
    
    b2Vec2 vertices2[8];
    vertices2[2].Set(0.8, 1.735);
    vertices2[1].Set(0.8, -1.735);
    vertices2[0].Set(-0.1, -1.735);
    vertices2[7].Set(-0.5, -1.3);
    vertices2[6].Set(-0.8, -0.8);
    vertices2[5].Set(-0.8, 0.8); //TOP RIGHT
    vertices2[4].Set(-0.5, 1.3); //TOP LEFT
    vertices2[3].Set(-0.1, 1.735);
    
    
    notSquareShapePlayer2.Set(vertices2, count);
    //squareShapePlayer2.SetAsBox(2.5, 3.47);
    squareShapePlayer2.SetAsBox(0.8, 1.735);
    //squareShapePlayer2.
    
    
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef2;
    fixtureDef2.shape = &notSquareShapePlayer2;
    fixtureDef2.density = 100.0f;
    fixtureDef2.friction = 0.0f;
    FixtureRight = BodyRight->CreateFixture(&fixtureDef2);
    
    [self.SpriteRight setPhysicsBody:BodyRight];
    //[self scheduleUpdate];
    
}

-(void) test
{
    
}

float leftAccel = 0.0f, rightAccel = 0.0f, rightAccelToUse = 0.0f, leftAccelToUse = 0.0f;

- (void)tick:(ccTime) dt {
    
    b2Vec2 rightPlayerPos = BodyRight->GetPosition();
    float32 angle = BodyRight->GetAngle();
    if(isSinglePlayerGame)
    {
        //NSLog(@"Update single player");
        b2Vec2 ballPos = [ball getBody]->GetPosition();
        if(ballPos.y > BodyRight->GetPosition().y)
            rightAccel = -0.1;
        else
            rightAccel = 0.1;
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetAngularVelocity(0);
        BodyRight->SetLinearVelocity(b2Vec2(0,40 * rightAccel * -1));
        BodyRight->SetTransform(rightPlayerPos, angle);
    }
    else
    {
        //NSLog(@"Update two player");
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetAngularVelocity(0);
        BodyRight->SetLinearVelocity(b2Vec2(0,rightAccel * 40 * -1));
        previousRightAccel = rightAccel;
        BodyRight->SetTransform(rightPlayerPos, angle);
    }
    angle = BodyLeft->GetAngle();
    BodyLeft->SetLinearDamping(0);
    BodyLeft->SetAngularDamping(0);
    BodyLeft->SetAngularVelocity(0);
    BodyLeft->SetLinearVelocity(b2Vec2(0,leftAccel * 40 * -1));
    previousLeftAccel = leftAccel;
    b2Vec2 loc = BodyLeft->GetPosition();
    BodyLeft->SetTransform(loc, angle);
    //b2Vec2 loc = b2Vec2(location.x, location.y);
    //rightPlayerPos = BodyRight->GetPosition();
    
}

@end
