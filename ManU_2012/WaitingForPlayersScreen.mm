//
//  WaitingForPlayersScreen.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WaitingForPlayersScreen.h"

bool gameOverNaturally;
@implementation WaitingForPlayersScreen

int LEFT_PLAYER_TAG = 6221, RIGHT_PLAYER_TAG = 6223;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	WaitingForPlayersScreen *layer = [WaitingForPlayersScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

bool clientDisconnected = NO;

-(id) init
{
	if( (self=[super init])) {
                
        //Still need to handle error
        NSError *error = nil;
        
        winSize = [CCDirector sharedDirector].winSize;
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        // 89x264 146x195
        playerOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(89, 263, 146, 195)];
        playerOneImageView.contentMode = UIViewContentModeScaleAspectFit;
        playerOneImageView.clipsToBounds = NO;
        playerOneImageView.layer.masksToBounds = NO;
        
        // 777x264
        playerTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(777, 263, 146, 195)];
        playerTwoImageView.contentMode = UIViewContentModeScaleAspectFit;
        playerTwoImageView.clipsToBounds = NO;
        playerTwoImageView.layer.masksToBounds = NO;
        
        // 10x470
        playerOneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 469, 333, 45)];
        
        playerTwoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(700, 469, 333, 45)];
        
        scoreScreenPlayerOneGoals = [[UILabel alloc] initWithFrame:CGRectMake(13, 306, 270, 45)];
        scoreScreenPlayerOneShots = [[UILabel alloc] initWithFrame:CGRectMake(13, 383, 270, 45)];
        scoreScreenPlayerTwoGoals = [[UILabel alloc] initWithFrame:CGRectMake(730, 306, 270, 45)];
        scoreScreenPlayerTwoShots = [[UILabel alloc] initWithFrame:CGRectMake(730, 383, 270, 45)];
        
        // 524x157
        startGameButton = [[UIButton alloc] initWithFrame:CGRectMake(524, 157, 253, 106)];
        
        startOnePlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(524, 157, 253, 106)];
        
        NSString *singlePath = [NSString stringWithFormat:@"%@/whistle1.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *singleURL = [NSURL fileURLWithPath:singlePath];
        singleWhistlePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:singleURL error:&error];
        singleWhistlePlayer.numberOfLoops = 0;
        
        NSString *triplePath = [NSString stringWithFormat:@"%@/whistle3.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *tripleURL = [NSURL fileURLWithPath:triplePath];
        tripleWhistlePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tripleURL error:&error];
        tripleWhistlePlayer.numberOfLoops = 0;
        
        NSString *crowdPath = [NSString stringWithFormat:@"%@/cheer.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *crowdURL = [NSURL fileURLWithPath:crowdPath];
        crowdPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:crowdURL error:&error];
        crowdPlayer.numberOfLoops = 0;
        
        // 201x97 35x45
        smallPlayerOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(201, 97, 35, 45)];
        [smallPlayerOneImageView retain];
        
        // 785x97 35x45
        smallPlayerTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(785, 97, 35, 45)];
        [smallPlayerTwoImageView retain];
        
        //236x97 185x45
        smallPlayerOneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 97, 185, 45)];
        [smallPlayerOneNameLabel retain];
        
        //700x97 185x45 //822
        smallPlayerTwoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(586, 97, 185, 45)];
        [smallPlayerTwoNameLabel retain];
        
        playerOneImage = nil;
        [playerOneImage retain];
        playerTwoImage = nil;
        [playerTwoImage retain];
        
        countdown = [Countdown alloc];
        
        // init physics
        [self initPhysics];
        
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(update:) forTarget:self interval:0 paused:YES];
        [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:YES];
        
        ball = [Ball alloc];
        [ball spawn:self :world :groundBody];
        [self spawnPlayers];
        
        timer = [[Timer alloc] spawn:self];
        
        [countdown spawn:self];
        
        
        
        [self setUpWaitScreen:YES :YES];
        
        playerHasJoined = NO;
        
	}
	return self;
}

-(void)talkToKevinsTrackingPage
{
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    NSString* location = [[NSUserDefaults standardUserDefaults] stringForKey:@"location"];
    NSString *urlString = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/resources/ios_tracking.php?location_id=%@", [location lowercaseString]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:7.5f];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    NSLog(@"Talking to Kevin");
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    //connection
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        NSLog(@"Error");
    }
    NSLog(@"Finished talking to kevin");
    [request release];
    request = NULL;
}

#pragma mark Wait Screen

