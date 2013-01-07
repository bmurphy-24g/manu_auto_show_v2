//
//  SelectPhotoScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TakePhotoScene.h"
#import "RSClient.h"

@interface SelectPhotoScene : CCLayer <NSXMLParserDelegate>{
    CGSize winSize;
    CCSprite* bg;
    UIButton* takePhotoButton;
    UIButton* continueWithoutPhotoButton;
    UIButton* pictureOneButton;
    UIButton* pictureTwoButton;
    UIButton* pictureThreeButton;
    UIButton* pictureFourButton;
    RSClient* _rsClient;
    RSContainer* container;
    RSStorageObject* object;
    UIView* newView;
    UIImage* curImageOne;
    UIImage* curImageTwo;
    UIImage* curImageThree;
    UIImage* curImageFour;
    UIButton* scrollLeftButton;
    UIButton* scrollRightButton;
    NSArray* sortedObjectsArray;
    
    UIImagePickerController *picker2;
    NSXMLParser *rssParser;
    NSMutableArray *articles;
    NSMutableDictionary *item;
    NSString *currentElement;
    NSMutableString *ElementValue;
    NSMutableArray *fileNames;
    BOOL errorParsing;
    
    UIActivityIndicatorView* pictureOneActivityMonitor;
    UIActivityIndicatorView* pictureTwoActivityMonitor;
    UIActivityIndicatorView* pictureThreeActivityMonitor;
    UIActivityIndicatorView* pictureFourActivityMonitor;
}
@property (nonatomic, copy) NSArray* sortedObjectsArray;
@property (nonatomic, strong) RSStorageObject *object;
+(CCScene *) scene;
-(IBAction)takePhotoPressedAction:(id)sender;
-(IBAction)continueWithoutPhotoPressedAction:(id)sender;
@end
