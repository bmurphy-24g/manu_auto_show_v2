//
//  ChooseServerOrClientScene.m
//  ManU_2012
//
//  Created by Brian Murphy on 11/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooseServerOrClientScene.h"
#import "StartScene.h"
#import "AppDelegate.h"

@implementation ChooseServerOrClientScene
@synthesize managedObjectContext = _managedObjectContext;
int numberSharesProcessed = 0;
-(id) init
{
	if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
		//bg = [CCSprite spriteWithFile:@"blank.jpg"];
        //bg.position = ccp(winSize.width/2, winSize.height/2);
        //[self addChild:bg z:0];
        
        btManager = [BluetoothManager sharedInstance];
        
        newView = [[UIView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        
        [[[CCDirector sharedDirector] view] addSubview:newView];
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:[[CCDirector sharedDirector] view].frame];
        [backgroundImageView setImage:[UIImage imageNamed:@"blank.jpg"]];
        [newView addSubview:backgroundImageView];
        
        startClientButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 224, 471, 149)];
        [startClientButton setBackgroundImage:[UIImage imageNamed:@"startclient_btn.png"] forState:UIControlStateNormal];
        [startClientButton addTarget:self action:@selector(startClientPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:startClientButton];
        
        startServerButton = [[UIButton alloc] initWithFrame:CGRectMake(553, 404, 471, 149)];
        [startServerButton setBackgroundImage:[UIImage imageNamed:@"startserver_btn.png"] forState:UIControlStateNormal];
        [startServerButton addTarget:self action:@selector(startServerPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:startServerButton];
        
        shareAssetsButton = [[UIButton alloc] initWithFrame:CGRectMake(613, 619, 411, 149)];
        [shareAssetsButton setBackgroundImage:[UIImage imageNamed:@"shareyourcard_btn.png"] forState:UIControlStateNormal];
        [shareAssetsButton addTarget:self action:@selector(startShareAllAssetPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newView addSubview:shareAssetsButton];
        
        if (_managedObjectContext == nil)
        {
            _managedObjectContext = [(AppController *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSLog(@"After _managedObjectContext: %@", _managedObjectContext);
        }
	}
	return self;
}

- (IBAction)startServerPressedAction:(id)sender
{
    //UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    NSLog(@"Server Pressed");
    //[startClientButton removeFromSuperview];
    //[startServerButton removeFromSuperview];
    [newView removeFromSuperview];
    [btManager setEnabled:YES];
    [btManager setPowered:NO];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[WaitingForPlayersScreen scene] withColor:ccWHITE]];
}

-(IBAction)startClientPressedAction:(id)sender
{
    NSLog(@"Client Pressed");
    //[startClientButton removeFromSuperview];
    //[startServerButton removeFromSuperview];
    [newView removeFromSuperview];
    [btManager setEnabled:YES];
    [btManager setPowered:NO];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:[StartScene scene] withColor:ccWHITE]];
}

