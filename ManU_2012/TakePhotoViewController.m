//
//  TakePhotoViewController.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//
//

#import "TakePhotoViewController.h"
#import "StartScene.h"

@interface TakePhotoViewController ()

@end

@implementation TakePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //imageView = [[UIImageView alloc] initWithFrame:CGRectMake(128, -128, 768, 1024)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 113, 316, 539)];
        UIImage *background = [UIImage imageNamed:@"background5.jpg"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
        [self.view addSubview:backgroundImageView];
        //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
        
        //ACCEPT 733x349
        acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 349, 289, 67)];
        [acceptButton setBackgroundImage:[UIImage imageNamed:@"accept_btn.png"] forState:UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:acceptButton];
        [acceptButton setEnabled:NO];
        //DECLINE 733x474
        declineButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 474, 289, 67)];
        [declineButton setBackgroundImage:[UIImage imageNamed:@"decline_btn.png"] forState:UIControlStateNormal];
        [declineButton addTarget:self action:@selector(declineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [declineButton setEnabled:NO];
        [self.view addSubview:declineButton];
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(735, 701, 289, 67)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [exitButton setEnabled:NO];
        [self.view addSubview:exitButton];
        
        _rsClient = [[RSClient alloc] initWithProvider:RSProviderTypeRackspaceUS username:@"bwolcott" apiKey:@"85398437f96c6f488fd0e1251dcc1930"];
        
        [_rsClient authenticate:^{
            
            // authentication was successful
            NSLog(@"Authentication succeeded!");
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            
            // authentication failed.  you can inspect the response, data, and error
            // objects to determine why.
            NSLog(@"Authentication failed!");
            
        }];
        container = [[RSContainer alloc] init];
        //container.name = @"manu_ipad_2012";
        [self setContainer];
        
    }
    return self;
}

-(IBAction)exitButtonPressed:(id)sender
{
    NSLog(@"exit pressed");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

-(void) setContainer
{
    [_rsClient getContainers:^(NSArray *containers, NSError *jsonError) {
        for (RSContainer *c in containers) {
            
            if ([c.name isEqualToString:@"manu_ipad_2012"]) {
                container = c;
                NSLog(@"Sweet success finding container");
                //successHandler();
            }
            
        }
        
        //STAssertNotNil(self.container, @"Loading container failed.");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        //[self stopWaiting];
        NSLog(@"Load container failed.");
    }];
}

-(void)runCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"IDK inside this if statement");
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.navigationBarHidden = YES;
        imagePicker.wantsFullScreenLayout = YES;
        imagePicker.showsCameraControls = NO;
        
        
        //I have no idea why it's moving the origin by 128... but this offsets it. What the hell is going on
        UIImageView *overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(128, -128, 768, 1024)];
        UIImage *overlayImage = [UIImage imageNamed:@"camera_overlay.png"];
        overlayView.image = overlayImage;
        UIButton *takePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(666, 500, 67, 67)];
        [takePictureButton addTarget:self action:@selector(takePictureAction:) forControlEvents:UIControlEventTouchUpInside];
        //[takePictureButton setBackgroundColor:UIColor.blueColor];
        [takePictureButton setBackgroundImage:[UIImage imageNamed:@"camera_btn.png"] forState:UIControlStateNormal];
        [overlayView addSubview:takePictureButton];
        [takePictureButton release];
        
        
        [overlayView setUserInteractionEnabled:YES];
        imagePicker.cameraOverlayView = overlayView;
        [overlayView release];
        CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                                    RADIANS(90.0));
        imagePicker.cameraOverlayView.transform = rotateTransform;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = YES;
        [imagePicker release];
        
        [super viewDidAppear:YES];
    }
}

-(IBAction)acceptButtonPressed:(id)sender
{
    NSLog(@"accepted!");
    /*UIImageWriteToSavedPhotosAlbum(currentImage,
                                   self,
                                   @selector(image:finishedSavingWithError:contextInfo:),
                                   nil);*/
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyyyyHHmmss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [device name];
    
    NSString* newFileName = [NSString stringWithFormat:@"%@_%@", uniqueIdentifier, dateString];
    
    [formatter release];  // maybe; you might want to keep the formatter
    // if you're doing this a lot.
    
    object = [[RSStorageObject alloc] init];
    object.name = [NSString stringWithFormat:@"%@.jpg", newFileName];
    object.content_type = @"image/jpg";
    object.data = UIImageJPEGRepresentation(currentImage, 100);
    
    
    [container uploadObject:object success:^{
        NSLog(@"Apparently succeeded?");
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"Create object failed.");
    }];
    [object release];
    object = nil;
    
    //Start next scene
    //EnterYourInformationScene* enterYourInformation = [EnterYourInformationScene alloc];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:currentImage :newFileName] withColor:ccWHITE]];
    //[[CCDIrector sharedDirector] ]
    //Send currentImage to next scene?

}

-(IBAction)declineButtonPressed:(id)sender
{
    NSLog(@"declined!");
    [self runCamera];
    [declineButton setEnabled:NO];
    [acceptButton setEnabled:NO];
    [exitButton setEnabled:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"take photo view did load");
    [self runCamera];
}
                                                           
- (IBAction)takePictureAction:(id)sender
{
    NSLog(@"takePicture");
    [imagePicker takePicture];
}

- (void) orientationChanged:(NSNotification *)notification
{
    //NSLog(@"WTF");
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        CGAffineTransform transform = self.view.transform;
        transform = CGAffineTransformRotate(transform, (M_PI/2.0));
        imagePicker.cameraOverlayView.transform = transform;
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
        imagePicker.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,117.81);
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Final image estimate 400x538
    NSLog(@"didFinishPicking");
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSLog(@"Inside if");
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
                
        UIImage* overlay = [UIImage imageNamed:@"camera_overlay.png"];
        UIImage* playerOverlay = [UIImage imageNamed:@"playercard_overlay.png"];
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
        UIImage* finalImage = [self addImageToImage:image :overlay :playerOverlay];
        
        [self.view addSubview:imageView];
        NSLog(@"w: %f h: %f", finalImage.size.width, finalImage.size.height);

        imageView.image = finalImage;
        //imageView.transform = CGAffineTransformMakeRotation(RADIANS(270));
        currentImage = finalImage;
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
    //imagePicker.delegate = nil;
    [acceptButton setEnabled:YES];
    [declineButton setEnabled:YES];
    [exitButton setEnabled:YES];
}

- (UIImage*) addImageToImage:(UIImage*)img:(UIImage*)img2:(UIImage*)img3{
    CGSize size = CGSizeMake(img3.size.width, img3.size.height);
    UIGraphicsBeginImageContext(size);
    
    NSLog(@"w: %f h: %f", img.size.width, img.size.height);
    
    //CGPoint pointImg1 = CGPointMake(0,0);
    //[img drawAtPoint:pointImg1 ];
    [img drawInRect:CGRectMake(0, 0, 316, 423)];
    
    //CGPoint pointImage2 = CGPointMake(0, 0);
    [img2 drawInRect:CGRectMake(0, 0, 316, 423)];

    [img3 drawInRect:CGRectMake(0, 0, 316, 539)];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    NSLog(@"finishedSaving");
    if (error) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"Camera dealloc");
    
    [super dealloc];
}



@end
