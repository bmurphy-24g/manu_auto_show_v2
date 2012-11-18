//
//  PlayGameScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGameScene.h"

enum {
	kTagParentNode = 0,
};


@implementation PlayGameScene
GKHelper *gkHelper;
GKPeerPickerController *picker;
GKSession* session;
BOOL isFirstPlayer;
int scoreForServer, scoreForClient;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlayGameScene *layer = [PlayGameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)registerWithTouchDispatcher {
    NSLog(@"registerWithTouchDispatcher");
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
        gkHelper = [[GKHelper alloc] init];
        //[self connectToPeer];
        
        
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
        winSize = s;
        
        bg = [CCSprite spriteWithFile:@"field.jpg"];
        bg.position = ccp(s.width/2, s.height/2);
        [self addChild:bg z:0];
        
        // init physics
		[self initPhysics];
        
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        //b2Draw *debugDraw = new b2Draw();
        world->SetDebugDraw(m_debugDraw);
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        m_debugDraw->SetFlags(flags);
				
		//Set up sprites
		[self initSprites];
        
        
        
        [self spawnScoreboards];
        
        CCNode *parent = [CCNode node];
        [self addChild:parent z:0 tag:kTagParentNode];
        
        [self scheduleUpdate];
        
        [self startAccelerometer];
        
        
        
        //[[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(animateController:) forTarget:self interval:22 paused:FALSE];
        //[self checkIfScored];
        
        //[ball respawnLeft];
	}
	return self;
}

/*-(void) draw
{
    NSLog(@"The fuck");
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    world->DrawDebugData();
    kmGLPopMatrix();
    [super draw];

}*/

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
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
	groundBox.Set(b2Vec2(0,20), b2Vec2(s.width/PTM_RATIO,20));
	groundBody->CreateFixture(&groundBox,0);
	
	// bottom
	groundBox.Set(b2Vec2(0,141/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,141/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	/*// left_bottom
    groundBox.Set(b2Vec2(0, (s.height/3)/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
    
    // left_top
    groundBox.Set(b2Vec2(0, (s.height)/PTM_RATIO), b2Vec2(0,(s.height/3 * 2)/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
	
	// right_bottom
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,(s.height/3)/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
    // right_top
    groundBox.Set(b2Vec2(s.width/PTM_RATIO,(s.height)/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,(s.height/3 * 2)/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);*/
}

-(void) initSprites
{
    NSLog(@"initSprites");
	//CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	
    /*CGPoint p1 = ccp(100, 368);
	
	player1Sprite = [PhysicsSprite spriteWithFile:@"player1.png"];
    [self addChild:player1Sprite];
	player1Sprite.position = ccp(p1.x, p1.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef1;
	bodyDef1.type = b2_dynamicBody;
	bodyDef1.position.Set(p1.x/PTM_RATIO, p1.y/PTM_RATIO);
    bodyDef1.fixedRotation = YES;
	player1Body = world->CreateBody(&bodyDef1);
	
    b2CircleShape circleShapePlayer1;
    circleShapePlayer1.m_radius = 2.5;
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &circleShapePlayer1;
	fixtureDef1.density = 10.0f;
	fixtureDef1.friction = 0.0f;
	player1Fixture = player1Body->CreateFixture(&fixtureDef1);
	
	[player1Sprite setPhysicsBody:player1Body];
    
    CGPoint p2 = ccp(924, 368);
	
	player2Sprite = [PhysicsSprite spriteWithFile:@"player2.png"];
    [self addChild:player2Sprite];
	player2Sprite.position = ccp(p2.x, p2.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef2;
	bodyDef2.type = b2_dynamicBody;
	bodyDef2.position.Set(p2.x/PTM_RATIO, p2.y/PTM_RATIO);
	body2 = world->CreateBody(&bodyDef2);
	
	// Define another box shape for our dynamic body.
	b2CircleShape circleShapePlayer2;
    circleShapePlayer2.m_radius = 2.5;
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef2;
	fixtureDef2.shape = &circleShapePlayer2;
	fixtureDef2.density = 10.0f;
	fixtureDef2.friction = 0.0f;
	body2->CreateFixture(&fixtureDef2);
	
	[player2Sprite setPhysicsBody:body2];*/
    
        
    ball = [[Ball alloc] spawn:self :world : groundBody];
    
    players = [[Player alloc] spawnPlayers:self :world :groundBody :ball.getBody :YES];

    [ball respawnLeft];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    [players updateLeftPlayer:acceleration.x];
    /*float32 angle = BodyLeft->GetAngle();
    BodyLeft->SetLinearDamping(0);
    BodyLeft->SetAngularDamping(0);
    BodyLeft->SetAngularVelocity(0);
    BodyLeft->SetLinearVelocity(b2Vec2(0,25 * acceleration.x * -1));
    b2Vec2 loc = BodyLeft->GetPosition();
    BodyLeft->SetTransform(loc, angle);*/
    
    /*if (player1Fixture->TestPoint(locationWorld)) {
     b2MouseJointDef md;
     md.bodyA = groundBody;
     md.bodyB = player1Body;
     md.target = locationWorld;
     md.collideConnected = true;
     md.maxForce = 500.0f * player1Body->GetMass();
     
     _mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
     player1Body->SetAwake(true);
     _mouseJoint->SetTarget(locationWorld);
     }*/
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

- (void)spawnScoreboards{
    scoreBoard = [[ScoreBoard alloc] spawn:self];
    
    _leftScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"SF Square Head" fontSize:64];
    _leftScoreLabel.position = ccp(winSize.width/2 - 100,winSize.height - 45);
    [self addChild: _leftScoreLabel];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherLeftScore)
     name:@"LeftScores"
     object:nil ];
    
    
    _rightScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"SF Square Head" fontSize:64];
    _rightScoreLabel.position = ccp(winSize.width/2 + 100,winSize.height - 45);
    [self addChild: _rightScoreLabel];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherRightScore)
     name:@"RightScores"
     object:nil ];
}