-(IBAction)startShareAllAssetPressed:(id)sender
{
    [shareAssetsButton setEnabled:NO];
    _rsClient = [[RSClient alloc] initWithProvider:RSProviderTypeRackspaceUS username:@"bwolcott" apiKey:@"85398437f96c6f488fd0e1251dcc1930"];
    
    [_rsClient authenticate:^{
        
        // authentication was successful
        NSLog(@"Authentication succeeded!");
        container = [[RSContainer alloc] init];
        //container.name = @"manu_ipad_2012";
        [self setContainer];
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        // authentication failed.  you can inspect the response, data, and error
        // objects to determine why.
        NSLog(@"Authentication failed!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error connecting to cloudfiles." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        [alert show];
        [alert release];
        [shareAssetsButton setEnabled:YES];
        
    }];
}

-(void) setContainer
{
    [_rsClient getContainers:^(NSArray *containers, NSError *jsonError) {
        for (RSContainer *c in containers) {
            
            if ([c.name isEqualToString:@"manu_ipad_2012"]) {
                container = c;
                NSLog(@"Sweet success finding container");
                [self uploadFromDatabase];
            }
        }
        //STAssertNotNil(self.container, @"Loading container failed.");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        //[self stopWaiting];
        NSLog(@"Load container failed.");
    }];
}

-(void)uploadFromDatabase
{
    numberSharesProcessed = 0;
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
    NSString* fileName = nil;
    if([fetchedObjects count] == 0)
    {
        [shareAssetsButton setEnabled:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Shares completed." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        [alert show];
        [alert release];
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
        fileName = [NSString stringWithFormat:@"%@.jpg", [info valueForKey:@"filename"]];
        NSLog(@"FileName: %@", [info valueForKey:@"filename"]);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:fullPathToFile];
        
        NSString* position = [info valueForKey:@"position"];
        NSString* number = [info valueForKey:@"number"];
        NSString* shots = [info valueForKey:@"shots"];
        NSString* goals = [info valueForKey:@"goals"];
        
        object = [[RSStorageObject alloc] init];
        object.name = [NSString stringWithFormat:@"%@", fileName];
        object.content_type = @"image/jpg";
        object.data = UIImageJPEGRepresentation(image, 100);
        
        [container uploadObject:object success:^{
            NSLog(@"Apparently succeeded?");
            NSLog(@"%@", fileName);
            NSLog(@"%@", info);
            NSString *urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/ipad/index.php?filename=%@&first=%@&last=%@", [info valueForKey:@"filename"], [info valueForKey:@"firstname"], @""];
            
            if(![position isEqualToString:@""])
            {
                urlAddress = [NSString stringWithFormat:@"%@&position=%@", urlAddress, [info valueForKey:@"position"]];
            }
            if(![number isEqualToString:@""])
            {
                urlAddress = [NSString stringWithFormat:@"%@&number=%@", urlAddress, [info valueForKey:@"number"]];
            }
            if(![shots isEqualToString:@""])
            {
                urlAddress = [NSString stringWithFormat:@"%@&shots=%@", urlAddress, [info valueForKey:@"shots"]];
            }
            if(![goals isEqualToString:@""])
            {
                urlAddress = [NSString stringWithFormat:@"%@&goals=%@", urlAddress, [info valueForKey:@"goals"]];
            }
            
            NSString *urlString = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSLog(@"ENCODED 1st: %@", urlString);
            NSURL* url = [NSURL URLWithString:urlString];
            if([self stringWithUrl:url])
            {
             
                urlAddress = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/filename.php?file=%@", [info valueForKey:@"filename"]];
                urlString = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                NSLog(@"ENCODED 1st: %@", urlString);
                url = [NSURL URLWithString:urlString];
                NSString* assetID = [self stringWithUrlResponse:url];
                NSLog(@"AssetID: %@", assetID);
                
                NSString* urlToSend = [NSString stringWithFormat:@"http://social-gen.com/chevroletfc/share_ajax.php?id=%@&type=%@&msg=%@&field1=%@&field2=%@&field3=%@", assetID, [info valueForKey:@"method"], [info valueForKey:@"message"], [info valueForKey:@"field1"], [info valueForKey:@"field2"], [info valueForKey:@"field3"]];
                NSLog(@"URL: %@", urlToSend);
                NSString* encodedUrl = [urlToSend stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                NSLog(@"ENCODED 2nd: %@", encodedUrl);
                
                url = [NSURL URLWithString:encodedUrl];
                if([self stringWithUrl:url])
                {
                    @synchronized(self)
                    {
                        [_managedObjectContext deleteObject:info];
                        NSError *error = nil;
                        if (_managedObjectContext != nil) {
                            if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
                                // Replace this implementation with code to handle the error appropriately.
                                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                //abort();
                            }
                        }
                    }
                }
            }
            numberSharesProcessed++;
            if(numberSharesProcessed == [fetchedObjects count])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Shares completed." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
                [alert show];
                [alert release];
                [shareAssetsButton setEnabled:YES];
            }
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            NSLog(@"Create object failed.");
        }];
        [object release];
        object = nil;
    }
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
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(error)
        NSLog(@"ERROR: %i", [httpResponse statusCode]);
    if([httpResponse statusCode] >= 400)
        return NO;
    
    // Construct a String around the Data from the response
    //return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    return YES;
}

- (NSString*)stringWithUrlResponse:(NSURL *)url
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
    NSString *responseBody = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    return responseBody;
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseServerOrClientScene *layer = [ChooseServerOrClientScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)dealloc
{
    NSLog(@"choose dealloc");
    [newView release];
    [startClientButton release];
    [startServerButton release];
    [backgroundImageView release];
    backgroundImageView = nil;
    [super dealloc];
}



@end
