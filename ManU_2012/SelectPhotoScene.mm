//
//  SelectPhotoScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectPhotoScene.h"


@implementation SelectPhotoScene
@synthesize sortedObjectsArray;

-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		bg = [CCSprite spriteWithFile:@"background4.jpg"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        
        [self addChild:bg z:0];
        
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        // 584x511 584x585
        takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhotoButton setFrame:CGRectMake(584, 585, 440, 135)];
        [takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takeyourphoto_btn.png"] forState:UIControlStateNormal];
        [takePhotoButton addTarget:self action:@selector(takePhotoPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [newView addSubview:takePhotoButton];
        
        continueWithoutPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [continueWithoutPhotoButton setFrame:CGRectMake(584, 511, 440, 67)];
        [continueWithoutPhotoButton setBackgroundImage:[UIImage imageNamed:@"continuewithoutphoto_btn.png"] forState:UIControlStateNormal];
        [continueWithoutPhotoButton addTarget:self action:@selector(continueWithoutPhotoPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:continueWithoutPhotoButton];
        
        // 61x188 292x188 522x188 753x188
        pictureOneButton = [[UIButton alloc] initWithFrame:CGRectMake(62, 187, 207, 277)];
        //[pictureOneButton setBackgroundColor:[UIColor whiteColor]];
        [pictureOneButton setBackgroundImage:[UIImage imageNamed:@"silhouette.png"] forState:UIControlStateNormal];
        [pictureOneButton addTarget:self action:@selector(pictureOnePressed:) forControlEvents:UIControlEventTouchUpInside];
        [pictureOneButton setEnabled:NO];
        [newView addSubview:pictureOneButton];
        
        pictureTwoButton = [[UIButton alloc] initWithFrame:CGRectMake(293, 187, 207, 277)];
        //[pictureTwoButton setBackgroundColor:[UIColor whiteColor]];
        [pictureTwoButton setBackgroundImage:[UIImage imageNamed:@"silhouette.png"] forState:UIControlStateNormal];
        [pictureTwoButton addTarget:self action:@selector(pictureTwoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [pictureTwoButton setEnabled:NO];
        [newView addSubview:pictureTwoButton];
        
        pictureThreeButton = [[UIButton alloc] initWithFrame:CGRectMake(523, 187, 207, 277)];
        //[pictureThreeButton setBackgroundColor:[UIColor whiteColor]];
        [pictureThreeButton setBackgroundImage:[UIImage imageNamed:@"silhouette.png"] forState:UIControlStateNormal];
        [pictureThreeButton addTarget:self action:@selector(pictureThreePressed:) forControlEvents:UIControlEventTouchUpInside];
        [pictureThreeButton setEnabled:NO];
        [newView addSubview:pictureThreeButton];
        
        pictureFourButton = [[UIButton alloc] initWithFrame:CGRectMake(754, 187, 207, 277)];
        //[pictureFourButton setBackgroundColor:[UIColor whiteColor]];
        [pictureFourButton setBackgroundImage:[UIImage imageNamed:@"silhouette.png"] forState:UIControlStateNormal];
        [pictureFourButton addTarget:self action:@selector(pictureFourPressed:) forControlEvents:UIControlEventTouchUpInside];
        [pictureFourButton setEnabled:NO];
        [newView addSubview:pictureFourButton];
        
        //2x289 995x289
        scrollLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 289, 30, 76)];
        [scrollLeftButton setBackgroundImage:[UIImage imageNamed:@"prev_btn.png"] forState:UIControlStateNormal];
        [scrollLeftButton addTarget:self action:@selector(scrollLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:scrollLeftButton];
        
        scrollRightButton = [[UIButton alloc] initWithFrame:CGRectMake(993, 289, 30, 76)];
        [scrollRightButton setBackgroundImage:[UIImage imageNamed:@"next_btn.png"] forState:UIControlStateNormal];
        [scrollRightButton addTarget:self action:@selector(scrollRightClicked:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:scrollRightButton];
        
        /*curImageOne = [UIImage alloc];
        curImageTwo = [UIImage alloc];
        curImageThree = [UIImage alloc];
        curImageFour = [UIImage alloc];*/
        
        currentLeftIndex = 0;
        
        fileNames = [[NSMutableArray alloc] initWithCapacity:20];
        
	}
	return self;
}

-(void)onEnterTransitionDidFinish {
    [self parseXMLFileAtURL:@"http://social-gen.com/chevroletfc/ipad/resources/latest_images.xml"];
}

int currentLeftIndex = 0;

-(void)loadImages
{
    for(NSString* s in fileNames)
    {
        NSLog(@"%@", s);
    }
    
    NSLog(@"Loading images");
    //Button 1
    if([fileNames count] > 0 && ![fileNames[0] isEqualToString:@"-1"])
    {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[0]]]];
        curImageOne = [UIImage imageWithData: imageData];
        [pictureOneButton setBackgroundColor:[UIColor clearColor]];
        [pictureOneButton setBackgroundImage:curImageOne forState:UIControlStateNormal];
        [pictureOneButton setEnabled:YES];
        NSLog(@"image on loaded");
        [imageData release];
    }
    
    if([fileNames count] > 1 && ![fileNames[1] isEqualToString:@"-1"])
    {
        //Button 2
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[1]]]];
        curImageTwo = [UIImage imageWithData: imageData];
        [pictureTwoButton setBackgroundColor:[UIColor clearColor]];
        [pictureTwoButton setBackgroundImage:curImageTwo forState:UIControlStateNormal];
        [pictureTwoButton setEnabled:YES];
        NSLog(@"image two loaded");
        [imageData release];
    }
    
    //Button 3
    if([fileNames count] > 2 && ![fileNames[2] isEqualToString:@"-1"])
    {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[2]]]];
        curImageThree = [UIImage imageWithData: imageData];
        [pictureThreeButton setBackgroundColor:[UIColor clearColor]];
        [pictureThreeButton setBackgroundImage:curImageThree forState:UIControlStateNormal];
        [pictureThreeButton setEnabled:YES];
        NSLog(@"image three loaded");
        [imageData release];
    }
    
    //Button 4
    if([fileNames count] > 3 && ![fileNames[3] isEqualToString:@"-1"])
    {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[3]]]];
        curImageFour = [UIImage imageWithData: imageData];
        [pictureFourButton setBackgroundColor:[UIColor clearColor]];
        [pictureFourButton setBackgroundImage:curImageFour forState:UIControlStateNormal];
        [pictureFourButton setEnabled:YES];
        NSLog(@"image four loaded");
        [imageData release];
        imageData = nil;
    }
}

