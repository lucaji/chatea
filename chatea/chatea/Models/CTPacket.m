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
//  CTPacket.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 04/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//


#import "CTPacket.h"
#import "CTNetworkManager.h"

/**
 * The protocol version string used in this implementation
 */
static NSString* const StaticPacketProtocolVersionString = @"65fa9";


NSString * const kCTPacketSenderKey = @"packetSender";
NSString * const kCTPacketTimestampKey = @"packetTimeStamp";
NSString * const kCTPacketUniqueIdKey = @"packetUniqueId";
NSString * const kCTPacketProtocolVersionStringKey = @"packetProtocolVersionString";


@implementation CTPacket

static NSInteger UTPacketChatInstanceCounter = -1;

/**
 * Properties
 */

//+(NSUInteger)totalPacketCounter {
//    return UTPacketChatInstanceCounter + 1;
//}

+(NSInteger)currentPacketID {
    if (UTPacketChatInstanceCounter < 0)
        UTPacketChatInstanceCounter = 0;
    return UTPacketChatInstanceCounter;
}

+(void)setCurrentPacketID:(NSInteger)currentPacketID {
    if( UTPacketChatInstanceCounter != currentPacketID) {
        UTPacketChatInstanceCounter = currentPacketID;
    }
}



/**
 * Constructors
 */

-(void)commonInit {
    _packetProtocolVersionString = StaticPacketProtocolVersionString;
    _packetSequenceNumber = UTPacketChatInstanceCounter++;
    _packetDirection = CTPacketDirectionUndefined;
    _packetSender = nil;
    _packetTimestamp = [NSDate timeIntervalSinceReferenceDate];
    _packetUniqueId = [NSUUID UUID].UUIDString;
}


-(instancetype)init {
    assert(NO);
    self = [super init]; if (!self) return nil;
    [self commonInit];
    return self;
}

+(NSArray*)remotePacketKeys {
    static dispatch_once_t predicate = 0;
    static NSArray *keys = nil;
    dispatch_once(&predicate, ^{
        NSArray * ourKeys = @[
                               kCTPacketSenderKey,
                               kCTPacketTimestampKey,
                               kCTPacketUniqueIdKey,
                               kCTPacketProtocolVersionStringKey
                               ];
        keys = ourKeys;
    });
    return keys;
}

+(BOOL)ValidateRemotePacketDictionary:(NSDictionary*)remoteDictionary {
    for (NSString*key in self.remotePacketKeys) {
        id object = remoteDictionary[key];
        if (object == nil) {
            NSString *adminMessage = [NSString stringWithFormat:@"DEBUG: null key '%@' in dictionary %@.", key, remoteDictionary];
            NSLog(@"%@", adminMessage);
            return NO;
        }
    }
    NSString*packetVersion = remoteDictionary[kCTPacketProtocolVersionStringKey];
    if (packetVersion == nil || ![packetVersion isEqualToString:StaticPacketProtocolVersionString]) {
        NSString *adminMessage = [NSString stringWithFormat:@"DEBUG: invalid remote packet protocol version %@.", packetVersion];
        NSLog(@"%@", adminMessage);
        return NO;
    }
    return YES;
}

-(instancetype)initPacketForBroadcast {
    self = [super init]; if (!self) return nil;
    [self commonInit];
    _packetDirection = CTPacketDirectionSend;
    _packetSender = CTNetworkManager.singleton.thisLocalPeer;
    return self;
}

#pragma mark - NSCoding

//+(BOOL)supportsSecureCoding { return YES; }

-(void)encodeWithCoder:(NSCoder *)coder {
    assert(_packetDirection == CTPacketDirectionSend);
    [coder encodeObject:self.packetSender forKey:kCTPacketSenderKey];
    [coder encodeObject:self.packetProtocolVersionString forKey:kCTPacketProtocolVersionStringKey];
    [coder encodeDouble:self.packetTimestamp forKey:kCTPacketTimestampKey];
}

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init]; if (!self) return nil;
    [self commonInit];
    _packetDirection = CTPacketDirectionReceive;

    _packetSender = [coder decodeObjectForKey:kCTPacketSenderKey];
	_packetProtocolVersionString = [coder decodeObjectForKey:kCTPacketProtocolVersionStringKey];
	_packetTimestamp = [coder decodeDoubleForKey:kCTPacketTimestampKey];

    return self;
}


#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    CTPacket *packet = [(CTPacket *) [[self class] allocWithZone:zone] init];
    packet.packetUniqueId = self.packetUniqueId.copy;
    packet.packetSender = self.packetSender.copy;
	packet.packetProtocolVersionString = self.packetProtocolVersionString.copy;
    packet.packetTimestamp = self.packetTimestamp;
	packet.packetDirection = self.packetDirection;
    return packet;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    return [self isEqualToPacket:(CTPacket *)object];
}

- (BOOL)isEqualToPacket:(CTPacket *)aPacket {
    if (self == aPacket)
        return YES;
    return [aPacket isKindOfClass:[CTPacket class]] && [aPacket.packetUniqueId isEqualToString:self.packetUniqueId];
}

- (NSUInteger)hash {
    return self.packetUniqueId.hash;
}

@end
