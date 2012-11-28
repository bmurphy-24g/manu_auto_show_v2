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

@interface ChooseServerOrClientScene : CCLayer {
    CCSprite* bg;
    CGSize winSize;
    UIButton* startServerButton;
    UIButton* startClientButton;
    UIView* newView;
    UIImageView* backgroundImageView;
}
+(CCScene *) scene;
@end
