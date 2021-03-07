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
//  CTPacketChat.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 27/04/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//

#import "CTPacketChat.h"
#import "NSDate+Utils.h"

/// Chat Packet Notifications
/// Dictionary Keys
NSString* const kCTPacketChatMessageTypeKey = @"messageType";
NSString* const kCTPacketChatMessageSentTimeKey = @"messageSentTime";
NSString* const kCTPacketChatMessageTextContentKey = @"messageTextContent";
NSString* const kCTPacketChatMessageDataPacketKey = @"messageDataPacket";
NSString* const kCTPacketChatMessageAudioDurationKey = @"messageAudioDuration";
NSString* const kCTPacketChatMessagePictureWidthKey = @"messagePictureWidth";
NSString* const kCTPacketChatMessagePictureHeightKey = @"messagePictureHeight";
/// Resource Transfer Keys
NSString* const kCTPacketChatMessageResourceNameKey = @"messageResourceName";


@implementation CTPacketChat


-(instancetype)init {
    self = [super init]; if (!self) return nil;
    [self commonChatInit];
    return self;
}

-(void)commonChatInit {
    _messageType = CTChatMessageTypeUndefined;

    _messageSentTime = [NSDate date];
    _messageTextContent = nil;
    
    _messageDataPacket = nil;
    _messageAudioDuration = 0.0f;
    _messagePictureWidth = 0.0f;
    _messagePictureHeight = 0.0f;
    
    _messageResourceName = nil;
    _messagePictureImage = nil;

    _progress = nil;
}


-(instancetype)initServiceMessage:(NSString*)servicemessage {
    assert(servicemessage);
    self = [super initPacketForBroadcast]; if (!self)return nil;
    [self commonChatInit];
    _messageTextContent = servicemessage;
    _messageType = CTChatMessageTypeService;
    return self;
}

-(instancetype)initMessageTextWithMessage:(NSString*)message {
    assert(message);
    self = [super initPacketForBroadcast]; if (!self) return nil;
    [self commonChatInit];

    _messageTextContent = message;
    _messageType = CTChatMessageTypeText;
    return self;
}

-(instancetype)initMessageWithImage:(UIImage*)picture {
    self = [super initPacketForBroadcast]; if (!self) return nil;
    [self commonChatInit];
    
    _messagePictureImage = picture;
    _messagePictureWidth = picture.size.width;
    _messagePictureHeight = picture.size.height;
    _messageType = CTChatMessageTypePicture;
    return self;
}

-(instancetype)initMessageAudioWithAudioData:(NSData*)audioData
                                withDuration:(NSTimeInterval)durationInSeconds {
    assert(audioData);
    self = [super initPacketForBroadcast]; if (!self) return nil;
    [self commonChatInit];

    _messageAudioDuration = durationInSeconds;
    _messageDataPacket = audioData;
    _messageType = CTChatMessageTypeAudio;
    return self;
}


-(instancetype)initMessageDrawingWithDrawingData:(NSData*)drawingData
                     withImageRepresentationData:(NSData*)drawingImage
                                     withMessage:(NSString*)message {
    self = [super initPacketForBroadcast]; if (!self) return nil;
    [self commonChatInit];

    _messageTextContent = message;
//    _messageData = drawingImage;
    _messageType = CTChatMessageTypeDrawing;
    return self;
}


-(instancetype)initChatPacketInboundMediaFilePath:(NSString*)filePath
                                     withProgress:(NSProgress*)progress
                                andSenderRecorder:(CTBasePeer*)sender {
   
    _progress = progress;
    _messageResourceName = filePath;
    return self;

}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    assert(self.packetDirection == CTPacketDirectionSend);
    [aCoder encodeInteger:self.messageType forKey:kCTPacketChatMessageTypeKey];
    [aCoder encodeObject:self.messageSentTime forKey:kCTPacketChatMessageSentTimeKey];
    
    [aCoder encodeObject:self.messageTextContent forKey:kCTPacketChatMessageTextContentKey];
    
    if (self.messageType == CTChatMessageTypePicture) {
        assert(self.messagePictureImage);
        self.messageDataPacket = UIImageJPEGRepresentation(self.messagePictureImage, 0.7);
    }
    
    [aCoder encodeObject:self.messageDataPacket forKey:kCTPacketChatMessageDataPacketKey];
    [aCoder encodeFloat:self.messageAudioDuration forKey:kCTPacketChatMessageAudioDurationKey];
    [aCoder encodeFloat:self.messagePictureWidth forKey:kCTPacketChatMessagePictureWidthKey];
    [aCoder encodeFloat:self.messagePictureHeight forKey:
kCTPacketChatMessagePictureHeightKey];

    [aCoder encodeObject:self.messageResourceName forKey:kCTPacketChatMessageResourceNameKey];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder]; if (!self) return nil;
    [self commonChatInit];
    _messageType = (CTChatMessageType) [aDecoder decodeIntegerForKey:kCTPacketChatMessageTypeKey];
    _messageSentTime = [aDecoder decodeObjectForKey:kCTPacketChatMessageSentTimeKey];
    _messageTextContent = [aDecoder decodeObjectForKey:kCTPacketChatMessageTextContentKey];

    _messageDataPacket = [aDecoder decodeObjectForKey:kCTPacketChatMessageDataPacketKey];
    _messageAudioDuration = [aDecoder decodeFloatForKey:kCTPacketChatMessageAudioDurationKey];
    _messagePictureWidth = [aDecoder decodeFloatForKey:kCTPacketChatMessagePictureWidthKey];
    _messagePictureHeight = [aDecoder decodeFloatForKey:kCTPacketChatMessagePictureHeightKey];
    
    _messageResourceName = [aDecoder decodeObjectForKey:kCTPacketChatMessageResourceNameKey];
    return self;
}

#pragma mark - NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
    CTPacketChat*packet = [super copyWithZone:zone];
    packet.messageType = self.messageType;
    packet.messageSentTime = self.messageSentTime.copy;
    
    packet.messageTextContent = self.messageTextContent.copy;
    
    packet.messageDataPacket = self.messageDataPacket.copy;
    packet.messageAudioDuration = self.messageAudioDuration;

    packet.messagePictureImage = self.messagePictureImage.copy;
    packet.messagePictureWidth = self.messagePictureWidth;
    packet.messagePictureHeight = self.messagePictureHeight;
    
    packet.messageResourceName = self.messageResourceName.copy;
    return packet;
}


#pragma mark - Data Representations

-(UIBezierPath*)messageDrawingPath {
    if (self.messageType == CTChatMessageTypeDrawing) {
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:self.messageDataPacket];
        if (object && [object isMemberOfClass:UIBezierPath.class])
            return object;
    }
    return nil;
}

@end