-(void)setUpWaitScreen: (bool)disconnected  :(bool)init//Game finished
{
    [self talkToKevinsTrackingPage];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        bg = [CCSprite spriteWithFile:@"results_retina.jpg"];
    } else {
        bg = [CCSprite spriteWithFile:@"results.jpg"];
    }
    
    bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:bg z:0 tag:421];
    
    
    if(!init) //Dealloc game
    {
        
    }
    /*
     [smallPlayerOneNameLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
     smallPlayerOneNameLabel.textAlignment = NSTextAlignmentLeft;
    */
    [scoreScreenPlayerOneGoals setText:[NSString stringWithFormat:@"Goals    %d", _leftScore_SERVER]];
    [scoreScreenPlayerOneGoals setFont:[UIFont fontWithName:@"Arial" size:30]];
    scoreScreenPlayerOneGoals.textAlignment = NSTextAlignmentRight;
    [scoreScreenPlayerOneGoals setTextColor:[UIColor whiteColor]];
    [scoreScreenPlayerOneGoals setBackgroundColor:[UIColor clearColor]];
    [newView addSubview:scoreScreenPlayerOneGoals];
    [scoreScreenPlayerOneShots setText:[NSString stringWithFormat:@"Shots on Goal    %d", _leftShotsOnGoal_SERVER]];
    [scoreScreenPlayerOneShots setFont:[UIFont fontWithName:@"Arial" size:30]];
    scoreScreenPlayerOneShots.textAlignment = NSTextAlignmentRight;
    [scoreScreenPlayerOneShots setTextColor:[UIColor whiteColor]];
    [scoreScreenPlayerOneShots setBackgroundColor:[UIColor clearColor]];
    [newView addSubview:scoreScreenPlayerOneShots];
    [scoreScreenPlayerTwoGoals setText:[NSString stringWithFormat:@"Goals    %d", _rightScore_SERVER]];
    [scoreScreenPlayerTwoGoals setFont:[UIFont fontWithName:@"Arial" size:30]];
    scoreScreenPlayerTwoGoals.textAlignment = NSTextAlignmentRight;
    [scoreScreenPlayerTwoGoals setTextColor:[UIColor whiteColor]];
    [scoreScreenPlayerTwoGoals setBackgroundColor:[UIColor clearColor]];
    [newView addSubview:scoreScreenPlayerTwoGoals];
    [scoreScreenPlayerTwoShots setText:[NSString stringWithFormat:@"Shots on Goal    %d", _rightShotsOnGoal_SERVER]];
    [scoreScreenPlayerTwoShots setFont:[UIFont fontWithName:@"Arial" size:30]];
    scoreScreenPlayerTwoShots.textAlignment = NSTextAlignmentRight;
    [scoreScreenPlayerTwoShots setTextColor:[UIColor whiteColor]];
    [scoreScreenPlayerTwoShots setBackgroundColor:[UIColor clearColor]];
    [newView addSubview:scoreScreenPlayerTwoShots];
    
    [playerOneNameLabel setBackgroundColor:[UIColor clearColor]];
    [playerOneNameLabel setTextColor:[UIColor whiteColor]];
    [playerOneNameLabel setMinimumScaleFactor:100];
    
    [playerTwoNameLabel setBackgroundColor:[UIColor clearColor]];
    [playerTwoNameLabel setTextColor:[UIColor blackColor]];
    [playerTwoNameLabel setMinimumScaleFactor:100];
    
    if(!disconnected)
    {
        [playerOneNameLabel setText:playerOneName];
        [playerTwoNameLabel setText:playerTwoName];
    }
    
    [smallPlayerOneNameLabel setText:@""];
    [smallPlayerTwoNameLabel setText:@""];
    
    [newView addSubview:playerOneNameLabel];
    [newView addSubview:playerTwoNameLabel];
    
    [startGameButton setBackgroundImage:[UIImage imageNamed:@"statgame_btn.png"] forState:UIControlStateNormal];
    [startGameButton addTarget:self action:@selector(startGamePressedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [startOnePlayerButton setBackgroundImage:[UIImage imageNamed:@"1player_btn.png"] forState:UIControlStateNormal];
    [startOnePlayerButton addTarget:self action:@selector(startOnePlayerPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if(!disconnected)
        scoreScreenTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(finishedScoreScreen) userInfo:nil repeats:NO];
    else
        [self finishedScoreScreen];
}

#pragma mark - Animations

-(void) removeAllAnimations
{
    //1
    if(screenSaverBackground1 != nil)
    {
        [screenSaverBackground1 removeFromSuperview];
        [screenSaverBackground1 release];
        screenSaverBackground1 = nil;
    }
    if(screenSaver1Icon1 != nil)
    {
        [screenSaver1Icon1 removeFromSuperview];
        [screenSaver1Icon1 release];
        screenSaver1Icon1 = nil;
    }
    if(screenSaver1Icon2 != nil)
    {
        [screenSaver1Icon2 removeFromSuperview];
        [screenSaver1Icon2 release];
        screenSaver1Icon2 = nil;
    }
    
    //2
    if(screenSaverBackground2 != nil)
    {
        [screenSaverBackground2 removeFromSuperview];
        [screenSaverBackground2 release];
        screenSaverBackground2 = nil;
    }
    if(screenSaver2Icon1 != nil)
    {
        [screenSaver2Icon1 removeFromSuperview];
        [screenSaver2Icon1 release];
        screenSaver2Icon1 = nil;
    }
    if(screenSaver2Icon2 != nil)
    {
        [screenSaver2Icon2 removeFromSuperview];
        [screenSaver2Icon2 release];
        screenSaver2Icon2 = nil;
    }
    if(screenSaver2Icon3 != nil)
    {
        [screenSaver2Icon3 removeFromSuperview];
        [screenSaver2Icon3 release];
        screenSaver2Icon3 = nil;
    }
    
    //3
    if(screenSaverBackground3 != nil)
    {
        [screenSaverBackground3 removeFromSuperview];
        [screenSaverBackground3 release];
        screenSaverBackground3 = nil;
    }
    if(screenSaver3Icon1 != nil)
    {
        [screenSaver3Icon1 removeFromSuperview];
        [screenSaver3Icon1 release];
        screenSaver3Icon1 = nil;
    }
    if(screenSaver3Icon2 != nil)
    {
        [screenSaver3Icon2 removeFromSuperview];
        [screenSaver3Icon2 release];
        screenSaver3Icon2 = nil;
    }
    if(screenSaver3Icon3 != nil)
    {
        [screenSaver3Icon3 removeFromSuperview];
        [screenSaver3Icon3 release];
        screenSaver3Icon3 = nil;
    }
    
    //4
    if(screenSaverBackground4 != nil)
    {
        [screenSaverBackground4 removeFromSuperview];
        [screenSaverBackground4 release];
        screenSaverBackground4 = nil;
    }
    if(screenSaver4Icon1 != nil)
    {
        [screenSaver4Icon1 removeFromSuperview];
        [screenSaver4Icon1 release];
        screenSaver4Icon1 = nil;
    }
    if(screenSaver4Icon2 != nil)
    {
        [screenSaver4Icon2 removeFromSuperview];
        [screenSaver4Icon2 release];
        screenSaver4Icon2 = nil;
    }
    if(screenSaver4Icon3 != nil)
    {
        [screenSaver4Icon3 removeFromSuperview];
        [screenSaver4Icon3 release];
        screenSaver4Icon3 = nil;
    }
    if(iconsSaver4 != nil)
    {
        [iconsSaver4 removeFromSuperview];
        [iconsSaver4 release];
        iconsSaver4 = nil;
    }
    
}

-(void) startScreenSaverAnimations
{
    [screenSaverBackground1 setAlpha:1.0F];
    [screenSaverBackground2 setAlpha:0.0F];
    [screenSaverBackground3 setAlpha:0.0F];
    [screenSaverBackground4 setAlpha:0.0F];
    
    [newView addSubview:screenSaverBackground1];
    [newView addSubview:screenSaverBackground2];
    [newView addSubview:screenSaverBackground3];
    [newView addSubview:screenSaverBackground4];
    
    [self screenSaver1FadeIn];
}

-(void) screenSaver1FadeIn
{
    [screenSaverBackground2 setAlpha:0.0F];
    [screenSaverBackground3 setAlpha:0.0F];
    if(!playerHasJoined)
    {
        [UIView animateWithDuration:2.0F animations:^()
         {
             [screenSaverBackground4 setAlpha:0.0F];
         }
         completion:^(BOOL finished)
         {
             if(!playerHasJoined)
                 [self screenSaver1IconsSlideIn];
         }];
    }
}

-(void) screenSaver1IconsSlideIn
{
    if(!playerHasJoined)
    {
        [screenSaverBackground4 setAlpha:0.0F];
        if (false) {//[[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            //&& [[UIScreen mainScreen] scale] == 2.0) {
            NSLog(@"retina!");
            screenSaver1Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-1514, 251, 1514, 120)];
            screenSaver1Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-860, 377, 860, 242)];
        } else {
            NSLog(@"Not retina!");
            screenSaver1Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-757, 125, 757, 60)];
            screenSaver1Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-430, 188, 430, 121)];
        }
        
        [screenSaver1Icon1 setImage:[UIImage imageNamed:@"text_1a.png"]];
        [screenSaver1Icon2 setImage:[UIImage imageNamed:@"text_1b.png"]];

        [newView addSubview:screenSaver1Icon1];
        [newView addSubview:screenSaver1Icon2];
        
        //screenSaver1Icon1 set
        [UIView animateWithDuration:0.3F animations:^()
         {
             CGRect cgr1 = screenSaver1Icon1.frame;
             [screenSaver1Icon1 setFrame:CGRectMake(0, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
         }
         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.3F animations:^()
              {
                  CGRect cgr2 = screenSaver1Icon2.frame;
                  [screenSaver1Icon2 setFrame:CGRectMake(0, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
              }
              completion:^(BOOL finished)
              {
                  if(!playerHasJoined)
                      [self screenSaver1IconsSlideOut];
                  else
                  {
                      [screenSaver1Icon1 removeFromSuperview];
                      [screenSaver1Icon2 removeFromSuperview];
                      [screenSaver1Icon1 setImage:nil];
                      [screenSaver1Icon2 setImage:nil];
                      [screenSaver1Icon1 release];
                      [screenSaver1Icon2 release];
                      screenSaver1Icon1 = nil;
                      screenSaver1Icon2 = nil;
                  }
              }];
         }];
    }
}

