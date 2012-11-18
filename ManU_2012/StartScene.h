//
//  StartScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LegalScene.h"

@interface StartScene : CCLayer {
    CCSprite *bg;
    CGSize winSize;
    UIButton* startButton;
}
+(CCScene *) scene;
-(IBAction)buttonPressedAction:(id)sender;
@end
