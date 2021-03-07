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
//  CTBasePeer.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 17/04/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//

#import "CTBasePeer.h"
#import "CDFInitialsAvatar.h"
@import MultipeerConnectivity;

//NSString * const kPeerVendorIdKey = @"peerVendorId";

//NSString * const kPeerDeviceNameKey = @"peerDeviceName";
//NSString * const kPeerDeviceModel = @"peerDeviceModel";
//NSString * const kPeerBonjourNameKey = @"peerBonjourName";
//NSString * const kPeerUserNameKey = @"peerUserName";
NSString * const kPeerAvatarImageKey = @"peerAvatarImage";

NSString * const kPeerIsOnlineKey = @"peerIsOnline";
NSString * const kPeerLastSeenDateKey = @"peerLastSeenDate";

//NSString * const kPeerIDDefaultKey = @"peerIDDefault";

@implementation CTBasePeer

//-(MCPeerID*)newPeerID{
//    NSString *deviceName = [UIDevice currentDevice].name;
//    //Replace deviceName if it's not valid for use
//    if (!deviceName || deviceName.length <= 0 || deviceName.length > 63)
//        deviceName = [UIDevice currentDevice].model;
//    return [[MCPeerID alloc] initWithDisplayName:deviceName];
//}


//+(instancetype)PeerForLocalDevice {
//    return [[self alloc] initPeerForLocalDevice];
//}

//-(void)setPeerUserName:(NSString *)peerUserName {
//    if (![_peerUserName isEqualToString:peerUserName]) {
//        CGRect avatarRect = CGRectMake(0, 0, 58, 58);
//        CDFInitialsAvatar*avatar = [[CDFInitialsAvatar alloc] initWithRect:avatarRect fullName:peerUserName];
//        _peerAvatarImage = [avatar imageRepresentation];
//    }
//    _peerUserName = peerUserName;
//}

//-(UIImage*)peerAvatarImage {
//    if (_peerAvatarImage == nil) {
//        self.peerUserName = self.peerDeviceName;
//    }
//    return _peerAvatarImage;
//}

-(NSString*)peerUserName {
    return self.peerPeerId.displayName.copy;
}

-(instancetype)initPeerWithPeerID:(MCPeerID*)peerID {
    self = [super init]; if (!self) return nil;
    [self commonInit];
    
//    _peerVendorId = UIDevice.currentDevice.identifierForVendor.UUIDString;
//    _peerDeviceName = UIDevice.currentDevice.name;
//    _peerDeviceModel = UIDevice.currentDevice.model;
//    _peerBonjourName =
//    self.peerUserName = _peerDeviceName;
    
    
//    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
//    NSData*peerIDData = [defaults objectForKey:kPeerIDDefaultKey];
//    MCPeerID *peerID = nil;
//    if (peerIDData == nil) {
//        peerID = [self newPeerID];
//        peerIDData = [NSKeyedArchiver archivedDataWithRootObject:peerID];
//        [defaults setObject:peerIDData forKey:kPeerIDDefaultKey];
//        [defaults synchronize];
//    } else {
//        peerID = [NSKeyedUnarchiver unarchiveObjectWithData:peerIDData];
//    }
    self.peerPeerId = peerID;
    NSString*peerUserName = peerID.displayName;
    CGRect avatarRect = CGRectMake(0, 0, 58, 58);
    CDFInitialsAvatar*avatar = [[CDFInitialsAvatar alloc] initWithRect:avatarRect fullName:peerUserName];
    _peerAvatarImage = [avatar imageRepresentation];

    return self;
}

-(instancetype)init {
    self = [super init]; if (!self) return nil;
    [self commonInit];
    return self;
}

-(void)commonInit {
//    _peerVendorId = nil;
//    _peerDeviceName = nil;
//    _peerDeviceModel = nil;
//    _peerBonjourName = nil;
//    _peerUserName = nil;
    _peerAvatarImage = nil;
    _peerIsOnline = NO;

    _peerPeerId = nil;

    _peerLastSeenDate = [NSDate date];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    CTBasePeer *recorder = [(CTBasePeer *) [[self class] allocWithZone:zone] init];
//    recorder.peerVendorId = self.peerVendorId.copy;
//    recorder.peerDeviceName = self.peerDeviceName.copy;
//    recorder.peerDeviceModel = self.peerDeviceModel.copy;
//    recorder.peerBonjourName = self.peerBonjourName.copy;
//    recorder.peerUserName = self.peerUserName.copy;
    recorder.peerAvatarImage = self.peerAvatarImage.copy;
    recorder.peerPeerId = self.peerPeerId;
    recorder.peerIsOnline = self.peerIsOnline;
    recorder.peerLastSeenDate = self.peerLastSeenDate.copy;
    return recorder;
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder*)coder {
//    [coder encodeObject:self.peerVendorId forKey:kPeerVendorIdKey];
//    [coder encodeObject:self.peerDeviceName forKey:kPeerDeviceNameKey];
//    [coder encodeObject:self.peerDeviceModel forKey:kPeerDeviceModel];
//    [coder encodeObject:self.peerBonjourName forKey:kPeerBonjourNameKey];
//    [coder encodeObject:self.peerUserName forKey:kPeerUserNameKey];
    [coder encodeObject:self.peerAvatarImage forKey:kPeerAvatarImageKey];

}

-(id)initWithCoder:(NSCoder*)coder {
    self = [super init]; if (!self) return nil;
    [self commonInit];

//    _peerVendorId = [coder decodeObjectForKey:kPeerVendorIdKey];
//    _peerDeviceName = [coder decodeObjectForKey:kPeerDeviceNameKey];
//    _peerDeviceModel = [coder decodeObjectForKey:kPeerDeviceModel];
//    _peerBonjourName = [coder decodeObjectForKey:kPeerBonjourNameKey];
//    _peerUserName = [coder decodeObjectForKey:kPeerUserNameKey];
    _peerAvatarImage = [coder decodeObjectForKey:kPeerAvatarImageKey];
    return self;
}

+(NSArray*)BaseRecoderKeys {
    static dispatch_once_t predicate = 0;
    static NSArray *keys = nil;
    dispatch_once(&predicate, ^{
        NSArray * ourKeys = @[
//                              kPeerVendorIdKey,
//                              kPeerDeviceNameKey,
//                              kPeerDeviceModel,
//                              kPeerBonjourNameKey,
//                              kPeerUserNameKey,
                              kPeerAvatarImageKey
                              ];
        keys = ourKeys;
    });
    return keys;
}




+(BOOL)ValidateRemotePacketDictionary:(NSDictionary*)remoteDictionary {
    for (NSString*key in self.BaseRecoderKeys) {
        id object = remoteDictionary[key];
        if (object == nil) {
#ifdef DEBUG
            NSString *adminMessage = [NSString stringWithFormat:@"DEBUG: null key '%@' in dictionary %@.", key, remoteDictionary];
            NSLog(@"%@", adminMessage);
#endif
            return NO;
        }
    }
    return YES;
}

#pragma mark - Equality

-(BOOL)isEqual:(id)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRecorder:object];
}

-(BOOL)isEqualToRecorder:(CTBasePeer*)d {
    return ([self.peerPeerId.displayName isEqualToString:d.peerPeerId.displayName]);
}

-(NSUInteger)hash {
    return self.peerPeerId.displayName.hash;
}

@end