-(IBAction)scrollLeftClicked:(id)sender
{
    NSLog(@"left clicked");
    if(currentLeftIndex > 0)
    {
        [scrollLeftButton setEnabled:NO];
        [scrollRightButton setEnabled:NO];
        currentLeftIndex--;
        curImageFour = curImageThree;
        [pictureFourButton setBackgroundImage:curImageFour forState:UIControlStateNormal];
        curImageThree = curImageTwo;
        [pictureThreeButton setBackgroundImage:curImageThree forState:UIControlStateNormal];
        curImageTwo = curImageOne;
        [pictureTwoButton setBackgroundImage:curImageTwo forState:UIControlStateNormal];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[currentLeftIndex]]]];
        curImageOne = [UIImage imageWithData: imageData];
        [imageData release];
        imageData = nil;
        [pictureOneButton setBackgroundImage:curImageOne forState:UIControlStateNormal];
        [scrollLeftButton setEnabled:YES];
        [scrollRightButton setEnabled:YES];
    }
}

-(IBAction)scrollRightClicked:(id)sender
{
    NSLog(@"right clicked");
    if((currentLeftIndex + 4) < [fileNames count])
    {
        [scrollLeftButton setEnabled:NO];
        [scrollRightButton setEnabled:NO];
        curImageOne = curImageTwo;
        [pictureOneButton setBackgroundImage:curImageOne forState:UIControlStateNormal];
        curImageTwo = curImageThree;
        [pictureTwoButton setBackgroundImage:curImageTwo forState:UIControlStateNormal];
        curImageThree = curImageFour;
        [pictureThreeButton setBackgroundImage:curImageThree forState:UIControlStateNormal];
        currentLeftIndex++;
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://a65724859e6559c43827-07ad0f7ce40dfee8df7f975329be3801.r13.cf1.rackcdn.com/%@.jpg", fileNames[currentLeftIndex+3]]]];
        curImageFour = nil;
        curImageFour = [UIImage imageWithData: imageData];
        [imageData release];
        imageData = nil;
        [pictureFourButton setBackgroundImage:curImageFour forState:UIControlStateNormal];
        [scrollLeftButton setEnabled:YES];
        [scrollRightButton setEnabled:YES];
    }
    else
    {
        NSLog(@"Hit end of array");
    }
}

