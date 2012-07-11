//
//   Copyright 2012 jordi domenech <jordi@iamyellow.net>
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "NetIamyellowTiwsWSProxy.h"

@implementation NetIamyellowTiwsWSProxy

-(id)init
{
    connected = FALSE;
    return [super init];
}

-(void)clean
{
    if (WS) {
        if (connected) {
            [WS close];
        }
        RELEASE_TO_NIL(WS);
    }
}

-(void)dealloc
{
    [self clean];

    [super dealloc];
}

#pragma WebSocket Delegate

-(void)webSocketDidOpen:(SRWebSocket*)webSocket
{
    if ([self _hasListeners:@"open"]) {
        [self fireEvent:@"open" withObject:nil];
    }
}

-(void)webSocket:(SRWebSocket*)webSocket didFailWithError:(NSError*)error
{
    [self clean];

    if ([self _hasListeners:@"error"]) {
        NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"reconnect",@"advice",
                               [error description],@"error",
                               nil];
        
        [self fireEvent:@"error" withObject:event];
    }
}

-(void)webSocket:(SRWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString*)reason wasClean:(BOOL)wasClean
{
    connected = NO;
    
    [self clean];

    if ([self _hasListeners:@"close"]) {
        NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:NUMINT(code),@"code",reason,@"reason",nil];
        [self fireEvent:@"close" withObject:event];
    }
}

-(void)webSocket:(SRWebSocket*)webSocket didReceiveMessage:(id)data
{
    if ([self _hasListeners:@"message"]) {
        NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:data,@"data",nil];
        [self fireEvent:@"message" withObject:event];
    }
}

#pragma Public API

-(void)open:(id)url
{
    if (connected || WS) {
        return;
    }
    
    ENSURE_SINGLE_ARG(url, NSString);

    WS = [[[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]] autorelease];
    WS.delegate = self;
    [WS open];
}

-(void)close:(id)args
{
    [self clean];
}

-(void)send:(id)msg
{
    ENSURE_SINGLE_ARG(msg, NSString);

    if (WS) {
        [WS send:msg];
    }    
}

@end
