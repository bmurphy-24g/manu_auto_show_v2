//
//  Ball.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"


@implementation Ball
@synthesize Sprite, Body, Fixture;
#define PTM_RATIO 32
int numTimesIncreased = 0;
int BALL_TAG = 98734;

-(id) spawn:(CCLayer *)layer :(b2World *)world :(b2Body *)groundBody {
    NSLog(@"SHOULD SPAWN");
    if ((self=[super init])) {
        NSLog(@"spawn");
        
        parentLayer = layer;
        _winSize = [CCDirector sharedDirector].winSize;
        
        CGPoint b = ccp(512, 368);
         
         Sprite = [PhysicsSprite spriteWithFile:@"ball.png"];
        [Sprite retain];
         //[layer addChild:Sprite];
        //[layer addChild:Sprite z:0 tag:BALL_TAG];
         Sprite.position = ccp(b.x, b.y);
         
         // Define the dynamic body.
         //Set up a 1m squared box in the physics world
         b2BodyDef bodyDefBall;
         bodyDefBall.type = b2_dynamicBody;
         bodyDefBall.position.Set(b.x/PTM_RATIO, b.y/PTM_RATIO);
         bodyDefBall.fixedRotation = NO;
         Body = world->CreateBody(&bodyDefBall);
         
         // Define another box shape for our dynamic body.
         //b2PolygonShape dynamicBoxBall;
         //dynamicBoxBall.SetAsBox(1.0f, 1.0f);//These are mid points for our 1m box
         
         b2CircleShape circleShapeBall;
         circleShapeBall.m_radius = 0.5f;
         
         // Define the dynamic body fixture.
         b2FixtureDef fixtureDefBall;
         fixtureDefBall.shape = &circleShapeBall;
         fixtureDefBall.density = 4.0f;
         fixtureDefBall.friction = 0.0f;
         fixtureDefBall.restitution = 1.0f;
         Fixture = Body->CreateFixture(&fixtureDefBall);
        
        
        
         [Sprite setPhysicsBody:Body];
        
        //[self addBall];
        
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:YES];
    }
    return self;
}

-(void)addBall {
    numTimesIncreased = 1;
    newSpeed = 25;
    [parentLayer addChild:Sprite z:0 tag:BALL_TAG];
    [self reset];
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(speedUpBall)
     name:@"SpeedUp"
     object:nil];
}

-(void)removeBall {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SpeedUp" object:nil];
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [parentLayer removeChildByTag:BALL_TAG cleanup:NO];
}

int newSpeed = 30;
- (void) speedUpBall
{
    if(numTimesIncreased == 1)
    {
        NSLog(@"Increasing 1");
        newSpeed = 45;
        /*float angle = Body->GetAngle();
        b2Vec2 vel = Body->GetLinearVelocity();
        NSLog(@"vx: %f vy: %f", vel.x, vel.y);
        b2Vec2 newVel = b2Vec2(vel.x * 1.67, vel.y * 1.67);
        Body->SetLinearVelocity(newVel);
        NSLog(@"angle: %f", angle);*/
        
        b2Vec2 velocity = Body->GetLinearVelocity();
        //float32 angle = [self getAngle:velocity];
        float32 speed = velocity.Length();
        
        float32 increase = (newSpeed/3.3)/speed;
        NSLog(@"Increasing speed! %f", increase);
        b2Vec2 force = b2Vec2(velocity.x * increase,velocity.y * increase);
        Body->ApplyLinearImpulse(force, Body->GetPosition());
    }
}

- (void)tick:(ccTime) dt {
    b2Vec2 ballPos = Body->GetPosition();
    ballPos *= PTM_RATIO;
    
    //NSLog(@"Updating! %f", Sprite.position.y);
    
    b2Vec2 velocity = Body->GetLinearVelocity();
    //float32 angle = [self getAngle:velocity];
    float32 speed = velocity.Length();
    //NSLog(@"speed: %f", speed);
    //NSLog(@"%f", (newSpeed/3.3));
    if(speed < (newSpeed/3.3) && speed > 0.5)
    {
        float32 increase = (newSpeed/3.3)/speed;
        NSLog(@"Increasing speed! %f", increase);
        b2Vec2 force = b2Vec2(velocity.x * increase,velocity.y * increase);
        Body->ApplyLinearImpulse(force, Body->GetPosition());
    }
    
    
    if(ballPos.x < 0){
        NSLog(@"Right scored!");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RightScores"
         object:nil ];
        [self respawnLeft];
    } else if(ballPos.x > _winSize.width){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LeftScores"
         object:nil ];
        [self respawnRight];
    }
}

-(void) respawnCenter {
    float32 angle = Body->GetAngle();
    
    Body->SetLinearDamping(0);
    Body->SetAngularDamping(0);
    Body->SetAngularVelocity(0);
    Body->SetLinearVelocity(b2Vec2(0,0));
    
    b2Vec2 center = b2Vec2(_winSize.width/2/PTM_RATIO, _winSize.height/2/PTM_RATIO);
    Body->SetTransform(center, angle);
}

-(void) reset {
    float32 angle = Body->GetAngle();
    
    Body->SetLinearDamping(0);
    Body->SetAngularDamping(0);
    Body->SetAngularVelocity(0);
    Body->SetLinearVelocity(b2Vec2(0,0));
    
    b2Vec2 center = b2Vec2(_winSize.width/2/PTM_RATIO, _winSize.height/2/PTM_RATIO);
    Body->SetTransform(center, angle);
}

-(void) gameOver {
    [self reset];
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    //[[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(tick:) forTarget:self];
}

-(void) respawn: (float)withAngle{
    [self reset];
    const int speed = newSpeed;
    
    double x = sin(withAngle * M_PI / 180) * speed;
    double y = cos(withAngle * M_PI / 180) * speed;
    
    NSLog(@"Respawn x: %d y: %d", x, y);
    
    b2Vec2 force = b2Vec2(x,y);
    Body->ApplyLinearImpulse(force, Body->GetPosition());
}

-(void) respawnLeft {
    [self respawn: 225];
}

-(void) respawnRight {
    [self respawn: 45];
}

-(b2Body *) getBody {
    return Body;
}

-(void)dealloc{
    NSLog(@"Ball dealloc");
    Sprite = NULL;
    Body = NULL;
    Fixture = NULL;
    
    [super dealloc];
}

-(float32)getAngle: (b2Vec2)curVel
{
    float32 angle = sqrtf(curVel.x*curVel.x + curVel.y*curVel.y);
    if(curVel.x > 0 && curVel.y > 0) // 1st quad
    {
        return angle;
    }
    else if(curVel.x < 0 && curVel.y > 0) // 2nd quad
    {
        return angle + 90;
    }
    else if(curVel.x < 0 && curVel.y < 0) // 3rd quad
    {
        return angle + 180;
    }
    else if(curVel.x > 0 && curVel.y < 0) // 4th quad
    {
        return angle + 270;
    }
    else
        return 0;
}

@end
