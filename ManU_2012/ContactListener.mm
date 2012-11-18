//
//  ContactListener.m
//  ManU_2012
//
//  Created by Brian Murphy on 10/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"
#import "Ball.h"
#import "Player.h"

#define IS_PLAYER(x, y)         (x.type == kGameObjectPlayer || y.type == kGameObjectPlayer)
#define IS_PLATFORM(x, y)       (x.type == kGameObjectPlatform || y.type == kGameObjectPlatform)


ContactListener::ContactListener(b2Fixture *leftPlayerFixture, b2Fixture *rightPlayerFixture, b2Fixture *ball) {
    leftFixture = leftPlayerFixture;
    rightFixture = rightPlayerFixture;
    ballFixture = ball;
}

ContactListener::~ContactListener() {
}

void ContactListener::BeginContact(b2Contact *contact) {
    //float32 idA = contact->GetFixtureA()->GetBody();
	/*GameObject *o1 = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
	GameObject *o2 = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
    
	if (IS_PLATFORM(o1, o2) && IS_PLAYER(o1, o2)) {
        CCLOG(@"-----> Player made contact with platform!");
    }*/
    if((contact->GetFixtureA() == leftFixture && contact->GetFixtureB() == ballFixture)
       || (contact->GetFixtureB() == leftFixture && contact->GetFixtureA() == ballFixture))
    {
        NSLog(@"Left and ball collided");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LeftShoots"
         object:nil ];
    }
    else if ((contact->GetFixtureA() == rightFixture && contact->GetFixtureB() == ballFixture)
             || (contact->GetFixtureB() == rightFixture && contact->GetFixtureA() == ballFixture))
    {
        NSLog(@"Right and ball collided");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RightShoots"
         object:nil ];
    }
    //NSLog(@"Colision!");
}

void ContactListener::EndContact(b2Contact *contact) {
	/*GameObject *o1 = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
	GameObject *o2 = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
    
	if (IS_PLATFORM(o1, o2) && IS_PLAYER(o1, o2)) {
        CCLOG(@"-----> Player lost contact with platform!");
    }*/
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}
