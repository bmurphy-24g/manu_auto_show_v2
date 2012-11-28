//
//  NoInternetShareScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NoInternetShareScene.h"
#import "StartScene.h"
#import "AppDelegate.h"

@implementation NoInternetShareScene
@synthesize fileName, firstName, lastName, position, number, playerGoals, playerShots, currentImage, managedObjectContext = _managedObjectContext;

bool emailButtonHasBeenPressed = NO, textButtonHasBeenPressed = NO, keyBoardShiftedUp = NO;

+(CCScene*) scene:(NSString *)cloudFileName :(NSString *)firstName :(NSString *)lastName :(NSString *)number :(NSString *)p :(NSString *)goals :(NSString *)shots :(UIImage*)img
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NoInternetShareScene *layer = [NoInternetShareScene node];
    
    [layer initVariables:cloudFileName :firstName :lastName :number :p :goals :shots :img];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)initVariables:(NSString *)file :(NSString *)fName :(NSString *)lName :(NSString *)num :(NSString *)pos :(NSString *)goalsScored :(NSString *)shotsOnGoal :(UIImage *)image
{
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
    
    self.currentImage = image;
    
    UIImage* playerOverlay = [UIImage imageNamed:@"playercard_overlay.png"];
    
    [currentImageView setImage:[[self addImageToImage:self.currentImage :playerOverlay] copy]];
}

