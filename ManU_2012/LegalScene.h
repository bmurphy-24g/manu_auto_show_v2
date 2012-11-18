//
//  LegalScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SelectPhotoScene.h"

@interface LegalScene : CCLayer {
    CCSprite *bg;
    CGSize winSize;
    UIButton* acceptButton;
}
+(CCScene *) scene;
-(IBAction)acceptPressedAction:(id)sender;

@end
