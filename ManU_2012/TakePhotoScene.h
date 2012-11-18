//
//  TakePhotoScene.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TakePhotoViewController.h"

@interface TakePhotoScene : CCLayer <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CGSize winSize;
    CCSprite* bg;
    UIImageView* imageView;
    BOOL newMedia;
    TakePhotoViewController* viewController;
}

+(CCScene *) scene;
@end
