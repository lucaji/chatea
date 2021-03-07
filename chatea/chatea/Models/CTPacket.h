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
//  CTPacket.h
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 04/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//


@import Foundation;
@import MultipeerConnectivity;

#import "CTBasePeer.h"

///------------------------------
/// @name: Packet Dictionary Keys
///------------------------------

extern NSString * const kCTPacketSenderKey;
extern NSString * const kCTPacketTimestampKey;
extern NSString * const kCTPacketUniqueIdKey;
extern NSString * const kCTPacketProtocolVersionStringKey;

typedef NS_ENUM(NSInteger, CTPacketDirection) {
    CTPacketDirectionUndefined,
    CTPacketDirectionSend,
    CTPacketDirectionReceive
};

/**
 @name Legacy Completion Blocks
 */
typedef void(^CTBroadcastPacketSuccessBlock)(NSDictionary * response);
typedef void(^CTBroadcastPacketFailureBlock)(NSError * error);


@interface CTPacket : NSObject <NSCoding, NSCopying> //, NSSecureCoding>

///-------------------------------
/// @name Class Properties
///-------------------------------

/**
 * Class Property
 * Packet counter accumulator
 */
@property (class, atomic) NSInteger currentPacketID;

///-------------------------------
/// @name Dictionary Properties
///-------------------------------

@property (nonatomic) NSString*packetUniqueId;

/**
 * Packet progressive Local id
 */
@property (nonatomic) NSInteger packetSequenceNumber;

/**
 * The packet timestamp
 */
@property (nonatomic) NSTimeInterval packetTimestamp;


/**
 * The packet direction (inbound, outbound)
 */
@property (nonatomic) CTPacketDirection packetDirection;

/**
 * The sender recorder is SRTLocalRecorder.singleton
 * when outbounding, when receiving it must be decoded
 * and looked up from the connected recorders list.
 * more over it can be used to accept new logins.
 */
@property (nonatomic) CTBasePeer* packetSender;


/**
 * The protocol version number used in this implementation
 */
@property (nonatomic) NSString* packetProtocolVersionString;


-(instancetype)initPacketForBroadcast;

@end
