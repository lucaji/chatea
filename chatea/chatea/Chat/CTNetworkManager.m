/*
    chatea - messaging mobile app
    Copyright (C) 2015-2021  Luca Cipressi [lucaji][@][mail.ru]

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

//
//  CTChatManager.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 22/01/15.
//  Edited by Luca Cipressi on 10/11/2017
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//



#import "CTNetworkManager.h"
#import "CTPacketChat.h"
#import "CTChatAudioPlayerRecorder.h"

#define k_NET_SERVICE_NAME @"lucaji-chaTea"

NSString * const kCTNetworkChatMessageReceivedNotification = @"org.lucaji.ChaTea.networkChatMessageReceivedNotification";
NSString * const kCTNetworkChatMessageReceivedNotificationObjectKey = @"org.lucaji.ChaTea.networkChatMessageReceivedNotification.transcript";
NSString * const kCTPacketChatMediaInboundStartedNotification = @"org.lucaji.ChaTea.kCTPacketChatMediaInboundStartedNotification";
NSString * const kCTPacketChatMediaInboundCompletedNotification = @"org.lucaji.ChaTea.kCTPacketChatMediaInboundCompletedNotification";


NSString * const kWCPreferences_DisplayLog = @"displayLog";
NSString * const kWCPreferences_WalkieTalkieMode = @"walkieTalkieMode";

NSString * const kWCNetworkPeerIDKey = @"peerIDDefault";
//NSString * const kWCNetworkDisplayNameKey = @"displayNameKey";

#define kRetryTime 5.0


@interface CTNetworkManager () <MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;

//@property (nonatomic) NSMutableArray<MCPeerID*>*discoveredServices;
@property (nonatomic, readwrite) BOOL autoPlayReceivedChatMessages;


@end

@implementation CTNetworkManager

+(MCPeerID*)getRecycledPeerForKey:(NSString*)key andDisplayName:(NSString*)displayName {
    NSUserDefaults*userDefaults = NSUserDefaults.standardUserDefaults;
    NSData*data = [userDefaults dataForKey:key];
    if (data != nil) {
        id p = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([p isKindOfClass:MCPeerID.class]) {
            MCPeerID*peer = (MCPeerID*)p;
            if ([peer.displayName isEqualToString:displayName]) {
                return peer;
            }
        }
    }
    
    MCPeerID*iden = [[MCPeerID alloc] initWithDisplayName:displayName];
    if (key != nil) {
        NSData*data = [NSKeyedArchiver archivedDataWithRootObject:iden];
        [userDefaults setObject:data forKey:key];
        [userDefaults synchronize];
    }
    return iden;
}

/**
 * Initialization
 */
-(instancetype)init {
    self = [super init]; if (!self) return nil;
    
    _transcripts = [NSMutableArray array];

//    _discoveredServices = [NSMutableArray array];

    _unreadMessagesCount = 0;

    NSUserDefaults*userDefaults = NSUserDefaults.standardUserDefaults;
    [userDefaults registerDefaults:@{kWCPreferences_DisplayLog : @NO,
                                     kWCPreferences_WalkieTalkieMode : @YES
                                     }];

    self.autoPlayReceivedChatMessages = [userDefaults boolForKey:kWCPreferences_WalkieTalkieMode];
#ifdef DEBUG
    _showLog = NO; //[userDefaults boolForKey:kWCPreferences_DisplayLog];
#else
    _showLog = NO;
#endif
    
    NSString*deviceName = UIDevice.currentDevice.name;
    MCPeerID*localPeer = [CTNetworkManager getRecycledPeerForKey:kWCNetworkPeerIDKey andDisplayName:deviceName];
    _thisLocalPeer = [[CTBasePeer alloc] initPeerWithPeerID:localPeer];
    
    _session = [[MCSession alloc] initWithPeer:localPeer
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;

    self.nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:localPeer
                                                                     discoveryInfo:nil
                                                                       serviceType:k_NET_SERVICE_NAME];
    self.nearbyServiceAdvertiser.delegate = self;
    
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:localPeer
                                                                 serviceType:k_NET_SERVICE_NAME];
    self.nearbyServiceBrowser.delegate = self;
    

    
    return self;
}


-(void)addLogMessage:(NSString*)logMessage {
    CTPacketChat *transcript = [[CTPacketChat alloc] initServiceMessage:logMessage];
    [self insertTranscript:transcript];
}

-(void)browser:(MCNearbyServiceBrowser *)browser
     foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