-(void) screenSaver1IconsSlideOut
{
    [UIView animateWithDuration:0.3F delay:5.0 options:nil animations:^()
     {
         CGRect cgr1 = screenSaver1Icon1.frame;
         [screenSaver1Icon1 setFrame:CGRectMake(-1514, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver1Icon2.frame;
              [screenSaver1Icon2 setFrame:CGRectMake(-860, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [screenSaver1Icon1 removeFromSuperview];
              [screenSaver1Icon2 removeFromSuperview];
              [screenSaver1Icon1 setImage:nil];
              [screenSaver1Icon2 setImage:nil];
              [screenSaver1Icon1 release];
              [screenSaver1Icon2 release];
              screenSaver1Icon1 = nil;
              screenSaver1Icon2 = nil;
              if(!playerHasJoined)
                  [self screenSaver2FadeIn];
          }];
     }];
}

-(void) screenSaver2FadeIn
{
    [UIView animateWithDuration:2.0F animations:^()
     {
         [screenSaverBackground2 setAlpha:1.0F];
     }
                     completion:^(BOOL finished)
     {
         if(!playerHasJoined)
             [self screenSaver2IconsSlideIn];
     }];
}

-(void) screenSaver2IconsSlideIn
{
    [screenSaverBackground3 setAlpha:0.0F];
    if (false) {//[[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        //&& [[UIScreen mainScreen] scale] == 2.0) {
        screenSaver2Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-780, 491, 780, 120)];
        screenSaver2Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-943, 619, 943, 120)];
        screenSaver2Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-860, 747, 860, 242)];
    } else {
        screenSaver2Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-390, 245, 390, 60)];
        screenSaver2Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-472, 309, 472, 60)];
        screenSaver2Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-430, 373, 430, 121)];
    }
    
    [screenSaver2Icon1 setImage:[UIImage imageNamed:@"text_2a.png"]];
    [screenSaver2Icon2 setImage:[UIImage imageNamed:@"text_2b.png"]];
    [screenSaver2Icon3 setImage:[UIImage imageNamed:@"text_2c.png"]];
    
    [newView addSubview:screenSaver2Icon1];
    [newView addSubview:screenSaver2Icon2];
    [newView addSubview:screenSaver2Icon3];
    
    //screenSaver1Icon1 set
    [UIView animateWithDuration:0.3F animations:^()
     {
         CGRect cgr1 = screenSaver2Icon1.frame;
         [screenSaver2Icon1 setFrame:CGRectMake(0, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver2Icon2.frame;
              [screenSaver2Icon2 setFrame:CGRectMake(0, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver2Icon3.frame;
                   [screenSaver2Icon3 setFrame:CGRectMake(0, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
               }
                               completion:^(BOOL finished)
               {
                   if(!playerHasJoined)
                       [self screenSaver2IconsSlideOut];
                   else
                   {
                       [screenSaver2Icon1 removeFromSuperview];
                       [screenSaver2Icon2 removeFromSuperview];
                       [screenSaver2Icon3 removeFromSuperview];
                       [screenSaver2Icon1 setImage:nil];
                       [screenSaver2Icon2 setImage:nil];
                       [screenSaver2Icon3 setImage:nil];
                       [screenSaver2Icon1 release];
                       [screenSaver2Icon2 release];
                       [screenSaver2Icon3 release];
                       screenSaver2Icon1 = nil;
                       screenSaver2Icon2 = nil;
                       screenSaver2Icon3 = nil;
                   }
               }];
          }];
     }];
}

-(void) screenSaver2IconsSlideOut
{
    [UIView animateWithDuration:0.3F delay:5.0 options:nil animations:^()
     {
         CGRect cgr1 = screenSaver2Icon1.frame;
         [screenSaver2Icon1 setFrame:CGRectMake(-780, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver2Icon2.frame;
              [screenSaver2Icon2 setFrame:CGRectMake(-943, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver2Icon3.frame;
                   [screenSaver2Icon3 setFrame:CGRectMake(-860, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
               }
                               completion:^(BOOL finished)
               {
                   [screenSaver2Icon1 removeFromSuperview];
                   [screenSaver2Icon2 removeFromSuperview];
                   [screenSaver2Icon3 removeFromSuperview];
                   [screenSaver2Icon1 setImage:nil];
                   [screenSaver2Icon2 setImage:nil];
                   [screenSaver2Icon3 setImage:nil];
                   [screenSaver2Icon1 release];
                   [screenSaver2Icon2 release];
                   [screenSaver2Icon3 release];
                   screenSaver2Icon1 = nil;
                   screenSaver2Icon2 = nil;
                   screenSaver2Icon3 = nil;
                   if(!playerHasJoined)
                       [self screenSaver3FadeIn];
               }];
          }];
     }];
}

-(void) screenSaver3FadeIn
{
    [UIView animateWithDuration:2.0F animations:^()
     {
         [screenSaverBackground3 setAlpha:1.0F];
     }
                     completion:^(BOOL finished)
     {
         if(!playerHasJoined)
             [self screenSaver3IconsSlideIn];
     }];
}

-(void) screenSaver3IconsSlideIn
{
    if (false) {//[[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        //&& [[UIScreen mainScreen] scale] == 2.0) {
        screenSaver3Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-780, 591, 780, 120)];
        screenSaver3Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-720, 719, 720, 120)];
        screenSaver3Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-914, 847, 914, 307)];
    } else {
        screenSaver3Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-390, 295, 390, 60)];
        screenSaver3Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-360, 359, 360, 60)];
        screenSaver3Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-457, 423, 457, 154)];
    }
    
    [screenSaver3Icon1 setImage:[UIImage imageNamed:@"text_3a.png"]];
    [screenSaver3Icon2 setImage:[UIImage imageNamed:@"text_3b.png"]];
    [screenSaver3Icon3 setImage:[UIImage imageNamed:@"text_3c.png"]];
    
    [newView addSubview:screenSaver3Icon1];
    [newView addSubview:screenSaver3Icon2];
    [newView addSubview:screenSaver3Icon3];
    
    //screenSaver1Icon1 set
    [UIView animateWithDuration:0.3F animations:^()
     {
         CGRect cgr1 = screenSaver3Icon1.frame;
         [screenSaver3Icon1 setFrame:CGRectMake(0, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver3Icon2.frame;
              [screenSaver3Icon2 setFrame:CGRectMake(0, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver3Icon3.frame;
                   [screenSaver3Icon3 setFrame:CGRectMake(0, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
               }
                               completion:^(BOOL finished)
               {
                   if(!playerHasJoined)
                       [self screenSaver3IconsSlideOut];
                   else
                   {
                       [screenSaver3Icon1 removeFromSuperview];
                       [screenSaver3Icon2 removeFromSuperview];
                       [screenSaver3Icon3 removeFromSuperview];
                       [screenSaver3Icon1 setImage:nil];
                       [screenSaver3Icon2 setImage:nil];
                       [screenSaver3Icon3 setImage:nil];
                       [screenSaver3Icon1 release];
                       [screenSaver3Icon2 release];
                       [screenSaver3Icon3 release];
                       screenSaver3Icon1 = nil;
                       screenSaver3Icon2 = nil;
                       screenSaver3Icon3 = nil;
                   }
               }];
          }];
     }];
}

-(void) screenSaver3IconsSlideOut
{
    [UIView animateWithDuration:0.3F delay:5.0 options:nil animations:^()
     {
         CGRect cgr1 = screenSaver3Icon1.frame;
         [screenSaver3Icon1 setFrame:CGRectMake(-780, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver3Icon2.frame;
              [screenSaver3Icon2 setFrame:CGRectMake(-720, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver3Icon3.frame;
                   [screenSaver3Icon3 setFrame:CGRectMake(-914, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
               }
                               completion:^(BOOL finished)
               {
                   [screenSaver3Icon1 removeFromSuperview];
                   [screenSaver3Icon2 removeFromSuperview];
                   [screenSaver3Icon3 removeFromSuperview];
                   [screenSaver3Icon1 setImage:nil];
                   [screenSaver3Icon2 setImage:nil];
                   [screenSaver3Icon3 setImage:nil];
                   [screenSaver3Icon1 release];
                   [screenSaver3Icon2 release];
                   [screenSaver3Icon3 release];
                   screenSaver3Icon1 = nil;
                   screenSaver3Icon2 = nil;
                   screenSaver3Icon3 = nil;
                   if(!playerHasJoined)
                       [self screenSaver4FadeIn];
               }];
          }];
     }];
}

-(void) screenSaver4FadeIn
{
    iconsSaver4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 507, 294, 163)];
    [iconsSaver4 setImage:[UIImage imageNamed:@"icons.png"]];
    [iconsSaver4 setAlpha:0.0f];
    [newView addSubview:iconsSaver4];
    [UIView animateWithDuration:2.0F animations:^()
     {
         [screenSaverBackground4 setAlpha:1.0F];
         [iconsSaver4 setAlpha:1.0f];
     }
                     completion:^(BOOL finished)
     {
         
         if(!playerHasJoined)
             [self screenSaver4IconsSlideIn];
     }];
}

-(void) screenSaver4IconsSlideIn
{
    if (false) {//[[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        //&& [[UIScreen mainScreen] scale] == 2.0) {
        screenSaver4Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-1291, 391, 1291, 120)];
        screenSaver4Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-1426, 519, 1426, 242)];
        screenSaver4Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-1073, 767, 1073, 120)];
    } else {
        screenSaver4Icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(-646, 195, 646, 60)];
        screenSaver4Icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(-713, 259, 713, 121)];
        screenSaver4Icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(-537, 383, 537, 60)];
    }
    
    [screenSaver4Icon1 setImage:[UIImage imageNamed:@"text_4a.png"]];
    [screenSaver4Icon2 setImage:[UIImage imageNamed:@"text_4b.png"]];
    [screenSaver4Icon3 setImage:[UIImage imageNamed:@"text_4c.png"]];
    
    [newView addSubview:screenSaver4Icon1];
    [newView addSubview:screenSaver4Icon2];
    [newView addSubview:screenSaver4Icon3];
    
    //screenSaver1Icon1 set
    [UIView animateWithDuration:0.3F animations:^()
     {
         CGRect cgr1 = screenSaver4Icon1.frame;
         [screenSaver4Icon1 setFrame:CGRectMake(0, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver4Icon2.frame;
              [screenSaver4Icon2 setFrame:CGRectMake(0, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver4Icon3.frame;
                   [screenSaver4Icon3 setFrame:CGRectMake(0, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
               }
                               completion:^(BOOL finished)
               {
                    if(!playerHasJoined)
                        [self screenSaver4IconsSlideOut];
                   else
                   {
                       [screenSaver4Icon1 removeFromSuperview];
                       [screenSaver4Icon2 removeFromSuperview];
                       [screenSaver4Icon3 removeFromSuperview];
                       [screenSaver4Icon1 setImage:nil];
                       [screenSaver4Icon2 setImage:nil];
                       [screenSaver4Icon3 setImage:nil];
                       [screenSaver4Icon1 release];
                       [screenSaver4Icon2 release];
                       [screenSaver4Icon3 release];
                       screenSaver4Icon1 = nil;
                       screenSaver4Icon2 = nil;
                       screenSaver4Icon3 = nil;
                   }
               }];
          }];
     }];
}

-(void) screenSaver4IconsSlideOut
{
    [UIView animateWithDuration:0.3F delay:5.0 options:nil animations:^()
     {
         CGRect cgr1 = screenSaver4Icon1.frame;
         [screenSaver4Icon1 setFrame:CGRectMake(-1291, cgr1.origin.y, cgr1.size.width, cgr1.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3F animations:^()
          {
              CGRect cgr2 = screenSaver4Icon2.frame;
              [screenSaver4Icon2 setFrame:CGRectMake(-1426, cgr2.origin.y, cgr2.size.width, cgr2.size.height)];
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3F animations:^()
               {
                   CGRect cgr3 = screenSaver4Icon3.frame;
                   [screenSaver4Icon3 setFrame:CGRectMake(-1073, cgr3.origin.y, cgr3.size.width, cgr3.size.height)];
                   [iconsSaver4 setAlpha:0.0f];
               }
                               completion:^(BOOL finished)
               {
                   [screenSaver4Icon1 removeFromSuperview];
                   [screenSaver4Icon2 removeFromSuperview];
                   [screenSaver4Icon3 removeFromSuperview];
                   [iconsSaver4 removeFromSuperview];
                   [screenSaver4Icon1 setImage:nil];
                   [screenSaver4Icon2 setImage:nil];
                   [screenSaver4Icon3 setImage:nil];
                   [iconsSaver4 setImage:nil];
                   [screenSaver4Icon1 release];
                   [screenSaver4Icon2 release];
                   [screenSaver4Icon3 release];
                   [iconsSaver4 release];
                   screenSaver4Icon1 = nil;
                   screenSaver4Icon2 = nil;
                   screenSaver4Icon3 = nil;
                   iconsSaver4 = nil;
                   if(!playerHasJoined)
                       [self screenSaver1FadeIn];
               }];
          }];
     }];
}

-(void)finishedScoreScreen //Waiting for players
{
    [scoreScreenPlayerOneGoals setText:@""];
    [scoreScreenPlayerOneShots setText:@""];
    [scoreScreenPlayerTwoGoals setText:@""];
    [scoreScreenPlayerTwoShots setText:@""];
    [scoreScreenPlayerOneGoals removeFromSuperview];
    [scoreScreenPlayerOneShots removeFromSuperview];
    [scoreScreenPlayerTwoGoals removeFromSuperview];
    [scoreScreenPlayerTwoShots removeFromSuperview];
    
    [self removeChildByTag:421 cleanup:NO];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        bg = [CCSprite spriteWithFile:@"begingame_background1_retina.jpg"];
    } else {
        bg = [CCSprite spriteWithFile:@"begingame_background1.jpg"];
    }
    bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:bg z:0 tag:420];
    [playerOneImageView setImage:[UIImage imageNamed:@"silhouette.png"]];
    [newView addSubview:playerOneImageView];
    
    [playerTwoImageView setImage:[UIImage imageNamed:@"silhouette.png"]];
    [newView addSubview:playerTwoImageView];
    
    [playerOneNameLabel setText:@"Player 1"];
    [playerTwoNameLabel setText:@"Player 2"];
    
    playerOneImage = nil;
    playerOneName = @"";
    [playerOneName release];
    playerTwoImage = nil;
    playerTwoName = @"";
    
    if (_matchmakingServer == nil)
    {
        _matchmakingServer = [[MatchmakingServer alloc] init];
        _matchmakingServer.delegate = self;
        _matchmakingServer.maxClients = 2;
        [_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        [_matchmakingServer.session setDataReceiveHandler:self withContext:nil];
        NSLog(@"Started server...");
    }
    
    receivedPlayerOneImage = NO, receivedPlayerOneName = NO, receivedPlayerTwoImage = NO, receivedPlayerTwoName = NO, gameHasStarted = NO;
    receivedStartGame = NO;
    _leftScore_SERVER = 0, _rightScore_SERVER = 0;
    _leftShotsOnGoal_SERVER = 0, _rightShotsOnGoal_SERVER = 0;
    
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
    
    gameOverNaturally = NO;
    
    isSinglePlayerGame = NO;
    
    clientDisconnected = NO;
    
    playerHasJoined = NO;
    
    screenSaverBackground1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    screenSaverBackground2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    screenSaverBackground3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    screenSaverBackground4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    
    [screenSaverBackground1 setImage:[UIImage imageNamed:@"background_1.png"]];
    [screenSaverBackground2 setImage:[UIImage imageNamed:@"background_2.png"]];
    [screenSaverBackground3 setImage:[UIImage imageNamed:@"background_3b.png"]];
    [screenSaverBackground4 setImage:[UIImage imageNamed:@"background_4a.png"]];
    
    [self startScreenSaverAnimations];
}

