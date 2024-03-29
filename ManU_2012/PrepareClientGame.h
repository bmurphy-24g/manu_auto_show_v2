//
//  PrepareClientGame.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MatchmakingClient.h"
#import "FinalShareScene.h"
#import "iCadeReaderView.h"
#import "BluetoothManager.h"

@interface PrepareClientGame : CCLayer <MatchmakingClientDelegate, GKSessionDelegate, iCadeEventDelegate> {
    CCSprite* bg;
    CGSize winSize;
    UIView* newView;
    MatchmakingClient *_matchmakingClient;
    NSString* playerPref;
    UIImage* playerImage;
    NSString* playerName;
    NSString* serverPeerID;
    UIImageView* imageView;
    UIButton* exitButton;
    NSString* shotsOnGoal;
    NSString* score;
    NSString* playerPosition;
    NSString* playerNumber;
    NSString* playerFirstName;
    NSString* playerLastName;
    NSString* cloudFileName;
    UIButton* startGameButton;
    UIButton* startOnePlayer;
    BluetoothManager* bluetoothManager;
    bool receivedPlayer, receivedGameOver, receivedScore, receivedShots, gameStarting;
    float xAccelToSend;
    NSTimer* sendICadeTimer;
}
@property (nonatomic, copy) UIImage* playerImage;
@property (nonatomic, copy) NSString* playerName;
@property (nonatomic, copy) NSString* playerPosition;
@property (nonatomic, copy) NSString* playerNumber;
@property (nonatomic, copy) NSString* playerFirstName;
@property (nonatomic, copy) NSString* playerLastName;
@property (nonatomic, copy) NSString* cloudFileName;
@property (nonatomic, copy) UIImage* currentImage;
+(CCScene *) scene :(UIImage*)img :(NSString*)name :(NSString*)position :(NSString*)number :(NSString*)firstName :(NSString*)lastName :(NSString*)fileName;
@end
