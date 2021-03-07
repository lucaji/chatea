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
//  CTChatManager.h
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 22/01/2015.
//  Edited by Luca Cipressi on 10/11/2017
//  Open Source adaption by Luca Cipressi on 07/03/2021.
//



@import Foundation;
@import AVFoundation;
@import MultipeerConnectivity;

@class CTPacketChat;
@class CTBasePeer;

NS_ASSUME_NONNULL_BEGIN

/// Chat Packet Notifications
extern NSString * const kCTNetworkChatMessageReceivedNotification;
extern NSString * const kCTNetworkChatMessageReceivedNotificationObjectKey;
extern NSString * const kUTPacketChatMediaInboundStartedNotification;
extern NSString * const kUTPacketChatMediaInboundCompletedNotification;

// Delegate protocol for updating UI when we receive data or resources from peers.
@protocol CTChatManagerDelegate <NSObject>

// Method used to signal to UI an initial message, incoming image resource has been received
- (void)receivedTranscript:(CTPacketChat*)transcript;
// Method used to signal to UI an image resource transfer (send or receive) has completed
- (void)updateTranscript:(CTPacketChat*)transcript atIndex:(NSUInteger)rowIndex;

@end

extern NSString * const kWCNetworkDisplayNameKey;
extern NSString * const kWCPreferences_DisplayLog;

@interface CTNetworkManager : NSObject <MCSessionDelegate>

@property (assign, nonatomic) id<CTChatManagerDelegate> delegate;

@property (nonatomic) BOOL networkConnection;

@property (nonatomic) BOOL showLog;
@property (nonatomic, readonly) BOOL autoPlayReceivedChatMessages;
-(void)persistAutoPlayReceivedChatMessages:(BOOL)autoPlayReceivedChatMessages;

@property (readonly, nonatomic) MCSession *session;
@property (nonatomic, strong) NSMutableArray <CTPacketChat*>*transcripts;
@property (nonatomic, assign) NSInteger unreadMessagesCount;

@property (nonatomic) BOOL isBrowsing;
@property (nonatomic) BOOL isAdvertising;


@property (readonly, nonatomic) CTBasePeer*thisLocalPeer;

+(instancetype)singleton;

-(void)addLogMessage:(NSString*)logMessage;

-(void)clearChatContents;



/**
 * Method for sending text messages to all connected remote peers.
 * Returna a message type transcript
 */
- (void)broadcastTextMessage:(NSString *)message;

/**
 * Method for sending image resources to all connected remote peers.
 * using NSURL.
 * Returns an progress type transcript for monitoring tranfer
*/
 - (void)broadcastResourceWithURL:(NSURL *)resourceUrl;

/**
 * Method for sending image data to all connected remote peers.
 * using NSURL.
 * Returns an progress type transcript for monitoring tranfer
 */
- (void)broadcastImageMessage:(UIImage *)image withMessageText:(NSString*)message;

-(void)broadcastDrawingMessage:(NSData*)drawingData withMessageText:(NSString*)message;

/**
 * Method for sending audio data to all connected remote peers.
 * using NSURL.
 * Returns an progress type transcript for monitoring tranfer
 */
- (void)broadcastAudioMessage:(NSData *)audioData withTime:(NSUInteger)durationInSeconds;

@end


NS_ASSUME_NONNULL_END