-(void) setUpGame //Game screen
{
    [self removeChildByTag:420 cleanup:NO];
    if(receivedPlayerOneImage)
        [self removeChildByTag:422 cleanup:NO];
    if(receivedPlayerTwoImage)
        [self removeChildByTag:423 cleanup:NO];
    NSLog(@"setUpGame");
    CGSize s = [CCDirector sharedDirector].winSize;
    winSize = s;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        bg = [CCSprite spriteWithFile:@"field_retina.jpg"];
    } else {
        bg = [CCSprite spriteWithFile:@"field.jpg"];
    }
    bg.position = ccp(s.width/2, s.height/2);
    [self addChild:bg z:0 tag:666];
    
    //[startGameButton removeFromSuperview];
    //[startOnePlayerButton removeFromSuperview];
    [playerOneImageView removeFromSuperview];
    [playerTwoImageView removeFromSuperview];
    [playerOneNameLabel removeFromSuperview];
    [playerTwoNameLabel removeFromSuperview];
    //newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
    //[[[CCDirector sharedDirector] view] addSubview:newView];
    
    [[[CCDirector sharedDirector] view] addSubview:newView];
    
    [smallPlayerOneImageView setImage:playerOneImage];
    [newView addSubview:smallPlayerOneImageView];
    
    [smallPlayerTwoImageView setImage:playerTwoImage];
    [newView addSubview:smallPlayerTwoImageView];
    
    [smallPlayerOneNameLabel setTextColor:[UIColor whiteColor]];
    [smallPlayerOneNameLabel setBackgroundColor:[UIColor clearColor]];
    [smallPlayerOneNameLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    smallPlayerOneNameLabel.textAlignment = NSTextAlignmentLeft;
    smallPlayerOneNameLabel.text = playerOneName;
    [newView addSubview:smallPlayerOneNameLabel];
    
    [smallPlayerTwoNameLabel setTextColor:[UIColor whiteColor]];
    [smallPlayerTwoNameLabel setBackgroundColor:[UIColor clearColor]];
    [smallPlayerTwoNameLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    smallPlayerTwoNameLabel.textAlignment = NSTextAlignmentRight;
    smallPlayerTwoNameLabel.text = playerTwoName;
    [newView addSubview:smallPlayerTwoNameLabel];
    
    contactListener = new ContactListener(FixtureLeft, FixtureRight, ball.Fixture);
    world->SetContactListener(contactListener);
    
    //Set up sprites
    [self showSprites];
    
    [self spawnScoreboards];
    
    NSLog(@"before");
    [ball addBall];
    NSLog(@"after");
    
    CCNode *parent = [CCNode node];
    [self addChild:parent z:-1 tag:0];
    
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
    
    [countdown startCountdown];
    
    //Listen for game over message
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(gameOver)
     name:@"GameOver"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(countDownFinished)
     name:@"StartGame"
     object:nil];
    
    //[self addChild:[BoxDebugLayer debugLayerWithWorld:world ptmRatio:PTM_RATIO] z:10000];
}