#ifdef DEBUG
    if (self.showLog) {
        NSString*logString = [NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peerID.displayName];
        [self addLogMessage:logString];
    }
#endif
    
    if (peerID.hash > self.nearbyServiceAdvertiser.myPeerID.hash) {
        if (self.showLog) {
            NSString*logString = [NSString stringWithFormat:@"Inviting: %@", peerID.displayName];
            [self addLogMessage:logString];
        }

        [browser invitePeer:peerID
                  toSession:self.session
                withContext:nil
                    timeout:15.0];

    }
    
//    unsigned long count = self.discoveredServices.count;
//    if (count < kUTPRODUCT_MAXDISCOVERABLEDEVICES) {

        
//    } else {
//        NSString*logString = [NSString stringWithFormat:@"Cannot invite %@ in this version.", peerID.displayName];
//        [self addLogMessage:logString];
//    }
}


-(void)browser:(MCNearbyServiceBrowser *)browser
      lostPeer:(MCPeerID *)peerID {
    NSString*logString = [NSString stringWithFormat:@"%@ has disconnected.", peerID.displayName];
    [self addLogMessage:logString];
//    [self.discoveredServices removeObject:peerID];
}


-(void)browser:(MCNearbyServiceBrowser *)browser
didNotStartBrowsingForPeers:(NSError *)error {
    NSString*logString = [NSString stringWithFormat:@"%@", error.localizedDescription];
    [self addLogMessage:logString];
    self.isBrowsing = NO;
    
    //start browsing after delay
    [NSObject cancelPreviousPerformRequestsWithTarget:self.nearbyServiceBrowser selector:@selector(startBrowsingForPeers) object:nil];
    [self.nearbyServiceBrowser performSelector:@selector(startBrowsingForPeers) withObject:nil afterDelay:kRetryTime];

}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
      withContext:(NSData *)context
invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    if (![self.discoveredServices containsObject:peerID]) {
//        [self.discoveredServices addObject:peerID];
//    }
//    unsigned long count = self.discoveredServices.count;
//    if (count < kUTPRODUCT_MAXDISCOVERABLEDEVICES) {
//        if(peerID.hash <= advertiser.myPeerID.hash)
//            invitationHandler(NO, nil);
//        else
#ifdef DEBUG
    if (self.showLog) {
        NSString*logString = [NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peerID.displayName];
        [self addLogMessage:logString];
    }
#endif
    if (peerID.hash > self.nearbyServiceAdvertiser.myPeerID.hash) {
        if (self.showLog) {
            NSString*logString = [NSString stringWithFormat:@"Rejecting %@", peerID.displayName];
            [self addLogMessage:logString];
        }
        invitationHandler(NO, nil);
    } else {
        invitationHandler(YES, self.session);
        if (self.showLog) {
            NSString*logString = [NSString stringWithFormat:@"Invited by %@", peerID.displayName];
            [self addLogMessage:logString];
        }
    }
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didNotStartAdvertisingPeer:(NSError *)error {
    NSString*logString = [NSString stringWithFormat:@"%@", error.localizedDescription];
    [self addLogMessage:logString];
    self.isAdvertising = NO;
    
    //Attempt to start advertising again later
    [NSObject cancelPreviousPerformRequestsWithTarget:self.nearbyServiceAdvertiser selector:@selector(startAdvertisingPeer) object:nil];
    [self.nearbyServiceAdvertiser performSelector:@selector(startAdvertisingPeer) withObject:nil afterDelay:kRetryTime];

}



-(void)cancelDelayedSelectors {
    if(self.nearbyServiceAdvertiser) [NSObject cancelPreviousPerformRequestsWithTarget:self.nearbyServiceAdvertiser selector:@selector(startAdvertisingPeer) object:nil];
    
    if(self.nearbyServiceBrowser) [NSObject cancelPreviousPerformRequestsWithTarget:self.nearbyServiceBrowser selector:@selector(startBrowsingForPeers) object:nil];
}

-(void)persistAutoPlayReceivedChatMessages:(BOOL)autoPlayReceivedChatMessages {
    NSLog(@"persist autoplay %@",autoPlayReceivedChatMessages?@"YES":@"NO");
    self.autoPlayReceivedChatMessages = autoPlayReceivedChatMessages;
    NSUserDefaults*userDefaults = NSUserDefaults.standardUserDefaults;
    [userDefaults setBool:autoPlayReceivedChatMessages forKey:kWCPreferences_WalkieTalkieMode];
    [userDefaults synchronize];
}

-(void)setNetworkConnection:(BOOL)networkConnection {
    if (networkConnection == _networkConnection) { return; }
    _networkConnection = networkConnection;
    [self cancelDelayedSelectors];

    if (networkConnection) {
        NSLog(@"starting advertiser");
        self.isAdvertising = YES;
        [self.nearbyServiceAdvertiser startAdvertisingPeer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.showLog) {
                NSString*logString = [NSString stringWithFormat:@"Browsing for nearby devices..."];
                [self addLogMessage:logString];
            }
            self.isBrowsing = YES;
            [self.nearbyServiceBrowser startBrowsingForPeers];
            
        });
    } else {
        NSLog(@"stopping session");
        
        self.isAdvertising = NO;
        self.isBrowsing = NO;
        
        [self.nearbyServiceBrowser stopBrowsingForPeers];
        [self.nearbyServiceAdvertiser stopAdvertisingPeer];
    }
    NSString*logString = [NSString stringWithFormat:@"Network is %@", networkConnection?@"active.":@"off."];
    [self addLogMessage:logString];
}


