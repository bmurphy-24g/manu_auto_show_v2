//
//  TakePhotoScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TakePhotoScene.h"
#import "TakePhotoViewController.h"


@implementation TakePhotoScene

-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"camera_overlay.png"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        //[self addChild:bg z:1];
        
        viewController = [[TakePhotoViewController alloc] init];
        [[[CCDirector sharedDirector] view] addSubview:viewController.view];
        
	}
	return self;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TakePhotoScene *layer = [TakePhotoScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)dealloc
{
    [super dealloc];
    [viewController.view removeFromSuperview];
    NSLog(@"dealloc TakePhotoScene");
}

@end