bool isSinglePlayerGame = NO;
- (IBAction)startGamePressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Start Game Pressed");
    gameHasStarted = YES;
    [newView removeFromSuperview];
    [self setUpGame];
    
    [self sendToAll:@"Start" needsReliable:YES :@""];
}

-(IBAction)startOnePlayerPressedAction:(id)sender
{
    NSLog(@"One Player Pressed");
    isSinglePlayerGame = YES;
    gameHasStarted = YES;
    [newView removeFromSuperview];
    [self setUpGame];
    
    [self sendToAll:@"Start" needsReliable:YES :@""];
}

#pragma mark Game Scene



int _leftScore_SERVER = 0, _rightScore_SERVER = 0;
int _leftShotsOnGoal_SERVER = 0, _rightShotsOnGoal_SERVER = 0;

int LEFT_PLAYER_SERVER = 666, RIGHT_PLAYER_SERVER = 667, NO_PLAYER_SERVER = 668;

int LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;

-(void)higherLeftScore{
    [crowdPlayer play];
    NSLog(@"higherLeftScore");
    if(LAST_PLAYER_TOUCH_SERVER == LEFT_PLAYER_SERVER)
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal_SERVER]];
    [_leftScoreLabel setString: [NSString stringWithFormat:@"%d",++_leftScore_SERVER]];
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
}
-(void)higherRightScore{
    [crowdPlayer play];
    [_rightScoreLabel setString:@""];
    NSLog(@"higherRightScore new");
    if(LAST_PLAYER_TOUCH_SERVER == RIGHT_PLAYER_SERVER)
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal_SERVER]];
    [_rightScoreLabel setString: [NSString stringWithFormat:@"%d",++_rightScore_SERVER]];
    LAST_PLAYER_TOUCH_SERVER = NO_PLAYER_SERVER;
}
-(void)higherLeftShotsOnGoal{
    NSLog(@"higherLeftShots new");
    if(LAST_PLAYER_TOUCH_SERVER == RIGHT_PLAYER_SERVER)
    {
        [_rightShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_rightShotsOnGoal_SERVER]];
    }
    LAST_PLAYER_TOUCH_SERVER = LEFT_PLAYER_SERVER;
}

