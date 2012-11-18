//
//  Player.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize SpriteLeft, SpriteRight, BodyRight, BodyLeft, BodyBall, FixtureLeft, FixtureRight;
#define PTM_RATIO 32

int rightPlayerBallOffset = 0;

-(id) spawnPlayers:(CCLayer *)layer :(b2World *)world :(b2Body *)groundBody :(b2Body *)ballBody :(BOOL)isSinglePlayer
{
    if ((self=[super init])) {
        _winSize = [CCDirector sharedDirector].winSize;
        
        BodyBall = ballBody;
        
        CGPoint p1 = ccp(100, 368);
        
        SpriteLeft = [PhysicsSprite spriteWithFile:@"player1.png"];
        [layer addChild:SpriteLeft z:0];
        SpriteLeft.position = ccp(p1.x, p1.y);
        
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
        //squareShapePlayer2.SetAsBox(2.5, 3.47);
        squareShapePlayer1.SetAsBox(0.8, 1.735);
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef1;
        fixtureDef1.shape = &squareShapePlayer1;
        fixtureDef1.density = 100.0f;
        fixtureDef1.friction = 0.0f;
        FixtureLeft = BodyLeft->CreateFixture(&fixtureDef1);
        
        [SpriteLeft setPhysicsBody:BodyLeft];
        
        CGPoint p2 = ccp(924, 368);
        
        SpriteRight = [PhysicsSprite spriteWithFile:@"player2.png"];
        [layer addChild:SpriteRight z:0];
        SpriteRight.position = ccp(p2.x, p2.y);
        
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
        //squareShapePlayer2.SetAsBox(2.5, 3.47);
        squareShapePlayer2.SetAsBox(0.8, 1.735);
        //squareShapePlayer2.
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef2;
        fixtureDef2.shape = &squareShapePlayer2;
        fixtureDef2.density = 100.0f;
        fixtureDef2.friction = 0.0f;
        FixtureRight = BodyRight->CreateFixture(&fixtureDef2);
        
        [SpriteRight setPhysicsBody:BodyRight];
        //[self scheduleUpdate];
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:FALSE];
    }
    return self;
}

-(void) gameOver {
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
    
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
}

-(void) test
{
    NSLog(@"WHAT THE FUCK");
}



- (void)tick:(ccTime) dt {
    
    b2Vec2 ballPos = BodyBall->GetPosition();
    b2Vec2 rightPlayerPos = BodyRight->GetPosition();
    float32 vel = 5.2f;
    if(ballPos.y > rightPlayerPos.y)
    {
                
    }
    else if (ballPos.y < rightPlayerPos.y)
    {
        vel *= -1;
    }
    
    //if(CGRectIntersectsRect(BodyBall->, <#CGRect rect2#>))
    /*float32 angle = BodyRight->GetAngle();
    BodyRight->SetLinearDamping(0);
    BodyRight->SetAngularDamping(0);
    BodyRight->SetLinearVelocity(b2Vec2(0, vel));
    BodyRight->SetTransform(rightPlayerPos, angle);*/
    CGPoint location = CGPointMake(924/PTM_RATIO, ballPos.y);
    //NSLog(@"Testing tick %f", pos.y);
    //CGPoint location = [[CCDirector sharedDirector] convertToGL:nextPoint];
    
    float32 angle = BodyRight->GetAngle();
    BodyRight->SetLinearDamping(0);
    BodyRight->SetAngularDamping(0);
    BodyRight->SetAngularVelocity(0);
    BodyRight->SetLinearVelocity(b2Vec2(0,vel));
    //b2Vec2 loc = b2Vec2(location.x, location.y);
    //rightPlayerPos = BodyRight->GetPosition();
    BodyRight->SetTransform(rightPlayerPos, angle);
}

-(void)dealloc{
    NSLog(@"Player dealloc");
    SpriteLeft = NULL;
    SpriteRight = NULL;
    BodyLeft = NULL;
    BodyRight = NULL;
    FixtureLeft = NULL;
    FixtureRight = NULL;
    [super dealloc];
}

-(void) updateLeftPlayer: (float) accel
{
    NSLog(@"Left player should be updating...");
    float32 angle = BodyLeft->GetAngle();
    BodyLeft->SetLinearDamping(0);
    BodyLeft->SetAngularDamping(0);
    BodyLeft->SetAngularVelocity(0);
    BodyLeft->SetLinearVelocity(b2Vec2(0,75 * accel * -1));
    b2Vec2 loc = BodyLeft->GetPosition();
    BodyLeft->SetTransform(loc, angle);
}

@end
