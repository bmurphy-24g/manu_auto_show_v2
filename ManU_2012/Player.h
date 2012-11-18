//
//  Player.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"

@interface Player : CCNode <UIAccelerometerDelegate>{
    CGSize _winSize;
    PhysicsSprite *SpriteLeft;
    PhysicsSprite *SpriteRight;
    b2Body* BodyLeft;
    b2Body* BodyRight;
    b2Body* BodyBall;
    b2Fixture* FixtureLeft;
    b2Fixture* FixtureRight;
}

@property(readonly,assign) CCSprite* SpriteLeft;
@property(readonly,assign) CCSprite* SpriteRight;
@property(readonly,assign) b2Body* BodyLeft;
@property(readonly,assign) b2Body* BodyRight;
@property(readonly,assign) b2Body* BodyBall;
@property(readonly,assign) b2Fixture* FixtureLeft;
@property(readonly,assign) b2Fixture* FixtureRight;

-(id) spawnPlayers: (CCLayer*) layer: (b2World*) world: (b2Body*) groundBody: (b2Body*) ballBody: (BOOL) isSinglePlayer;
-(void) updateLeftPlayer: (float) accel;
-(void) gameOver;
-(void) test;
@end

/*
 #import <Foundation/Foundation.h>
 #import "cocos2d.h"
 #import "Box2D.h"
 #import "GLES-Render.h"
 #import "PhysicsSprite.h"
 
 @interface Player : CCNode {
 CGSize _winSize;
 PhysicsSprite* SpriteLeft;
 PhysicsSprite* SpriteRight;
 b2Body* BodyLeft;
 b2Body* BodyRight;
 b2Fixture* FixtureLeft;
 b2Fixture* [FixtureRight;
 }
 
 @property(readonly,assign) CCSprite* SpriteLeft;
 @property(readonly,assign) CCSprite* SpriteRight;
 @property(readonly,assign) b2Body* BodyLeft;
 @property(readonly,assign) b2Body* BodyRight;
 @property(readonly,assign) b2Fixture* FixtureLeft;
 @property(readonly,assign) b2Fixture* FixtureRight;
 
 
 //-(id) spawnPlayers: (CCLayer*) layer: (b2World*) world: (b2Body*) groundBody: (BOOL) isSinglePlayer;
 
 @end
 */
