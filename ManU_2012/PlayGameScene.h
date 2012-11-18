//
//  PlayGameScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"
#import "Ball.h"
#import "Player.h"
#import "BoxDebugLayer.h"
#import "ContactListener.h"
#import "Timer.h"
#define PTM_RATIO 32

@interface PlayGameScene : CCLayer {
    //CCSprite *ball;
    CCSprite *player1;
    CCSprite *player2;
    PhysicsSprite *player1Sprite;
    b2Body *player1Body;
    b2Fixture *player1Fixture;
    PhysicsSprite *player2Sprite;
    b2Body *body2;
    //PhysicsSprite *ballSprite;
    //b2Body *bodyBall;
    Ball *ball;
    Player *players;
    CCSprite *bg;
    CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    b2MouseJoint *_mouseJoint;
    b2Body* groundBody;
    CCLabelTTF *_leftScoreLabel;
    CCLabelTTF *_rightScoreLabel;
    CCLabelTTF *_leftShotsOnGoalLabel;
    CCLabelTTF *_rightShotsOnGoalLabel;
    CGSize winSize;
    GLESDebugDraw *_debugDraw;
    
    Timer* timer;
    
    ContactListener* contactListener;
}
+(CCScene*)scene;
-(void) initPhysics;
@end
