//
//  InitialShareScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InitialShareScene.h"
#import "StartScene.h"

@implementation InitialShareScene
@synthesize fileName, firstName, lastName, number, position, currentImage, currentURL;

+(CCScene*)scene:(UIImage *)image :(NSString *)cloudFileName :(NSString *)firstName :(NSString *)lastName :(NSString *)number :(NSString *)position
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	InitialShareScene *layer = [InitialShareScene node];
    
    [layer initVariables:image :cloudFileName :firstName :lastName :number :position];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;

}

-(void) initVariables: (UIImage*)image: (NSString*)file: (NSString*)fName: (NSString*)lName: (NSString*)num: (NSString*)pos
{
    self.fileName = file;
    
    self.currentImage = image;
    
    self.firstName = fName;
    self.lastName = lName;
    self.number = num;
    self.position = pos;
    //NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@&first=%@&last=%@&position=%@&number=%@&goals=5&shots=22", fileName, firstName, lastName, position, number];
    NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@&first=%@&last=%@&position=%@&number=%@&hide_right=true", fileName, firstName, lastName, position, number];
    self.currentURL = urlAddress;
    NSLog(@"%@", urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [shareWebView loadRequest:requestObj];
}

-(id) init
{
	if( (self=[super init])) {
        
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"blank.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:0];
        
        //Clear cache
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        //Delete cookies
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        shareWebView = [[UIWebView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        shareWebView.delegate = self;
        [shareWebView setAlpha:0.0f];
        [newView addSubview:shareWebView];
        
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 187, 67)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:backButton];
        
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 224, 411, 149)];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"shareyourcard_btn.png"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setAlpha:0.0f];
        [newView addSubview:shareButton];
        
        playButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 404, 411, 149)];
        [playButton setBackgroundImage:[UIImage imageNamed:@"playnow_btn.png"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [playButton setAlpha:0.0f];
        [newView addSubview:playButton];
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 701, 289, 67)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [exitButton setAlpha:1.0];
        [newView addSubview:exitButton];
        
        reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 624, 289, 67)];
        [reloadButton setBackgroundImage:[UIImage imageNamed:@"reload_btn.png"] forState:UIControlStateNormal];
        [reloadButton addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [reloadButton setAlpha:1.0];
        [newView addSubview:reloadButton];
        
        testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        //[testImageView setBackgroundColor:[UIColor whiteColor]];
        //[newView addSubview:testImageView];
        NSLog(@"Checking internet connectivity");
        if(![self connectedToInternet])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection." message:@"Joining game." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
            [alert show];
            [alert release];
            
            NSLog(@"Not connected to internet");
            
        }

	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [newView removeFromSuperview];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[PrepareClientGame scene:self.currentImage :@"" :self.position :self.number :self.firstName :self.lastName :self.fileName] withColor:ccWHITE]];
    }
    else if (buttonIndex == 1) {
        NSLog(@"OK Tapped. Hello World!");
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // Do whatever you want here
    [playButton setAlpha:1.0f];
    [shareButton setAlpha:1.0f];
    [shareWebView setAlpha:1.0f];
}

-(IBAction)backButtonPressed:(id)sender
{
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:self.currentImage :self.fileName] withColor:ccWHITE]];
}

-(IBAction)reloadButtonPressed:(id)sender
{
    NSLog(@"reload pressed");
    NSURL *url = [NSURL URLWithString:self.currentURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [shareWebView loadRequest:requestObj];
}

-(IBAction)exitButtonPressed:(id)sender
{
    NSLog(@"exit pressed");
    [shareWebView stopLoading];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

-(IBAction)shareButtonPressed:(id)sender
{
    NSLog(@"share button pressed");
    //shareWebView.delegate = nil;
    //[shareButton setAlpha:0.0f];
    //[playButton setAlpha:0.0f];
    [shareButton removeFromSuperview];
    [playButton removeFromSuperview];
    //[reloadButton setAlpha:1.0f];
    [exitButton setAlpha:1.0f];
    NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@&first=%@&last=%@&position=%@&number=%@", self.fileName, self.firstName, self.lastName, self.position, self.number];
    self.currentURL = urlAddress;
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [shareWebView loadRequest:requestObj];
    //[urlAddress release];
    //[url release];
    //[requestObj release];
}

-(IBAction)playButtonPressed:(id)sender
{
    NSLog(@"play button pressed");
    /*[shareButton removeFromSuperview];
    [playButton removeFromSuperview];*/
    [newView removeFromSuperview];
    //[testImageView setImage:self.currentImage];
    //+(CCScene *) scene :(UIImage*)img :(NSString*)name :(NSString*)position :(NSString*)number :(NSString*)firstName :(NSString*)lastName :(NSString*)fileName;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[PrepareClientGame scene:self.currentImage :@"" :self.position :self.number :self.firstName :self.lastName :self.fileName] withColor:ccWHITE]];
}

- (BOOL) connectedToInternet
{
    NSString *TheUrl = @"http://www.google.com";
    NSURL *url = [NSURL URLWithString:TheUrl];
    NSError* error = nil;
    NSString* text = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    return ( text != NULL ) ? YES : NO;
}

- (void) dealloc
{
    NSLog(@"InitialShare dealloc");
    shareWebView.delegate = nil;
    [super dealloc];
}

@end
