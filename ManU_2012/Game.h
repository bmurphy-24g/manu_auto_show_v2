//
//  Game.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Game : CCNode {
    
}

-(void)startGameWithSession:(GKSession*)session player:(NSString*)playerNum;
-(void)sendXAccel:(float)x needsReliable:(BOOL)reliable;

@end
