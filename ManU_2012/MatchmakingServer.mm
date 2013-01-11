
#import "MatchmakingServer.h"

typedef enum
{
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;

@implementation MatchmakingServer
{
	NSMutableArray *_connectedClients;
	ServerState _serverState;
}

@synthesize delegate = _delegate;
@synthesize maxClients = _maxClients;
@synthesize session = _session;
//@synthesize connectedClients = _connectedClients;

int numConnected = 0;

- (id)init
{
	if ((self = [super init]))
	{
		_serverState = ServerStateIdle;
        self.connectedClients = [NSMutableArray alloc];
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
	if (_serverState == ServerStateIdle)
	{
		_serverState = ServerStateAcceptingConnections;
        
		 self.connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
		_session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
		_session.delegate = self;
		_session.available = YES;
	}
}

- (void)stopAcceptingConnections
{
	NSAssert(_serverState == ServerStateAcceptingConnections, @"Wrong state");
    
	_serverState = ServerStateIgnoringNewConnections;
	_session.available = NO;
}

- (void)endSession
{
	NSAssert(_serverState != ServerStateIdle, @"Wrong state");
    
	_serverState = ServerStateIdle;
    
	[_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
    [_session release];
	_session = nil;
    
	self.connectedClients = nil;
    
	[self.delegate matchmakingServerSessionDidEnd:self];
}

/*- (NSMutableArray *)connectedClients
{
	return self.connectedClients;
}*/

- (NSUInteger)connectedClientCount
{
	return [self.connectedClients count];
}

- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
{
	return [_connectedClients objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
	return [_session displayNameForPeer:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
#endif
    
	switch (state)
	{
		case GKPeerStateAvailable:
			break;
            
		case GKPeerStateUnavailable:
			break;
            
            // A new client has connected to the server.
		case GKPeerStateConnected:
			if (_serverState == ServerStateAcceptingConnections)
			{
                if(self.connectedClients == nil)
                    NSLog(@"EY YO WHAT THE FUCK");
                else
                {
                if (![self.connectedClients containsObject:peerID])
				{
					[self.connectedClients addObject:peerID];
					[self.delegate matchmakingServer:self clientDidConnect:peerID];
				}
                }

				//numConnected++;
                //if(numConnected >= 2)
                    //[self.delegate matchmakingServer:self clientDidConnect:peerID];
			}
			break;
            
            // A client has disconnected from the server.
		case GKPeerStateDisconnected:
			if (_serverState != ServerStateIdle)
			{
				if ([self.connectedClients containsObject:peerID])
				{
                    if([self.connectedClients objectAtIndex:0] == peerID)
                    {
                        [self.connectedClients removeObject:peerID];
                        [self.delegate matchmakingServer:self clientDidDisconnect:0];
                    }
                    else
                    {
                        [self.connectedClients removeObject:peerID];
                        [self.delegate matchmakingServer:self clientDidDisconnect:1];
                    }
					
					
                    
				}
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{

	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);

    //[self receiveData];
    
	if (_serverState == ServerStateAcceptingConnections && numConnected < self.maxClients)
	{
		NSError *error;
		if ([session acceptConnectionFromPeer:peerID error:&error])
			NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
		else
			NSLog(@"MatchmakingServer: Error accepting connection from peer %@, %@", peerID, error);
	}
	else  // not accepting connections or too many clients
	{
		[session denyConnectionFromPeer:peerID];
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
#endif
    
	// Not used by the server.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: session failed %@", error);
#endif
    
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			//[self.delegate matchmakingServerNoNetwork:self];
			[self endSession];
		}
	}
}

- (void)receiveData
{
    /*_session.delegate = self;
    _session.available = NO;
	[_session setDataReceiveHandler:self withContext:nil];*/
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
//#ifdef DEBUG
	//NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if ([unarchiver containsValueForKey:@"1x"])
    {
        float x =[unarchiver decodeFloatForKey:@"1x"];
        float newX = 0;
        
        NSLog(@"%f", x);
        
        
        
    }

//#endif
}

@end
