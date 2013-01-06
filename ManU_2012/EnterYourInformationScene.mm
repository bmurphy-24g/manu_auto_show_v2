//
//  EnterYourInformationScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EnterYourInformationScene.h"
#import "StartScene.h"

@implementation EnterYourInformationScene
@synthesize fileName, currentImage;

bool keyboardShiftedUp = NO;
-(id) init
{
    NSLog(@"EnterYourInfo init");
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"background7.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:bg z:1];
        
        newImageView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [newImageView setUserInteractionEnabled:YES];
        [[[CCDirector sharedDirector] view] addSubview:newImageView];
        
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background7.jpg"]];
        [newImageView addSubview:backgroundImageView];
        
        // 116, 113
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 113, 316, 539)];
        
        submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitButton setFrame:CGRectMake(735, 600, 289, 67)]; // was 440
        [submitButton setBackgroundImage:[UIImage imageNamed:@"submit_btn.png"] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0, 0, 187, 67)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [newImageView addSubview:backButton];
        
        [newImageView addSubview:submitButton];
        //submitButton.transform = rotateTransform;
        
        // Set up the name text fields
        firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(540, 332, 250, 35)];
        [firstNameTextField setBackgroundColor:[UIColor whiteColor]];
        [firstNameTextField setBorderStyle:UITextBorderStyleBezel];
        firstNameTextField.text = @"";
        firstNameTextField.delegate = self;
        [newImageView addSubview:firstNameTextField];
        
        lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(540, 407, 250, 35)];
        [lastNameTextField setBackgroundColor:[UIColor whiteColor]];
        [lastNameTextField setBorderStyle:UITextBorderStyleBezel];
        lastNameTextField.text = @"";
        lastNameTextField.delegate = self;
        [newImageView addSubview:lastNameTextField];
        
        numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(822, 480, 100, 35)];
        [numberTextField setBackgroundColor:[UIColor whiteColor]];
        [numberTextField setBorderStyle:UITextBorderStyleBezel];
        [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        //numberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        numberTextField.text = @"";
        numberTextField.delegate = self;
        [newImageView addSubview:numberTextField];
        
        // 539x568
        //playLaterButton = [[[UITextField] alloc] initWithFrame:CGRectMake(539, 568, ]
        playLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playLaterButton setFrame:CGRectMake(735, 701, 289, 67)]; // was 440
        [playLaterButton setBackgroundImage:[UIImage imageNamed:@"playlater_btn.png"] forState:UIControlStateNormal];
        [playLaterButton addTarget:self action:@selector(playLaterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newImageView addSubview:playLaterButton];
        
        // Set up the drop down menu
        positions = [[NSArray alloc] initWithObjects:
                     @"Forward", @"Midfielder", @"Defender", @"Keeper", nil];
        
        positionPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(540, 515, 250, 20)];
        positionPickerView.showsSelectionIndicator = YES;
        positionPickerView.delegate = self;
        //UIGestureRecognizer* myGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerTapped:)];
        //[positionPickerView addGestureRecognizer:myGR];
        //[myGR release];
        positionPickerView.alpha = 0.0f;
        positionTextField = [[UITextField alloc] initWithFrame:CGRectMake(540, 480, 250, 35)];
        [positionTextField setBackgroundColor:[UIColor whiteColor]];
        positionTextField.enabled = NO;
        //positionTextField.layer.cornerRadius = 10.0;
        [positionTextField setBorderStyle:UITextBorderStyleBezel];//UITextBorderStyleRoundedRect];
        positionTextField.text = @"Forward";
        [newImageView addSubview:positionTextField];
        dropDownButton = [[UIButton alloc] initWithFrame:CGRectMake(748, 480, 42, 35)];
        [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropdownarrow.jpg"] forState:UIControlStateNormal];
        [dropDownButton addTarget:self action:@selector(dropDownButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newImageView addSubview:dropDownButton];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(dismissKeyboard)];
        
        [newImageView addGestureRecognizer:tap];
        [tap release];
        
        [newImageView addSubview:positionPickerView];
        
        keyboardShiftedUp = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShiftBackgroundUp) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShiftBackgroundDown) name:UIKeyboardWillHideNotification object:nil];
	}
	return self;
}

