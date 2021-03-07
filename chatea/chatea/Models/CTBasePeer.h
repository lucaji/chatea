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
//  CTBasePeer.h
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 04/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MCPeerID;

//extern NSString * const kPeerVendorIdKey;
//extern NSString * const kPeerDeviceNameKey;
//extern NSString * const kPeerDeviceModel;
//extern NSString * const kPeerBonjourNameKey;
//extern NSString * const kPeerUserNameKey;
extern NSString * const kPeerAvatarImageKey;

extern NSString * const kPeerIsOnlineKey;
extern NSString * const kPeerLastSeenDateKey;

@interface CTBasePeer : NSObject <NSCopying, NSCoding>

/// Dictionary properties
//@property (nonatomic, copy) NSString* peerVendorId;
//@property (nonatomic, copy) NSString* peerDeviceName;
//@property (nonatomic, copy) NSString* peerDeviceModel;
//@property (nonatomic, copy) NSString* peerBonjourName;
@property (nonatomic, readonly, copy) NSString* peerUserName;
@property (nonatomic, strong) UIImage* peerAvatarImage;

@property (nonatomic) BOOL peerIsOnline;
@property (nonatomic) MCPeerID* peerPeerId;
@property (nonatomic, strong) NSDate* peerLastSeenDate;

//+(instancetype)PeerForLocalDevice;
-(instancetype)initPeerWithPeerID:(MCPeerID*)peerID;

@end