-(id) init
{
	if( (self=[super init])) {
        emailButtonHasBeenPressed = NO, textButtonHasBeenPressed = NO, keyBoardShiftedUp = NO;
        
        mainView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        backgroundImageView = [[UIImageView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [backgroundImageView setImage:[UIImage imageNamed:@"background12.jpg"]];
        [mainView addSubview:backgroundImageView];
        [[[CCDirector sharedDirector] view] addSubview:mainView];
        
        currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 113, 316, 539)];
        [mainView addSubview:currentImageView];
        
        /* TEXT */
        textShareView = [[UIView alloc] initWithFrame:CGRectMake(1029, 190, 512, 415)];
        phoneNumberOneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 54, 472, 30)];
        [phoneNumberOneTextField setPlaceholder:@"Phone Number"];
        [phoneNumberOneTextField setBackgroundColor:[UIColor whiteColor]];
        [phoneNumberOneTextField setBorderStyle:UITextBorderStyleBezel];
        [textShareView addSubview:phoneNumberOneTextField];
        phoneNumberTwoTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 103, 472, 30)];
        [phoneNumberTwoTextField setPlaceholder:@"Phone Number"];
        [phoneNumberTwoTextField setBackgroundColor:[UIColor whiteColor]];
        [phoneNumberTwoTextField setBorderStyle:UITextBorderStyleBezel];
        [textShareView addSubview:phoneNumberTwoTextField];
        phoneNumberThreeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 158, 472, 30)];
        [phoneNumberThreeTextField setPlaceholder:@"Phone Number"];
        [phoneNumberThreeTextField setBackgroundColor:[UIColor whiteColor]];
        [phoneNumberThreeTextField setBorderStyle:UITextBorderStyleBezel];
        [textShareView addSubview:phoneNumberThreeTextField];
        textTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 211, 472, 128)];
        textTextView.layer.borderWidth = 2.0;
        [[textTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [textShareView addSubview:textTextView];
        
        /* EMAIL */
        emailShareView = [[UIView alloc] initWithFrame:CGRectMake(1029, 190, 512, 415)];
        emailOneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 54, 472, 30)];
        [emailOneTextField setPlaceholder:@"Email address"];
        [emailOneTextField setBackgroundColor:[UIColor whiteColor]];
        [emailOneTextField setBorderStyle:UITextBorderStyleBezel];
        [emailShareView addSubview:emailOneTextField];
        emailTwoTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 103, 472, 30)];
        [emailTwoTextField setPlaceholder:@"Email address"];
        [emailTwoTextField setBackgroundColor:[UIColor whiteColor]];
        [emailTwoTextField setBorderStyle:UITextBorderStyleBezel];
        [emailShareView addSubview:emailTwoTextField];
        emailThreeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 158, 472, 30)];
        [emailThreeTextField setPlaceholder:@"Email address"];
        [emailThreeTextField setBackgroundColor:[UIColor whiteColor]];
        [emailThreeTextField setBorderStyle:UITextBorderStyleBezel];
        [emailShareView addSubview:emailThreeTextField];
        emailTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 211, 472, 128)];
        emailTextView.layer.borderWidth = 2.0;
        [[emailTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [emailShareView addSubview:emailTextView];
        
        
        textButton = [[UIButton alloc] initWithFrame:CGRectMake(800, 123, 93, 89)];
        [textButton setBackgroundImage:[UIImage imageNamed:@"text_btn.png"] forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(textButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:textButton];
        
        emailButton = [[UIButton alloc] initWithFrame:CGRectMake(900, 123, 92, 89)];
        [emailButton setBackgroundImage:[UIImage imageNamed:@"email_btn.png"] forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(emailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:emailButton];
        
        sendTextButton = [[UIButton alloc] initWithFrame:CGRectMake(358, 360, 154, 30)];
        [sendTextButton setBackgroundImage:[UIImage imageNamed:@"sendtext_btn.png"] forState:UIControlStateNormal];
        [sendTextButton addTarget:self action:@selector(sendTextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [textShareView addSubview:sendTextButton];
        
        sendEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(358, 360, 154, 30)];
        [sendEmailButton setBackgroundImage:[UIImage imageNamed:@"sendemail_btn.png"] forState:UIControlStateNormal];
        [sendEmailButton addTarget:self action:@selector(sendEmailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [emailShareView addSubview:sendEmailButton];
        
        [mainView addSubview:textShareView];
        [mainView addSubview:emailShareView];
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 701, 289, 67)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [exitButton setAlpha:1.0];
        [mainView addSubview:exitButton];
        
        if (_managedObjectContext == nil)
        {
            _managedObjectContext = [(AppController *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSLog(@"After _managedObjectContext: %@", _managedObjectContext);
        }
        
        NSError *error;
        NSArray *fetchedObjects;
        @synchronized(self)
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"NoInternetInfo" inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        }
        for (NSManagedObject *info in fetchedObjects) {
            NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~");
            NSLog(@"Method: %@", [info valueForKey:@"method"]);
            NSLog(@"name: %@", [info valueForKey:@"firstname"]);
            NSLog(@"Field1: %@", [info valueForKey:@"field1"]);
            NSLog(@"Field2: %@", [info valueForKey:@"field2"]);
            NSLog(@"Field3: %@", [info valueForKey:@"field3"]);
            NSLog(@"Message: %@", [info valueForKey:@"message"]);
            NSLog(@"Position: %@", [info valueForKey:@"position"]);
            NSLog(@"Number: %@", [info valueForKey:@"number"]);
            NSLog(@"Shots: %@", [info valueForKey:@"shots"]);
            NSLog(@"Goals: %@", [info valueForKey:@"goals"]);
            NSLog(@"FileName: %@", [info valueForKey:@"filename"]);
        }
	}
	return self;
}

-(void)dealloc
{
    [mainView release];
    mainView = nil;
    [backgroundImageView release];
    backgroundImageView = nil;
    [currentImageView release];
    currentImageView = nil;
    [super dealloc];
}

-(IBAction)exitButtonPressed:(id)sender
{
    NSLog(@"exit pressed");
    [mainView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}


-(IBAction)emailButtonPressed:(id)sender
{
    if(textButtonHasBeenPressed)
    {
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.4f];
        textShareView.frame = CGRectMake(1029, 190, 512, 415);
        [UIView commitAnimations];
    }
    
    [emailShareView setHidden:NO];
    [UIView beginAnimations:@"MoveView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4f];
    emailShareView.frame = CGRectMake(508, 190, 512, 415);
    [UIView commitAnimations];
    
    emailButtonHasBeenPressed = YES;
}

-(IBAction)textButtonPressed:(id)sender
{
    if(emailButtonHasBeenPressed)
    {
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.4f];
        emailShareView.frame = CGRectMake(1029, 190, 512, 415);
        [UIView commitAnimations];
    }
    
    [textShareView setHidden:NO];
    [UIView beginAnimations:@"MoveView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4f];
    textShareView.frame = CGRectMake(508, 190, 512, 415);
    [UIView commitAnimations];
    
    textButtonHasBeenPressed = YES;
}

-(IBAction)sendEmailButtonPressed:(id)sender
{
    [self addAttributeToDatabase:@"email" :self.firstName :emailTextView.text :emailOneTextField.text :emailTwoTextField.text :emailThreeTextField.text :self.playerShots :self.playerGoals :self.position :self.number :self.fileName];
}

-(IBAction)sendTextButtonPressed:(id)sender
{
    [self addAttributeToDatabase:@"text" :self.firstName :textTextView.text :phoneNumberOneTextField.text :phoneNumberTwoTextField.text :phoneNumberThreeTextField.text :self.playerShots :self.playerGoals :self.position :self.number :self.fileName];
}

-(void)addAttributeToDatabase:(NSString*)method :(NSString*)name :(NSString*)message :(NSString*)field1 :(NSString*)field2 :(NSString*)field3 :(NSString*)shots :(NSString*)goals :(NSString*)pos :(NSString*)num :(NSString*)file
{   
    NSManagedObject *noInternetInfo = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"NoInternetInfo"
                                       inManagedObjectContext:_managedObjectContext];
    [noInternetInfo setValue:method forKey:@"method"];
    [noInternetInfo setValue:field1 forKey:@"field1"];
    [noInternetInfo setValue:field2 forKey:@"field2"];
    [noInternetInfo setValue:field3 forKey:@"field3"];
    [noInternetInfo setValue:message forKey:@"message"];
    [noInternetInfo setValue:name forKey:@"firstname"];
    [noInternetInfo setValue:shots forKey:@"shots"];
    [noInternetInfo setValue:goals forKey:@"goals"];
    [noInternetInfo setValue:pos forKey:@"position"];
    [noInternetInfo setValue:num forKey:@"number"];
    [noInternetInfo setValue:file forKey:@"filename"];
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (UIImage*) addImageToImage:(UIImage*)img:(UIImage*)img3{
    CGSize size = CGSizeMake(img3.size.width, img3.size.height);
    UIGraphicsBeginImageContext(size);
    
    NSLog(@"w: %f h: %f", img.size.width, img.size.height);
    
    //CGPoint pointImg1 = CGPointMake(0,0);
    //[img drawAtPoint:pointImg1 ];
    [img drawInRect:CGRectMake(0, 0, 316, 423)];
    
    [img3 drawInRect:CGRectMake(0, 0, 316, 539)];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}
@end
