//
//  LegalScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LegalScene.h"


@implementation LegalScene

-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"background3.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:0];
        
        acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton setFrame:CGRectMake(550, 110, 289, 67)];
        [acceptButton setBackgroundImage:[UIImage imageNamed:@"accept_btn.png"] forState:UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(acceptPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                                    RADIANS(270.0));
        acceptButton.transform = rotateTransform;
        [[[[CCDirector sharedDirector] view] window] addSubview:acceptButton];

	}
	return self;
}

- (IBAction)acceptPressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Button Pressed");
    [acceptButton removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[SelectPhotoScene scene] withColor:ccWHITE]];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LegalScene *layer = [LegalScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

@end
