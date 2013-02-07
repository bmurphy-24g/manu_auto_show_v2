//
//  Ball.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"

@interface Ball : CCNode {
    CGSize _winSize;
    PhysicsSprite* Sprite;
    b2Body* Body;
    b2Fixture* Fixture;
    b2Body* leftBody;
    b2Body* rightBody;
    CCLayer* parentLayer;
    b2World* mainWorld;
}

@property(readonly,assign) CCSprite* Sprite;
@property(readonly,assign) b2Body* Body;
@property(readonly,assign) b2Fixture* Fixture;

-(id) spawn: (CCLayer*) layer: (b2World*) world: (b2Body*) groundBody;
-(void) respawnLeft;
-(void) respawnRight;
-(void) respawnCenter;
-(void) dealloc;
-(void) gameOver;
-(b2Body *) getBody;
-(void) addBall: (b2World*) world;
-(void) removeBall;

@end
