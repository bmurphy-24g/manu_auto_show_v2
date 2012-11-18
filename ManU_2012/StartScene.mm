//
//  StartScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StartScene.h"


@implementation StartScene

-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"background2.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        
        [self addChild:bg z:0];
        
        startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [startButton setFrame:CGRectMake(500, 110, 289, 67)];
        [startButton setBackgroundImage:[UIImage imageNamed:@"continue_btn.png"] forState:UIControlStateNormal];
        [startButton addTarget:self action:@selector(buttonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                                    RADIANS(270.0));
        startButton.transform = rotateTransform;
        [[[[CCDirector sharedDirector] view] window] addSubview:startButton];
        
        
	}
	return self;
}

- (IBAction)buttonPressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Button Pressed");
    [startButton removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[LegalScene scene] withColor:ccWHITE]];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StartScene *layer = [StartScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


@end
