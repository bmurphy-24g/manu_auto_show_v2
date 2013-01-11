//
//  FinalShareScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "FinalShareScene.h"
#import "StartScene.h"
#import "NoInternetShareScene.h"

@implementation FinalShareScene
@synthesize fileName, firstName, lastName, position, number, playerGoals, playerShots, currentURL, currentImage;
+(CCScene*) scene:(NSString *)cloudFileName :(NSString *)firstName :(NSString *)lastName :(NSString *)number :(NSString *)p :(NSString *)goals :(NSString *)shots :(UIImage*) img
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	FinalShareScene *layer = [FinalShareScene node];
    
    [layer initVariables:cloudFileName :firstName :lastName :number :p :goals :shots :img];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)initVariables:(NSString *)file :(NSString *)fName :(NSString *)lName :(NSString *)num :(NSString *)pos :(NSString *)goalsScored :(NSString *)shotsOnGoal :(UIImage*)image
{
    self.currentImage = image;
    isConnectedToInternet = YES;
    self.fileName = file;
    NSLog(@"%@", self.fileName);
    self.firstName = fName;
    NSLog(@"%@", self.firstName);
    self.lastName = lName;
    NSLog(@"%@", self.lastName);
    self.position = pos;
    NSLog(@"%@", self.position);
    self.number = num;
    NSLog(@"%@", self.number);
    self.playerGoals = goalsScored;
    NSLog(@"%@", self.playerGoals);
    self.playerShots = shotsOnGoal;
    NSLog(@"%@", self.playerShots);
    
    if([self connectedToNetwork])
    {
        NSString* location = [[NSUserDefaults standardUserDefaults] stringForKey:@"location"];
        
        NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@&first=%@&last=%@&position=%@&number=%@&goals=%@&shots=%@&location_id=%@", self.fileName, self.firstName, self.lastName, self.position, self.number, self.playerGoals, self.playerShots, [location lowercaseString]];
        self.currentURL = urlAddress;
        NSLog(@"%@", urlAddress);
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [shareWebView loadRequest:requestObj];
    }
    else
    {
        isConnectedToInternet = NO;
        [reloadButton setAlpha:0.0f];
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(613, 224, 411, 149)];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"shareyourcard_btn.png"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setAlpha:1.0f];
        [newView addSubview:shareButton];
    }
}

-(IBAction)shareButtonPressed:(id)sender
{   
    // noInternetShare
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[NoInternetShareScene scene:self.fileName :self.firstName :self.lastName :self.number :self.position :self.playerGoals :self.playerShots :self.currentImage] withColor:ccWHITE]];
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
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // Do whatever you want here
    [shareWebView setAlpha:1.0f];
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
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 701, 289, 67)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:exitButton];
        
        reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 624, 289, 67)];
        [reloadButton setBackgroundImage:[UIImage imageNamed:@"reload_btn.png"] forState:UIControlStateNormal];
        [reloadButton addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:reloadButton];
        
        testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        //[testImageView setBackgroundColor:[UIColor whiteColor]];
        //[newView addSubview:testImageView];
        
        btManager = [BluetoothManager sharedInstance];
        [btManager setEnabled:NO];
        [btManager setPowered:NO];
	}
	return self;
}

-(void)dealloc
{
    shareWebView.delegate = nil;
    [btManager setEnabled:YES];
    [btManager setPowered:YES];
    [super dealloc];
}

- (BOOL)connectedToNetwork  {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return 0;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    //below suggested by Ariel
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"]; //comment by friendlydeveloper: maybe use www.google.com
    NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    //NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:nil]; //suggested by Ariel
    NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:nil]; //modified by friendlydeveloper
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}
@end