-(IBAction)pictureOnePressed:(id)sender
{
    NSLog(@"One Pressed");
    NSString* newFileName;
    newFileName = [fileNames objectAtIndex:currentLeftIndex];
    NSArray *bits = [newFileName componentsSeparatedByString: @"."];
    newFileName = [bits objectAtIndex:0];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:curImageOne :newFileName] withColor:ccWHITE]];
}

-(IBAction)pictureTwoPressed:(id)sender
{
    NSLog(@"Two Pressed");
    NSString* newFileName;
    newFileName = [fileNames objectAtIndex:currentLeftIndex+1];
    NSArray *bits = [newFileName componentsSeparatedByString: @"."];
    newFileName = [bits objectAtIndex:0];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:curImageTwo :newFileName] withColor:ccWHITE]];
}

-(IBAction)pictureThreePressed:(id)sender
{
    NSLog(@"Three Pressed");
    NSString* newFileName;
    newFileName = [fileNames objectAtIndex:currentLeftIndex+2];
    NSArray *bits = [newFileName componentsSeparatedByString: @"."];
    newFileName = [bits objectAtIndex:0];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:curImageThree :newFileName] withColor:ccWHITE]];
}

-(IBAction)pictureFourPressed:(id)sender
{
    NSLog(@"Four Pressed");
    NSString* newFileName;
    newFileName = [fileNames objectAtIndex:currentLeftIndex+3];
    NSArray *bits = [newFileName componentsSeparatedByString: @"."];
    newFileName = [bits objectAtIndex:0];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:curImageFour :newFileName] withColor:ccWHITE]];
}

-(void)dealloc
{
    [ElementValue release];
    [fileNames release];
    [pictureOneButton release];
    [pictureTwoButton release];
    [pictureThreeButton release];
    [pictureFourButton release];
    [scrollLeftButton release];
    [scrollRightButton release];
    [newView release];
    rssParser.delegate = nil;
    [rssParser release];
    [articles release];
    
    [super dealloc];
}

- (IBAction)continueWithoutPhotoPressedAction:(id)sender
{
    //[continueWithoutPhotoButton removeFromSuperview];
    //[takePhotoButton removeFromSuperview];
    [newView removeFromSuperview];
    NSLog(@"Button Pressed");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[EnterYourInformationScene scene:[UIImage imageNamed:@"silhouette.png"] :@"silhouette3"] withColor:ccWHITE]];
}

- (IBAction)takePhotoPressedAction:(id)sender
{
    NSLog(@"Button Pressed");
    //[continueWithoutPhotoButton removeFromSuperview];
    //[takePhotoButton removeFromSuperview];
    [takePhotoButton setEnabled:NO];
    [newView removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[TakePhotoScene scene] withColor:ccWHITE]];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SelectPhotoScene *layer = [SelectPhotoScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark RSS XML STUFF

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    NSString *errorString = [NSString stringWithFormat:@"Error code %i", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement = [elementName copy];
    ElementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"item"]) {
        item = [[NSMutableDictionary alloc] init];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [fileNames addObject:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"item"]) {
        
        [articles addObject:[item copy]];
    } else {
        [item setObject:ElementValue forKey:elementName];
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (errorParsing == NO)
    {
        NSLog(@"XML processing done!");
        [self loadImages];
    } else {
        NSLog(@"Error occurred during XML processing");
    }
    
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    
    NSString *agentString = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:URL]];
    [request setValue:agentString forHTTPHeaderField:@"User-Agent"];
    NSData *xmlFile = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    
    
    articles = [[NSMutableArray alloc] init];
    errorParsing=NO;
    
    rssParser = [[NSXMLParser alloc] initWithData:xmlFile];
    [rssParser setDelegate:self];
    
    // You may need to turn some of these on depending on the type of XML file you are parsing
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
    
    [rssParser parse];
    
    
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"File found and parsing started");
    
}

@end
