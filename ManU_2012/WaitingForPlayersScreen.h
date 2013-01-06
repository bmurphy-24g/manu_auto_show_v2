//
//  WaitingForPlayersScreen.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MatchmakingServer.h"
#import "PhysicsSprite.h"
#import "Ball.h"
#import "Player.h"
#import "Timer.h"
#import "ContactListener.h"
#import "PlayerHold.h"
#import "Countdown.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface WaitingForPlayersScreen : CCLayer <MatchmakingServerDelegate, GKSessionDelegate> {
    CCSprite* bg;
    CGSize winSize;
    UIView* newView; 
    UIButton* startOnePlayerButton; //Need to release
    UIButton* startGameButton; //Need to release
    UIImage* playerOneImage;
    UIImage* playerTwoImage;
    MatchmakingServer *_matchmakingServer; 
    UIImageView* playerOneImageView; 
    UIImageView* playerTwoImageView; 
    NSString* playerOneName; 
    NSString* playerTwoName; 
    UILabel* playerOneNameLabel; 
    UILabel* playerTwoNameLabel; 
    UIImageView* smallPlayerOneImageView; 
    UIImageView* smallPlayerTwoImageView; 
    UILabel* smallPlayerOneNameLabel; 
    UILabel* smallPlayerTwoNameLabel;
    UILabel* scoreScreenPlayerOneShots;
    UILabel* scoreScreenPlayerOneGoals;
    UILabel* scoreScreenPlayerTwoShots;
    UILabel* scoreScreenPlayerTwoGoals;
    
    UIImageView* screenSaverBackground1;
    UIImageView* screenSaverBackground2;
    UIImageView* screenSaverBackground3;
    UIImageView* screenSaverBackground4;
    UIImageView* screenSaver1Icon1;
    UIImageView* screenSaver1Icon2;
    UIImageView* screenSaver2Icon1;
    UIImageView* screenSaver2Icon2;
    UIImageView* screenSaver2Icon3;
    UIImageView* screenSaver3Icon1;
    UIImageView* screenSaver3Icon2;
    UIImageView* screenSaver3Icon3;
    UIImageView* screenSaver4Icon1;
    UIImageView* screenSaver4Icon2;
    UIImageView* screenSaver4Icon3;
    
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
    //Player *players_server;
    CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    b2MouseJoint *_mouseJoint;
    b2Body* groundBody;
    CCLabelTTF *_leftScoreLabel;
    CCLabelTTF *_rightScoreLabel;
    CCLabelTTF *_leftShotsOnGoalLabel;
    CCLabelTTF *_rightShotsOnGoalLabel;
    GLESDebugDraw *_debugDraw;
    
    Timer* timer;
    
    ContactListener* contactListener;
    
    PhysicsSprite *SpriteLeft;
    PhysicsSprite *SpriteRight;
    b2Body* BodyLeft;
    b2Body* BodyRight;
    b2Body* BodyBall;
    b2Fixture* FixtureLeft;
    b2Fixture* FixtureRight;
    
    Countdown* countdown;
    
    //PlayerHold* playerHold;
    bool receivedPlayerOneImage, receivedPlayerOneName, receivedPlayerTwoImage, receivedPlayerTwoName, gameHasStarted;
    AVAudioPlayer *singleWhistlePlayer;
    AVAudioPlayer *tripleWhistlePlayer;
    AVAudioPlayer *crowdPlayer;
    
    
    UIView* largeView;
    
    NSTimer* scoreScreenTimer;
    
    bool playerHasJoined;
    
}
@property(nonatomic,retain) PhysicsSprite* SpriteLeft;
@property(nonatomic,retain) PhysicsSprite* SpriteRight;
@property(readonly,assign) b2Body* BodyLeft;
@property(readonly,assign) b2Body* BodyRight;
@property(readonly,assign) b2Body* BodyBall;
@property(readonly,assign) b2Fixture* FixtureLeft;
@property(readonly,assign) b2Fixture* FixtureRight;

+(CCScene *) scene;
@end