#pragma mark - User Defaults and Settings

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    self.networkConnection = NO;
}

+(instancetype)singleton {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * note) {
                                                          NSLog(@"ChatManager entering background.");
                                                          CTNetworkManager.singleton.networkConnection = NO;
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * note) {
                                                          NSLog(@"ChatManager entering foreground.");
                                                          CTNetworkManager.singleton.networkConnection = YES;

                                                      }];

    });
    return sharedInstance;
}

#pragma mark - Broadcast methods

-(void)broadcastTextMessage:(NSString *)message {
    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initMessageTextWithMessage:message];
    [self sendMessage:outboundMessage];
}

-(void)broadcastAudioMessage:(NSData *)audioData
                    withTime:(NSUInteger)durationInSeconds {
    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initMessageAudioWithAudioData:audioData
                                                                     withDuration:durationInSeconds];
    [self sendMessage:outboundMessage];
}

-(void)broadcastDrawingMessage:(NSData*)drawingData withMessageText:(NSString*)message {
    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initMessageDrawingWithDrawingData:drawingData
                                                         withImageRepresentationData:drawingData
                                                                         withMessage:message];
    [self sendMessage:outboundMessage];
}


-(void)broadcastImageMessage:(UIImage *)image withMessageText:(NSString*)message {
    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initMessageWithImage:image];
    [self sendMessage:outboundMessage];
}

-(void)broadcastPictureMessageData:(NSData *)pictureData  withMessageText:(NSString*)message {
//    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initMessagePictureWithPictureData:pictureData
//                                                                         withMessage:message];
//    [self sendMessage:outboundMessage];
}


/**
 * RESOURCE BROADCAST GK MULTIPEER
 */
-(void)broadcastMediaFilePath:(NSString *)targetFile
                 toRecipients:(NSArray<CTBasePeer*>*)recipients {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSURL*fileURL = [NSURL URLWithString:targetFile];
    NSProgress *progress;
    // Loop on connected peers and send the image to each
    for (CTBasePeer *recipient in recipients) {
        // Send the resource to the remote peer.  The completion handler block will be called at the end of sending or if any errors occur
        progress = [self.session sendResourceAtURL:fileURL
                                                                withName:targetFile
                                                                  toPeer:recipient.peerPeerId
                                                   withCompletionHandler:^(NSError *error) {
                                                       // Implement this block to know when the sending resource transfer completes and if there is an error.
                                                       if (error) {
                                                           NSString*logString = [NSString stringWithFormat:@"Send resource to [%@] completed with Error [%@]", recipient.peerUserName, error.localizedDescription];
                                                           [self addLogMessage:logString];
                                                       }
                                                       else {
                                                           //                    CTPacketChat*outboundMessage = [[CTPacketChat alloc] initResourceWithURL:targetFile.fileURL];
                                                           //                    [CTPacketChat updateDelegateWithTranscript:outboundMessage];
                                                       }
                                                   }];
        
        //            targetFile.fileDownloadProgress = progress;
    }
    //        CTPacketChat*transcript = [[CTPacketChat alloc] initResourceWithName:resourceUrl.lastPathComponent
    //                                                                withProgress:progress
    //                                                          withSenderRecorder:SRTLocalRecorder.singleton
    //                                                                andDirection:UTPacketDirectionReceive];
    //        [CTPacketChat insertTranscript:transcript];
    
}


