//
//  GKHelper.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>
#import <GameKit/GameKit.h>

@interface GKHelper : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate> {
    
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) CADisplayLink *timerLink;
-(void) connectToPeer;
@end
