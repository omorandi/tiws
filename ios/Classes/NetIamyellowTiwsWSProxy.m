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


#pragma WebSocket Delegate

-(void)webSocketDidOpen:(SRWebSocket*)webSocket
{
    connected  = YES;

    if ([self _hasListeners:@"open"]) {
        [self fireEvent:@"open" withObject:nil];
    }
}

-(void)webSocket:(SRWebSocket*)webSocket didFailWithError:(NSError*)error
{
    connected  = NO;

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

    if ([self _hasListeners:@"close"]) {
        NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:NUMINTEGER(code),@"code",reason,@"reason",nil];
        [self fireEvent:@"close" withObject:event];
    }
}

-(void)webSocket:(SRWebSocket*)webSocket didReceiveMessage:(id)data
{
    if ([data isKindOfClass:[NSData class]]) {
		data = [[TiBlob alloc] initWithData:data mimetype:@"application/octet-stream"];
	}

    if ([self _hasListeners:@"message"]) {
        NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:data,@"data",nil];
        [self fireEvent:@"message" withObject:event];
    }
}

#pragma Public API

-(void)open:(id)args
{
    if (WS || connected) {
        return;
    }

    id url = nil;
    ENSURE_ARG_AT_INDEX(url, args, 0, NSString);
    id protocols = nil;
    ENSURE_ARG_OR_NIL_AT_INDEX(protocols, args, 1, NSArray);
    id headers = nil;
    ENSURE_ARG_OR_NIL_AT_INDEX(headers, args, 2, NSDictionary);

    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (headers) {
        for (NSString* header in headers) {
            [req setValue:[headers objectForKey:header] forHTTPHeaderField:header];
        }
    }

    WS = [[SRWebSocket alloc] initWithURLRequest:req protocols:protocols];
    WS.delegate = self;
    [WS open];
}


- (void)reconnect:(id)args
{
    WS.delegate = nil;
    [WS close];

    id url = nil;
    ENSURE_ARG_AT_INDEX(url, args, 0, NSString);
    id protocols = nil;
    ENSURE_ARG_OR_NIL_AT_INDEX(protocols, args, 1, NSArray);

    WS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] protocols:protocols];
    WS.delegate = self;
    [WS open];
}

-(void)close:(id)args
{
    if (WS && connected) {
        [WS close];

    }
}

-(void)send:(id)msg
{
    ENSURE_SINGLE_ARG(msg, NSObject);
    if ([msg isKindOfClass:[NSString class]]) {
        msg = [TiUtils stringValue:msg];
    } else if ([msg isKindOfClass:[TiBlob class]]) {
        msg = [msg data];
    } else {
        NSAssert(NO, @"Argument type must be NSString or TiBlob");
    }

    if (WS && connected) {
        [WS send:msg];
    }
}

-(NSNumber*)readyState
{
    if (WS == nil) {
        return [NSNumber numberWithInt:-1];
    }
    return [NSNumber numberWithInt:WS.readyState];
}

@end