-(void)broadcastResourceWithURL:(NSURL *)resourceUrl {
}

-(void)insertTranscript:(CTPacketChat *)transcript {
    // Add to the data source
    [_transcripts addObject:transcript];

    if (self.delegate) {
        [self.delegate receivedTranscript:transcript];
        if (self.autoPlayReceivedChatMessages) {
            NSLog(@"autoPlayReceivedChatMessages received and playing");
            [[CTChatAudioPlayerRecorder singleton] speakChatMessageData:transcript.messageDataPacket withCompletion:^{
                
            }];

        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [NSNotificationCenter.defaultCenter postNotificationName:kCTNetworkChatMessageReceivedNotification
                                                          object:nil
                                                        userInfo:@{kCTNetworkChatMessageReceivedNotificationObjectKey:transcript}];

    });

}


-(void)updateDelegateWithTranscript:(CTPacketChat*)transcript {
//    // Find the data source index of the progress transcript
//    NSNumber *index = _imageNameIndex[transcript.resourceName];
//    NSUInteger idx = [index unsignedLongValue];
//    // Replace the progress transcript with the image transcript
//    [_transcripts replaceObjectAtIndex:idx withObject:transcript];
//    [self.delegate updateTranscript:transcript atIndex:idx];

}


-(void)sendMessage:(CTPacketChat*)message {
    [self insertTranscript:message];
    if (self.session.connectedPeers.count > 0) {
        NSData*messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
        __autoreleasing NSError* error = nil;
        [self.session sendData:messageData toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
        if (error) {
            NSString*logString = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self addLogMessage:logString];
        }
    }

}


-(void)clearChatContents {
    self.unreadMessagesCount = 0;
    [self.transcripts removeAllObjects];
}



#pragma mark - Strings

// Helper method for human readable printing of MCSessionState.  This state is per peer.
- (NSString *)stringForPeerConnectionState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            return @"connected.";

        case MCSessionStateConnecting:
            return @"connecting...";

        case MCSessionStateNotConnected:
            return @"standby.";
    }
    return @"Unknown";
}


#pragma mark - MCSessionDelegate methods

// Override this method to handle changes to peer session state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
#ifdef DEBUG
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
#endif
    NSString *adminMessage = [NSString stringWithFormat:@"'%@' is %@", peerID.displayName, [self stringForPeerConnectionState:state]];
    // Create an local transcript
    CTPacketChat *transcript = [[CTPacketChat alloc] initServiceMessage:adminMessage];
    // Add to the data source
    [self insertTranscript:transcript];
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (object && [object isMemberOfClass:CTPacketChat.class]) {
        CTPacketChat *transcript = (CTPacketChat*)object;
        transcript.packetDirection = CTPacketDirectionReceive;
        [self insertTranscript:transcript];
    }
}

//// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
//    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    // Create a resource progress transcript
//    CTPacketChat *transcript = [[CTPacketChat alloc] initResourceWithName:resourceName withProgress:progress withPeerID:peerID andDirection:CTPacketChatDirectionReceive];
//    [self insertTranscript:transcript];
}

//// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error {
    // If error is not nil something went wrong
//    if (error) {
//        NSString*logString = [NSString stringWithFormat:@"Error [%@] receiving resource from peer %@ ", error.localizedDescription, peerID.displayName];
//        [self addLogMessage:logString];
//    } else {
//        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
//        // Write to documents directory
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], resourceName];
//        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil]) {
//            NSString*logString = [NSString stringWithFormat:@"%@", error.localizedDescription];
//            [self addLogMessage:logString];
//        } else {
//            // Get a URL for the path we just copied the resource to
//            NSURL *imageUrl = [NSURL fileURLWithPath:copyPath];
//            // Create an image transcript for this received image resource
//            CTPacketChat *transcript = [[CTPacketChat alloc] initResourceWithURL:imageUrl withPeerID:peerID andDirection:CTPacketChatDirectionReceive];
//            [self updateDelegateWithTranscript:transcript];
//        }
//    }
}


//// Streaming API not utilized in this code
- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID {
//    NSLog(@"Received data over stream with name %@ from peer %@", streamName, peerID.displayName);
}


#pragma mark - UI Strings

+(NSDateFormatter*)timeFormatter {
    static NSDateFormatter*_timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm"];
    });
    return _timeFormatter;
}
+ (NSString *)stringTimeFromDate:(NSDate*)date {
    NSString *str = [self.timeFormatter stringFromDate:date];
    return str;
}


@end
