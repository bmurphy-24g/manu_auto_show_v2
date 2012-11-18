//
//  Timer.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Timer : CCNode {
    CCLabelTTF *_timerLabel;
    int seconds;
    int minutes;
    CGSize _winSize;
    CCLayer* parentLayer;
}
-(void)stopTimer;
-(id) spawn: (CCLayer*) layer;
-(void)startTimer;

@end
