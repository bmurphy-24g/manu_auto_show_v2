//
//  FinalShareScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BluetoothManager.h"

@interface FinalShareScene : CCLayer <UIWebViewDelegate> {
    CCSprite* bg;
    CGSize winSize;
    UIView* newView;
    UIWebView *shareWebView;
    UIButton* backButton;
    UIButton* shareButton;
    UIButton* playButton;
    UIImage* currentImage;
    NSString* fileName;
    NSString* firstName;
    NSString* lastName;
    NSString* position;
    NSString* number;
    NSString* playerGoals;
    NSString* playerShots;
    UIImageView* testImageView;
    UIButton* exitButton;
    UIButton* reloadButton;
    NSString* currentURL;
    bool isConnectedToInternet;
    BluetoothManager* btManager;
}

@property (nonatomic, copy) UIImage* currentImage;
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* position;
@property (nonatomic, copy) NSString* number;
@property (nonatomic, copy) NSString* playerGoals;
@property (nonatomic, copy) NSString* playerShots;
@property (nonatomic, copy) NSString* currentURL;
+(CCScene *) scene: (NSString*)cloudFileName: (NSString*)firstName: (NSString*)lastName: (NSString*)number: (NSString*)position :(NSString*)goals :(NSString*)shots :(UIImage*)img;

@end
