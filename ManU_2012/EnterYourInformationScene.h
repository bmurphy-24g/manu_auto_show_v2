//
//  EnterYourInformationScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "cocos2d.h"
#import "InitialShareScene.h"
#import "BluetoothManager.h"

@interface EnterYourInformationScene : CCLayer <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
    CCSprite* bg;
    CGSize winSize;
    UIButton* submitButton;
    UIButton* backButton;
    UIImage* currentImage;
    UIImageView* imageView;
    UITextField* firstNameTextField;
    UITextField* lastNameTextField;
    UITextField* positionTextField;
    UITextField* numberTextField;
    UIPickerView* positionPickerView;
    UIPickerView* numberPickerView;
    NSString* fileName;
    CGAffineTransform rotateTransform;
    UIView* newImageView;
    NSArray* positions;
    UIButton* dropDownButton;
    UIButton* playLaterButton;
    UIImageView* backgroundImageView;
    BluetoothManager* btManager;
}

@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) UIImage* currentImage;

+(CCScene *) scene: (UIImage*)image: (NSString*)cloudFileName;
@end
