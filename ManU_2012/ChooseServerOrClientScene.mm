//
//  ChooseServerOrClientScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooseServerOrClientScene.h"
#import "StartScene.h"

@implementation ChooseServerOrClientScene
-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"blank.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:0];
        
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        startClientButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 224, 471, 149)];
        [startClientButton setBackgroundImage:[UIImage imageNamed:@"startclient_btn.png"] forState:UIControlStateNormal];
        [startClientButton addTarget:self action:@selector(startClientPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:startClientButton];
        
        startServerButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 404, 471, 149)];
        [startServerButton setBackgroundImage:[UIImage imageNamed:@"startserver_btn.png"] forState:UIControlStateNormal];
        [startServerButton addTarget:self action:@selector(startServerPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:startServerButton];
	}
	return self;
}

- (IBAction)startServerPressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Server Pressed");
    [startClientButton removeFromSuperview];
    [startServerButton removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[WaitingForPlayersScreen scene] withColor:ccWHITE]];
}

-(IBAction)startClientPressedAction:(id)sender
{
    NSLog(@"Client Pressed");
    [startClientButton removeFromSuperview];
    [startServerButton removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseServerOrClientScene *layer = [ChooseServerOrClientScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)dealloc
{
    NSLog(@"choose dealloc");
    [newView release];
    [startClientButton release];
    [startServerButton release];
    [super dealloc];
}



@end
