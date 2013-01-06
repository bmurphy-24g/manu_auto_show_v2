//
//  ChooseServerOrClientScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WaitingForPlayersScreen.h"
#import "RSClient.h"
#import "BluetoothManager.h"

@interface ChooseServerOrClientScene : CCLayer {
    CCSprite* bg;
    CGSize winSize;
    UIButton* startServerButton;
    UIButton* startClientButton;
    UIButton* shareAssetsButton;
    UIView* newView;
    UIImageView* backgroundImageView;
    RSClient* _rsClient;
    RSContainer* container;
    RSStorageObject* object;
    BluetoothManager* btManager;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
+(CCScene *) scene;
@end
