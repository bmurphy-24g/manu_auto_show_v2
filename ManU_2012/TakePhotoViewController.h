//
//  TakePhotoViewController.h
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "cocos2d.h"
#import "EnterYourInformationScene.h"
#import "RSClient.h"

@interface TakePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImageView* imageView;
    BOOL newMedia;
    UIImagePickerController *imagePicker;
    UIButton *acceptButton;
    UIButton *declineButton;
    UIButton* exitButton;
    UIImage *currentImage;
    RSClient* _rsClient;
    RSContainer* container;
    RSStorageObject* object;
}
-(void) rackSpaceSuccessfulUpload;
@end
