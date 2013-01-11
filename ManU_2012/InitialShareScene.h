//
//  InitialShareScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PrepareClientGame.h"


@interface InitialShareScene : CCLayer <UIWebViewDelegate> {
    CCSprite* bg;
    CGSize winSize;
    UIView* newView;
    UIWebView *shareWebView;
    UIButton* backButton;
    UIButton* shareButton;
    UIButton* playButton;
    UIButton* exitButton;
    UIButton* reloadButton;
    UIImage* currentImage;
    NSString* fileName;
    NSString* firstName;
    NSString* lastName;
    NSString* position;
    NSString* number;
    UIImageView* testImageView;
    NSString* currentURL;
    BluetoothManager* btManager;
}
@property (nonatomic, copy) UIImage* currentImage;
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* position;
@property (nonatomic, copy) NSString* number;
@property (nonatomic, copy) NSString* currentURL;

+(CCScene *) scene: (UIImage*)image: (NSString*)cloudFileName: (NSString*)firstName: (NSString*)lastName: (NSString*)number: (NSString*)position;
@end