-(void)dismissKeyboard {
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    [numberTextField resignFirstResponder];
}


-(IBAction)backButtonPressed:(id)sender
{
    [newImageView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[SelectPhotoScene scene] withColor:ccWHITE]];
}
-(IBAction)playLaterButtonPressed:(id)sender
{
    NSLog(@"play later pressed");
    NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@", self.fileName];
    NSString* encodedUrl = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"ENCODED: %@", encodedUrl);
    
    NSURL* url = [NSURL URLWithString:encodedUrl];
    [self stringWithUrl:url];

    [newImageView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

- (BOOL)stringWithUrl:(NSURL *)url
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    if(error)
        return NO;
    
    // Construct a String around the Data from the response
    //return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    return YES;
}

-(IBAction)dropDownButtonPressed:(id)sender
{
    if(positionPickerView.alpha == 0.0f)
        positionPickerView.alpha = 1.0f;
    else
        positionPickerView.alpha = 0.0f;
}

-(IBAction)submitButtonPressed:(id)sender
{
    NSLog(@"submit pressed");
    NSLog(@"%@", self.fileName);
    [newImageView removeFromSuperview];
    //NSString *stringWithoutSpaces = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[InitialShareScene scene:self.currentImage :self.fileName :[firstNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] :@"" :[numberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] :positionTextField.text] withColor:ccWHITE]];
}

-(void) initVariables: (UIImage*)image: (NSString*)file
{
    self.currentImage = image;
    UIImage* playerOverlay = [UIImage imageNamed:@"playercard_overlay.png"];
    
    imageView.image = [[self addImageToImage:self.currentImage :playerOverlay] copy];
    NSLog(@"width: %f height: %f", imageView.image.size.width, imageView.image.size.height);
    [newImageView addSubview:imageView];
    self.fileName = [NSString stringWithString:file];
}

//+(CCScene *) scene
+(CCScene *) scene:(UIImage *)image :(NSString *)cloudFileName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EnterYourInformationScene *layer = [EnterYourInformationScene node];
    
    [layer initVariables:image :cloudFileName];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)textFieldDidBeginEditing:(UITextView *)textView{
    NSLog(@"did begin editing");
    
    
    
    //[newImageView setBounds:CGRectMake(0, 200, 1024, 768)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"did finish editing");
    
    
    
    //[newImageView setBounds:CGRectMake(0, 0, 1024, 768)];
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [positions count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [positions objectAtIndex:row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow");
    NSString* result = [positions objectAtIndex:row];
    positionTextField.text = result;
    positionPickerView.alpha = 0.0f;
    
}

-(void)dealloc
{
    positionPickerView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (UIImage*) addImageToImage:(UIImage*)img:(UIImage*)img3{
    CGSize size = CGSizeMake(IMAGE_COMPLETE_WIDTH, IMAGE_COMPLETE_HEIGHT);
    UIGraphicsBeginImageContext(size);
    
    NSLog(@"w: %f h: %f", img.size.width, img.size.height);
    
    //CGPoint pointImg1 = CGPointMake(0,0);
    //[img drawAtPoint:pointImg1 ];
    [img drawInRect:CGRectMake(0, 0, IMAGE_WIDTH_FOR_UPLOAD, IMAGE_HEIGHT_FOR_UPLOAD)];
    
    [img3 drawInRect:CGRectMake(0, 0, 316, 539)];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

-(void) keyBoardShiftBackgroundUp
{
    if(!keyboardShiftedUp)
    {
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.25f];
        newImageView.frame = CGRectMake(0, -200, 1024, 768);
        [UIView commitAnimations];
    }
    keyboardShiftedUp = YES;
}

-(void) keyBoardShiftBackgroundDown
{
    if(keyboardShiftedUp)
    {
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.25f];
        newImageView.frame = CGRectMake(0, 0, 1024, 768);
        [UIView commitAnimations];
    }
    keyboardShiftedUp = NO;
}

@end