int _leftScore = 0, _rightScore = 0;

-(void)higherLeftScore{
    NSLog(@"higherLeftScore");
    [_leftScoreLabel setString: [NSString stringWithFormat:@"%d",++_leftScore]];
    [scoreBoard incrementLeft];
}
-(void)higherRightScore{
    NSLog(@"higherRightScore");
    [_rightScoreLabel setString: [NSString stringWithFormat:@"%d",++_rightScore]];
    [scoreBoard incrementRight];
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
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    
	world->Step(dt, velocityIterations, positionIterations);
    
    world->DrawDebugData();
    kmGLPopMatrix();
}



- (void)animateController {
    CGPoint nextPoint = CGPointMake(player2.position.x, ball.position.y);
    CGPoint location = [[CCDirector sharedDirector] convertToGL:nextPoint];
    
    float32 angle = player1Body->GetAngle();
    player1Body->SetLinearDamping(0);
    player1Body->SetAngularDamping(0);
    player1Body->SetAngularVelocity(0);
    player1Body->SetLinearVelocity(b2Vec2(0,0));
    b2Vec2 loc = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    player1Body->SetTransform(loc, angle);

    //CCAction *myAction = [CCSequence actions:[CCMoveTo actionWithDuration:0.22 position:nextPoint], [CCCallFunc actionWithTarget:self selector:@selector(animateController)], nil];
    //[player2 runAction:myAction];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	/*for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		//[self addNewSpriteAtPosition: location];
	}*/
}

- (void)checkIfScored {
    //b2Vec2 ballPos = bodyBall->GetPosition();
    //NSLog(@"Ball x: %f y: %f", ballPos.x, ballPos.y);
    [self checkIfScored];
}

- (void)resetGame {
    //world->DestroyBody(bodyBall);
    world->DestroyBody(player1Body);
    world->DestroyBody(body2);
    [self initSprites];
}

CGPoint prevPoint;// = ccp(100, 368);
CGPoint curPoint;// = ccp(100, 368);

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    /*if (_mouseJoint == NULL) return;
    prevPoint = curPoint;
    curPoint = [touch locationInView:[touch view]];
	curPoint = [[CCDirector sharedDirector] convertToGL:curPoint];
    //if (curPoint.x >= 512) curPoint.x = 512;
    b2Vec2 locationWorld = b2Vec2(curPoint.x/PTM_RATIO, curPoint.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);*/
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    /*CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if(_mouseJoint == NULL)
    {
        
        //if (curPoint.x >= 512) curPoint.x = 512;
        
        b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
        
        float32 angle = player1Body->GetAngle();
        player1Body->SetLinearDamping(0);
        player1Body->SetAngularDamping(0);
        player1Body->SetAngularVelocity(0);
        player1Body->SetLinearVelocity(b2Vec2(0,0));
        b2Vec2 loc = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
        player1Body->SetTransform(loc, angle);
        
        if (player1Fixture->TestPoint(locationWorld)) {
            b2MouseJointDef md;
            md.bodyA = groundBody;
            md.bodyB = player1Body;
            md.target = locationWorld;
            md.collideConnected = true;
            md.maxForce = 500.0f * player1Body->GetMass();
            
            _mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
            player1Body->SetAwake(true);
            _mouseJoint->SetTarget(locationWorld);
        }
    }*/
    //if( location.x < 25 && location.y < 25)
    //   [self resetGame];
    return YES;
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker
		   sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    session = [[GKSession alloc] initWithSessionID:@"ManU_2012" displayName:nil sessionMode:GKSessionModePeer];
    session.delegate = gkHelper;
    [session setDataReceiveHandler: self withContext:nil];
    //session.available = YES;
    return session;
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    isFirstPlayer = YES;
    //label.text = @"server";
}

-(void) connectToPeer
{
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = gkHelper;
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
    
    //if ([prefix isEqualToString:@"s"]) label.text = [NSString stringWithFormat:@"You: %i, other: %i", scoreForServer, scoreForClient];
}

@end