-(void)higherRightShotsOnGoal{
    
    if(LAST_PLAYER_TOUCH_SERVER == LEFT_PLAYER_SERVER)
    {
        [_leftShotsOnGoalLabel setString: [NSString stringWithFormat:@"%d", ++_leftShotsOnGoal_SERVER]];
    }
    LAST_PLAYER_TOUCH_SERVER = RIGHT_PLAYER_SERVER;
}

-(void)gameOver{
    gameOverNaturally = YES;
    if(gameHasStarted)
    {
        [tripleWhistlePlayer play];
        //Handle game being over
        [ball gameOver];
        //Reset right player
        CGPoint p2 = ccp(924, 368);
        float32 angle = BodyRight->GetAngle();
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetLinearVelocity(b2Vec2(0, 0));
        BodyRight->SetTransform(b2Vec2(p2.x/PTM_RATIO, p2.y/PTM_RATIO), angle);
        
        //Reset left player
        CGPoint p1 = ccp(100, 368);
        angle = BodyLeft->GetAngle();
        BodyLeft->SetLinearDamping(0);
        BodyLeft->SetAngularDamping(0);
        BodyLeft->SetLinearVelocity(b2Vec2(0,0));
        BodyLeft->SetTransform(b2Vec2(p1.x/PTM_RATIO, p1.y/PTM_RATIO), angle);
        NSLog(@"Game Over received");
    }
    
    if([_matchmakingServer connectedClientCount] > 0)
    {
        [self sendToAll:@"Game Over" needsReliable:YES :@""];
        [self sendAssign:[NSString stringWithFormat:@"%d", _leftScore_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
        [self sendAssign:[NSString stringWithFormat:@"%d", _leftShotsOnGoal_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
        if(!isSinglePlayerGame && [_matchmakingServer connectedClientCount] > 1)
        {
            [self sendAssign:[NSString stringWithFormat:@"%d", _rightScore_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:1]];
            [self sendAssign:[NSString stringWithFormat:@"%d", _rightShotsOnGoal_SERVER] needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:1]];
        }
    }
    
    [smallPlayerOneImageView removeFromSuperview];
    [smallPlayerOneNameLabel removeFromSuperview];
    [smallPlayerTwoImageView removeFromSuperview];
    [smallPlayerTwoNameLabel removeFromSuperview];
    [ball removeBall];
    
    [self removeChildByTag:L_SCORE_LABEL cleanup:NO];
    [self removeChildByTag:L_SHOTS_LABEL cleanup:NO];
    [self removeChildByTag:R_SCORE_LABEL cleanup:NO];
    [self removeChildByTag:R_SHOTS_LABEL cleanup:NO];
    
    _leftScoreLabel = nil;
    _leftShotsOnGoalLabel = nil;
    _rightScoreLabel = nil;
    _rightShotsOnGoalLabel = nil;
    
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [_matchmakingServer endSession];
    [self hideSprites];
    [self removeChildByTag:666 cleanup:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GameOver" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StartGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LeftScores" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LeftShoots" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RightScores" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RightShoots" object:nil];
    
    contactListener = NULL;
    
    if(clientDisconnected)
        [self setUpWaitScreen:YES :NO];
    else
        [self setUpWaitScreen:NO :NO];
}

-(void) update: (ccTime) dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
    //ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    //kmGLPushMatrix();
    
	world->Step(dt, velocityIterations, positionIterations);
}

-(void)sendToAll:(NSString*)message needsReliable:(BOOL)reliable:(NSString*)peer{
    NSLog(@"Should be sending %@", message);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = [message dataUsingEncoding:NSASCIIStringEncoding];
    [archiver encodeDataObject:data];
	//[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    if (reliable)
    {
    	[_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingServer.session sendDataToAllPeers: dataToSend withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
	[dataToSend release];
}

-(void)sendAssign:(NSString*)assignPlayer needsReliable:(BOOL)reliable:(NSString*)peer{
    NSLog(@"Should be sending %@", assignPlayer);
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    NSData* data = [assignPlayer dataUsingEncoding:NSASCIIStringEncoding];
    [archiver encodeDataObject:data];
	//[archiver encodeFloat:x forKey: [playerPref stringByAppendingString:@"x"]];
    [archiver finishEncoding];
    NSMutableArray* peerArray;
    peerArray = [NSMutableArray arrayWithCapacity:1];
    [peerArray addObject:peer];
    if (reliable)
    {
    	[_matchmakingServer.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataReliable error:nil];
    }
    else
        [_matchmakingServer.session sendData:dataToSend toPeers:peerArray withDataMode:GKSendDataUnreliable error:nil];
	[archiver release];
    archiver = nil;
	[dataToSend release];
    dataToSend = nil;
    [peerArray removeAllObjects];
    peer = nil;
    peerArray = nil;
    data = nil;
    //[peerArray release];
}

#pragma mark - MatchmakingServerDelegate

int devicesConnected = 0;
- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
    NSLog(@"Client did connect!");
    NSLog(@"%d", [_matchmakingServer connectedClientCount]);
    if([_matchmakingServer connectedClientCount] == 1)
    {
        //devicesConnected++;
        NSLog(@"%@", peerID);
        [self sendAssign:@"1" needsReliable:YES :peerID];
    }
    else if ([_matchmakingServer connectedClientCount] == 2)
    {
        NSLog(@"%@", peerID);
        [self sendAssign:@"2" needsReliable:YES :peerID];
    }
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(int)peerID
{
    NSLog(@"Client disconnected");
    if(gameHasStarted)
    {
        [timer stopTimer];
        [countdown stopCountdown];
    }
    [self gameOver];
}

- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server
{
    NSLog(@"server session did end");
	_matchmakingServer.delegate = nil;
    [_matchmakingServer release];
	_matchmakingServer = nil;
}

#pragma mark - GKSession Data Receive Handler
float previousLeftAccel, previousRightAccel;
bool receivedPlayerOneImage = NO, receivedPlayerOneName = NO, receivedPlayerTwoImage = NO, receivedPlayerTwoName = NO, gameHasStarted = NO;
bool receivedStartGame = NO;
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
    //NSLog(@"Data received");
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        if(gameHasStarted)
        {
            //NSLog(@"FUCK THIS SHIT");
            if ([unarchiver containsValueForKey:@"1x"])
            {
                leftAccel =[unarchiver decodeFloatForKey:@"1x"];
            }
            else if ([unarchiver containsValueForKey:@"2x"])
            {
                rightAccel = [unarchiver decodeFloatForKey:@"2x"];
            }
        }
        else if([[_matchmakingServer connectedClients] objectAtIndex:0] == peerID) //Player 1
        {
            NSLog(@"Received data from player 1");
            NSData* decodedData = [unarchiver decodeDataObject];
            NSLog(@"Finished decoding");
            if(!receivedPlayerOneImage)
            {
                playerHasJoined = YES;
                [self removeAllAnimations];
                if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
                    && [[UIScreen mainScreen] scale] == 2.0) {
                    bg = [CCSprite spriteWithFile:@"begingame_background2_retina.jpg"];
                } else {
                    bg = [CCSprite spriteWithFile:@"begingame_background2.jpg"];
                }
                bg.position = ccp(winSize.width/2, winSize.height/2);
                [self removeChildByTag:421 cleanup:NO];
                [self addChild:bg z:0 tag:422];
                [newView removeFromSuperview];
                [[[CCDirector sharedDirector] view] addSubview:newView];
                receivedPlayerOneImage = YES;
                playerOneImage = [UIImage imageWithData:decodedData];
                //[playerOneImageView setImage:playerOneImage];
                playerOneImageView.image = playerOneImage;
                //[newView addSubview:playerOneImageView];
            }
            else if (!receivedPlayerOneName)
            {
                receivedPlayerOneName = YES;
                playerOneName = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                [playerOneNameLabel setText:playerOneName];
                //[newView addSubview:startOnePlayerButton];
                [self sendAssign:@"ONE" needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
            }
            else if (!receivedStartGame)
            {
                
                receivedStartGame = YES; 
                NSString* message = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                NSLog(@"!receivedStartGame: %@", message);
                if([message isEqualToString:@"ONE"])
                {
                    //Start one player
                    NSLog(@"One Player Pressed");
                    isSinglePlayerGame = YES;
                    gameHasStarted = YES;
                    [newView removeFromSuperview];
                    [self setUpGame];
                    
                    [self sendToAll:@"Start" needsReliable:YES :@""];
                }
                else if ([message isEqualToString:@"TWO"])
                {
                    //Start two player
                    NSLog(@"Start Game Pressed");
                    gameHasStarted = YES;
                    [newView removeFromSuperview];
                    [self setUpGame];
                    
                    [self sendToAll:@"Start" needsReliable:YES :@""];
                }
                [message release];
            }
        }
        else //Player 2
        {
            NSLog(@"Received data from player 2");
            NSData* decodedData = [unarchiver decodeDataObject];
            if(!receivedPlayerTwoImage)
            {
                if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
                    && [[UIScreen mainScreen] scale] == 2.0) {
                    bg = [CCSprite spriteWithFile:@"begingame_background3_retina.jpg"];
                } else {
                    bg = [CCSprite spriteWithFile:@"begingame_background3.jpg"];
                }
                
                bg.position = ccp(winSize.width/2, winSize.height/2);
                [self removeChildByTag:422 cleanup:NO];
                [self addChild:bg z:0 tag:423];
                [newView removeFromSuperview];
                [[[CCDirector sharedDirector] view] addSubview:newView];
                receivedPlayerTwoImage = YES;
                playerTwoImage = [UIImage imageWithData:decodedData];
                [playerTwoImageView setImage:playerTwoImage];
                [startOnePlayerButton removeFromSuperview];
                //[newView addSubview:startGameButton];
            }
            else if (!receivedPlayerTwoName)
            {
                receivedPlayerTwoName = YES;
                playerTwoName = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
                [playerTwoNameLabel setText:playerTwoName];
                [self sendAssign:@"TWO" needsReliable:YES :[[_matchmakingServer connectedClients] objectAtIndex:0]];
            }
        }
        [unarchiver release];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught error...");
    }
    @finally {
        
    }
}

-(void) countDownFinished
{
    [singleWhistlePlayer play];
    
    [timer startTimer];
    [ball respawnLeft];
}

-(void) dealloc
{
    NSLog(@"DEALLOC");
    [[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(tick:) forTarget:self];
    if(BodyRight)
        world->DestroyBody(BodyRight);
    if(BodyLeft)
        world->DestroyBody(BodyLeft);
    if(BodyBall)
        world->DestroyBody(BodyBall);
    if(groundBody)
        world->DestroyBody(groundBody);
    
    
    [playerOneName release];
    [playerOneNameLabel release];
    [smallPlayerOneNameLabel release];
    [playerOneImageView release];
    [smallPlayerOneImageView release];
    if(!isSinglePlayerGame)
    {
        [playerTwoName release];
        [playerTwoNameLabel release];
        [smallPlayerTwoNameLabel release];
        [playerTwoImageView release];
        [smallPlayerTwoImageView release];
    }
    [startOnePlayerButton release];
    [startGameButton release];
    [newView release];
    if(world)
    {
	delete world;
	world = NULL;
    }
    
    
    
	
    if(m_debugDraw)
    {
	delete m_debugDraw;
	m_debugDraw = NULL;
    }
    if(contactListener)
    {
    delete contactListener;
    contactListener = NULL;
    }
    if(_mouseJoint)
    {
    delete _mouseJoint;
    _mouseJoint = NULL;
    }
    FixtureLeft = NULL;
    FixtureRight = NULL;
    BodyRight = NULL;
    BodyLeft = NULL;
    self.SpriteLeft = NULL;
    self.SpriteRight = NULL;
    player1 = NULL;
    player2 = NULL;
    player1Sprite = NULL;
    player1Body = NULL;
    player1Fixture = NULL;
    player2Sprite = NULL;
    body2 = NULL;
    spriteTexture_ = NULL;
    groundBody = NULL;
    _leftScoreLabel = NULL;
    _rightScoreLabel = NULL;
    _leftShotsOnGoalLabel = NULL;
    _rightShotsOnGoalLabel = NULL;
    BodyBall = NULL;
    
    
    if(timer)
    {
    [timer release];
    timer = NULL;
    }
    if(ball)
    {
    [ball release];
    [ball dealloc];
    ball = NULL;
    }
    if(countdown)
    {
    [countdown release];
    countdown = NULL;
    }
    
	[super dealloc];
}

-(void) initPhysics
{
	NSLog(@"initPhysics");
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	//world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// top
	groundBox.Set(b2Vec2(0,19.594f), b2Vec2(winSize.width/PTM_RATIO,19.594f));
	groundBody->CreateFixture(&groundBox,0);
	
	// bottom
	groundBox.Set(b2Vec2(0,4.4f), b2Vec2(winSize.width/PTM_RATIO,4.4f));
	groundBody->CreateFixture(&groundBox,0);
    
}

-(void) initSprites
{
    NSLog(@"initSprites");
	
    [ball addBall];
    
    [self spawnPlayers];
    
    [ball respawnCenter];
    
    //[self updateLeftPlayer:0.0f];
}

int L_SCORE_LABEL = 44444, R_SCORE_LABEL = 44445, L_SHOTS_LABEL = 44446, R_SHOTS_LABEL = 44447;

- (void)spawnScoreboards{
    _leftScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftScoreLabel.position = ccp(470, 648);
    [self addChild: _leftScoreLabel z:0 tag:L_SCORE_LABEL];
    
    _leftShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _leftShotsOnGoalLabel.position = ccp(174, 648);
    [self addChild: _leftShotsOnGoalLabel z:0 tag:L_SHOTS_LABEL];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherLeftScore)
     name:@"LeftScores"
     object:nil ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherLeftShotsOnGoal)
     name:@"LeftShoots"
     object:nil];
    
    
    _rightScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _rightScoreLabel.position = ccp(555, 648);
    [self addChild: _rightScoreLabel z:0 tag:R_SCORE_LABEL];
    
    _rightShotsOnGoalLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:42];
    _rightShotsOnGoalLabel.position = ccp(994, 648);
    [self addChild: _rightShotsOnGoalLabel z:0 tag:R_SHOTS_LABEL];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherRightScore)
     name:@"RightScores"
     object:nil ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(higherRightShotsOnGoal)
     name:@"RightShoots"
     object:nil];
}

