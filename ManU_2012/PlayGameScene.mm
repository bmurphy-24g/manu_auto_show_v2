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
        
        //Set up sprites
		[self initSprites];
        
        [self spawnScoreboards];
        
        CCNode *parent = [CCNode node];
        [self addChild:parent z:-1 tag:kTagParentNode];
        
        [self scheduleUpdate];
        
        [self startAccelerometer];
        
        timer = [[Timer alloc] spawn:self];
        
        //Listen for game over message
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(gameOver)
         name:@"GameOver"
         object:nil];

        
        contactListener = new ContactListener(players.FixtureLeft, players.FixtureRight, ball.Fixture);
        world->SetContactListener(contactListener);
        
        //[self addChild:[BoxDebugLayer debugLayerWithWorld:world ptmRatio:PTM_RATIO] z:10000];
        
        //[[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(animateController:) forTarget:self interval:22 paused:FALSE];
        //[self checkIfScored];
        
        //[ball respawnLeft];
	}
	return self;
}

-(void) draw
{
    [super draw];
 //NSLog(@"The fuck");
    //glDisable(GL_TEXTURE_2D);
 ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
 kmGLPushMatrix();
 world->DrawDebugData();
 kmGLPopMatrix();
    //glEnable(GL_TEXTURE_2D);
 
}

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
	groundBox.Set(b2Vec2(0,19.594f), b2Vec2(s.width/PTM_RATIO,19.594f));
	groundBody->CreateFixture(&groundBox,0);
	
	// bottom
	groundBox.Set(b2Vec2(0,4.4f), b2Vec2(s.width/PTM_RATIO,4.4f));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) initSprites
{
    NSLog(@"initSprites");
	ball = [[Ball alloc] spawn:self :world : groundBody];
    
    players = [[Player alloc] spawnPlayers:self :world :groundBody :ball.getBody :YES];
    
    [ball respawnLeft];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    [players updateLeftPlayer:acceleration.x];
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
    
    _leftScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftScoreLabel.position = ccp(470, 648);
    [self addChild: _leftScoreLabel];
    
    _leftShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftShotsOnGoalLabel.position = ccp(174, 648);
    [self addChild: _leftShotsOnGoalLabel];
    
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
    //_rightScoreLabel = [CCLabelTTF label]
    _rightScoreLabel.position = ccp(555, 648);
    [self addChild: _rightScoreLabel];
    
    _rightShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _rightShotsOnGoalLabel.position = ccp(994, 648);
    [self addChild: _rightShotsOnGoalLabel];
    
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

int _leftScore = 0, _rightScore = 0;
int _leftShotsOnGoal = 0, _rightShotsOnGoal = 0;

int LEFT_PLAYER = 666, RIGHT_PLAYER = 667, NO_PLAYER = 668;

int LAST_PLAYER_TOUCH = NO_PLAYER;

-(void)higherLeftScore{
    NSLog(@"higherLeftScore");
    if(LAST_PLAYER_TOUCH == LEFT_PLAYER)
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal]];
    [_leftScoreLabel setString: [NSString stringWithFormat:@"%d",++_leftScore]];
    LAST_PLAYER_TOUCH = NO_PLAYER;
}
-(void)higherRightScore{
    NSLog(@"higherRightScore");
    if(LAST_PLAYER_TOUCH == RIGHT_PLAYER)
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal]];
    [_rightScoreLabel setString: [NSString stringWithFormat:@"%d",++_rightScore]];
    LAST_PLAYER_TOUCH = NO_PLAYER;
}
-(void)higherLeftShotsOnGoal{
    if(LAST_PLAYER_TOUCH == RIGHT_PLAYER)
    {   
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal]];
    }
    LAST_PLAYER_TOUCH = LEFT_PLAYER;
}
-(void)higherRightShotsOnGoal{
    
    if(LAST_PLAYER_TOUCH == LEFT_PLAYER)
    {
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal]];
    }
    LAST_PLAYER_TOUCH = RIGHT_PLAYER;
}
-(void)gameOver{
    //Handle game being over
    [self stopAccelerometer];
    [ball gameOver];
    [players gameOver];
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
    
    //world->DrawDebugData();
    //kmGLPopMatrix();
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
