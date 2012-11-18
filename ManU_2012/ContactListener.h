//
//  ContactListener.h
//  ManU_2012
//
//  Created by Brian Murphy on 10/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"
#import "Ball.h"
#import "Player.h"
#import <GameKit/GameKit.h>
#import "BoxDebugLayer.h"
#import "Box2D.h"
class ContactListener : public b2ContactListener {
public:
	ContactListener(b2Fixture *leftPlayerFixture, b2Fixture *rightPlayerFixture, b2Fixture *ball);
	~ContactListener();
    
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
    
private:
    b2Fixture *leftFixture;
    b2Fixture *rightFixture;
    b2Fixture *ballFixture;
};