@synthesize SpriteLeft, SpriteRight, BodyRight, BodyLeft, BodyBall, FixtureLeft, FixtureRight;
#define PTM_RATIO 32

-(void) showSprites {
    [self addChild:self.SpriteLeft z:0 tag:LEFT_PLAYER_TAG];
    [self addChild:self.SpriteRight z:0 tag:RIGHT_PLAYER_TAG];
}

-(void) hideSprites {
    [self removeChildByTag:LEFT_PLAYER_TAG cleanup:NO];
    [self removeChildByTag:RIGHT_PLAYER_TAG cleanup:NO];
}

-(void) spawnPlayers
{
    NSLog(@"spawnPlayers");
    winSize = [CCDirector sharedDirector].winSize;
    
    BodyBall = ball.getBody;
    
    CGPoint p1 = ccp(100, 368);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        self.SpriteLeft = [PhysicsSprite spriteWithFile:@"player_left_retina.png"];
    } else {
        self.SpriteLeft = [PhysicsSprite spriteWithFile:@"player1.png"];
    }
    
    //[self addChild:SpriteLeft z:0];
    self.SpriteLeft.position = ccp(p1.x, p1.y);
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef1;
    bodyDef1.type = b2_dynamicBody;
    bodyDef1.position.Set(p1.x/PTM_RATIO, p1.y/PTM_RATIO);
    bodyDef1.fixedRotation = YES;
    BodyLeft = world->CreateBody(&bodyDef1);
    
    //b2CircleShape circleShapePlayer1;
    //circleShapePlayer1.m_radius = 1.25;
    b2PolygonShape squareShapePlayer1;
    b2PolygonShape notSquareShapePlayer1;
    //squareShapePlayer2.SetAsBox(2.5, 3.47);
    b2Vec2 vertices[8];
    vertices[0].Set(0.1, -1.735);
    //vertices[1].Set(0.3, -1.5);
    vertices[1].Set(0.5, -1.3);
    vertices[2].Set(0.8, -0.8);
    vertices[3].Set(0.8, 0.8); //TOP RIGHT
    vertices[4].Set(0.5, 1.3); //TOP LEFT
    //vertices[5].Set(0.3, 1.5);
    vertices[5].Set(0.1, 1.735);
    vertices[6].Set(-0.8, 1.735);
    vertices[7].Set(-0.8, -1.735);
    int32 count = 8;
    notSquareShapePlayer1.Set(vertices, count);
    
    squareShapePlayer1.SetAsBox(0.8, 1.735);
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef1;
    fixtureDef1.shape = &notSquareShapePlayer1;
    fixtureDef1.density = 100.0f;
    fixtureDef1.friction = 0.0f;
    FixtureLeft = BodyLeft->CreateFixture(&fixtureDef1);
    
    [self.SpriteLeft setPhysicsBody:BodyLeft];
    
    CGPoint p2 = ccp(924, 368);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        self.SpriteRight = [PhysicsSprite spriteWithFile:@"player_right_retina.png"];
    } else {
        self.SpriteRight = [PhysicsSprite spriteWithFile:@"player2.png"];
    }
    
    //[self addChild:SpriteRight z:0];
    self.SpriteRight.position = ccp(p2.x, p2.y);
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef2;
    bodyDef2.type = b2_dynamicBody;
    //bodyDef2.position.Set(p2.x/PTM_RATIO - 1.25, p2.y/PTM_RATIO - 1.735);
    bodyDef2.position.Set(p2.x/PTM_RATIO, p2.y/PTM_RATIO);
    bodyDef2.fixedRotation = YES;
    BodyRight = world->CreateBody(&bodyDef2);
    
    // Define another box shape for our dynamic body.
    //b2CircleShape circleShapePlayer2;
    //circleShapePlayer2.m_radius = 2.5;
    
    b2PolygonShape squareShapePlayer2;
    b2PolygonShape notSquareShapePlayer2;
    
    b2Vec2 vertices2[8];
    vertices2[2].Set(0.8, 1.735);
    vertices2[1].Set(0.8, -1.735);
    vertices2[0].Set(-0.1, -1.735);
    vertices2[7].Set(-0.5, -1.3);
    vertices2[6].Set(-0.8, -0.8);
    vertices2[5].Set(-0.8, 0.8); //TOP RIGHT
    vertices2[4].Set(-0.5, 1.3); //TOP LEFT
    vertices2[3].Set(-0.1, 1.735);
    
    
    notSquareShapePlayer2.Set(vertices2, count);
    //squareShapePlayer2.SetAsBox(2.5, 3.47);
    squareShapePlayer2.SetAsBox(0.8, 1.735);
    //squareShapePlayer2.
    
    
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef2;
    fixtureDef2.shape = &notSquareShapePlayer2;
    fixtureDef2.density = 100.0f;
    fixtureDef2.friction = 0.0f;
    FixtureRight = BodyRight->CreateFixture(&fixtureDef2);
    
    [self.SpriteRight setPhysicsBody:BodyRight];
    //[self scheduleUpdate];
    
}

