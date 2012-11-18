//
//  Player.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

/*#import "Player.h"


@implementation Player
@synthesize SpriteLeft, SpriteRight, BodyLeft, BodyRight, FixtureLeft, FixtureRight;
#define PTM_RATIO 32

-(id) spawnPlayers:(CCLayer *)layer :(b2World *)world :(b2Body *)groundBody :(b2Body *)ballBody :(BOOL)isSinglePlayer
{
    if ((self=[super init])) {
        _winSize = [CCDirector sharedDirector].winSize;
        
        BodyBall = ballBody;
        
        CGPoint p1 = ccp(100, 368);
        
        SpriteLeft = [PhysicsSprite spriteWithFile:@"player1.png"];
        [self addChild:SpriteLeft];
        SpriteLeft.position = ccp(p1.x, p1.y);
        
        // Define the dynamic body.
        //Set up a 1m squared box in the physics world
        b2BodyDef bodyDef1;
        bodyDef1.type = b2_dynamicBody;
        bodyDef1.position.Set(p1.x/PTM_RATIO, p1.y/PTM_RATIO);
        bodyDef1.fixedRotation = YES;
        BodyLeft = world->CreateBody(&bodyDef1);
        
        b2CircleShape circleShapePlayer1;
        circleShapePlayer1.m_radius = 2.5;
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef1;
        fixtureDef1.shape = &circleShapePlayer1;
        fixtureDef1.density = 10.0f;
        fixtureDef1.friction = 0.0f;
        FixtureLeft = BodyLeft->CreateFixture(&fixtureDef1);
        
        [SpriteLeft setPhysicsBody:BodyLeft];
        
        CGPoint p2 = ccp(924, 368);
        
        SpriteRight = [PhysicsSprite spriteWithFile:@"player2.png"];
        [self addChild:SpriteRight];
        SpriteRight.position = ccp(p2.x, p2.y);
        
        // Define the dynamic body.
        //Set up a 1m squared box in the physics world
        b2BodyDef bodyDef2;
        bodyDef2.type = b2_dynamicBody;
        bodyDef2.position.Set(p2.x/PTM_RATIO, p2.y/PTM_RATIO);
        BodyRight = world->CreateBody(&bodyDef2);
        
        // Define another box shape for our dynamic body.
        b2CircleShape circleShapePlayer2;
        circleShapePlayer2.m_radius = 2.5;
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef2;
        fixtureDef2.shape = &circleShapePlayer2;
        fixtureDef2.density = 10.0f;
        fixtureDef2.friction = 0.0f;
        FixtureRight = BodyRight->CreateFixture(&fixtureDef2);
        
        [SpriteRight setPhysicsBody:BodyRight];
        //[self scheduleUpdate];
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:FALSE];
    }
    return self;
}

//-(id) spawnPlayers

- (void)tick:(ccTime) dt {
    CGPoint nextPoint = CGPointMake(BodyRight.position.x, BodyBall.position.y);
    CGPoint location = [[CCDirector sharedDirector] convertToGL:nextPoint];
    
    float32 angle = BodyRight->GetAngle();
    BodyRight->SetLinearDamping(0);
    BodyRight->SetAngularDamping(0);
    BodyRight->SetAngularVelocity(0);
    BodyRight->SetLinearVelocity(b2Vec2(0,0));
    b2Vec2 loc = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    BodyRight->SetTransform(loc, angle);
}

-(void)dealloc{
    SpriteLeft = NULL;
    SpriteRight = NULL;
    BodyLeft = NULL;
    BodyRight = NULL;
    FixtureLeft = NULL;
    FixtureRight = NULL;
    [super dealloc];
}

@end
*/