//
//  NoInternetShareScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NoInternetShareScene : CCLayer {
    UIView* mainView;
    UIImageView* backgroundImageView;
    
    UIButton* textButton;
    UIButton* emailButton;
    UIButton* exitButton;
    
    UIView* textShareView;
    UIView* emailShareView;
    
    UITextField* phoneNumberOneTextField;
    UITextField* phoneNumberTwoTextField;
    UITextField* phoneNumberThreeTextField;
    UITextView* textTextView;
    
    UITextField* emailOneTextField;
    UITextField* emailTwoTextField;
    UITextField* emailThreeTextField;
    UITextView* emailTextView;
    
    UIImageView* currentImageView;
    
    UIButton* sendEmailButton;
    UIButton* sendTextButton;
}

@property (nonatomic, copy) UIImage* currentImage;
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* position;
@property (nonatomic, copy) NSString* number;
@property (nonatomic, copy) NSString* playerGoals;
@property (nonatomic, copy) NSString* playerShots;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
+(CCScene *) scene: (NSString*)cloudFileName: (NSString*)firstName: (NSString*)lastName: (NSString*)number: (NSString*)position :(NSString*)goals :(NSString*)shots :(UIImage *)img;

@end