-(void) test
{
    
}

float leftAccel = 0.0f, rightAccel = 0.0f, rightAccelToUse = 0.0f, leftAccelToUse = 0.0f;

- (void)tick:(ccTime) dt {
    
    b2Vec2 rightPlayerPos = BodyRight->GetPosition();
    float32 angle = BodyRight->GetAngle();
    
    angle = BodyLeft->GetAngle();
    BodyLeft->SetLinearDamping(0);
    BodyLeft->SetAngularDamping(0);
    BodyLeft->SetAngularVelocity(0);
    BodyLeft->SetLinearVelocity(b2Vec2(0,leftAccel * 40 * -1));
    previousLeftAccel = leftAccel;
    b2Vec2 loc = BodyLeft->GetPosition();
    BodyLeft->SetTransform(loc, angle);
    
    if(isSinglePlayerGame)
    {
        //NSLog(@"Update single player");
        b2Vec2 ballPos = [ball getBody]->GetPosition();
        if(ballPos.y > BodyRight->GetPosition().y)
            rightAccel = -0.1;
        else
            rightAccel = 0.1;
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetAngularVelocity(0);
        BodyRight->SetLinearVelocity(b2Vec2(0,40 * rightAccel * -1));
        BodyRight->SetTransform(rightPlayerPos, angle);
    }
    else
    {
        //NSLog(@"Update two player");
        BodyRight->SetLinearDamping(0);
        BodyRight->SetAngularDamping(0);
        BodyRight->SetAngularVelocity(0);
        BodyRight->SetLinearVelocity(b2Vec2(0,rightAccel * 40 * -1));
        previousRightAccel = rightAccel;
        BodyRight->SetTransform(rightPlayerPos, angle);
    }
    
    //b2Vec2 loc = b2Vec2(location.x, location.y);
    //rightPlayerPos = BodyRight->GetPosition();
    
}

@end
