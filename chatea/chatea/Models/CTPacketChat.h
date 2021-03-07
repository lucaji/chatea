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
//  CTPacketChat.h
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 27/04/2017.
//  Updated by lucaji on 04/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//

#import "CTPacket.h"

typedef NS_ENUM(NSInteger, CTChatMessageType) {
    CTChatMessageTypeUndefined = 0,
    CTChatMessageTypeText,
    CTChatMessageTypeAudio,
    CTChatMessageTypePicture,
    CTChatMessageTypeDrawing,
    CTChatMessageTypeResource,
    CTChatMessageTypeService,
    CTChatMessageTypeEmoji,
    CTChatMessageTypeVideo,
    CTChatMessageTypeLocation
};




/// Dictionary properties keys
extern NSString * const kCTPacketChatMessageTypeKey;
extern NSString * const kCTPacketChatMessageSentTimeKey;
extern NSString * const kCTPacketChatMessageTextContentKey;
extern NSString * const kCTPacketChatMessageDataPacketKey;
extern NSString * const kCTPacketChatMessageAudioDurationKey;
extern NSString * const kCTPacketChatMessagePictureWidthKey;
extern NSString * const kCTPacketChatMessagePictureHeightKey;
extern NSString * const kCTPacketChatMessageResourceNameKey;

@interface CTPacketChat : CTPacket

/// Properties in dictionary (exported)
@property (nonatomic, assign) CTChatMessageType messageType;

@property (nonatomic, strong) NSDate *messageSentTime;

@property (nonatomic, copy) NSString *messageTextContent;

@property (nonatomic, copy) NSData *messageDataPacket;
@property (nonatomic, assign) NSTimeInterval messageAudioDuration;

@property (nonatomic) CGFloat messagePictureWidth;
@property (nonatomic) CGFloat messagePictureHeight;
/// Resource Transfer
@property (nonatomic) NSString *messageResourceName;

/// Runtime Properties
@property (nonatomic, strong) UIImage *messagePictureImage;

/// Resource transfer progress
@property (readonly, nonatomic) NSProgress *progress;


/// OUTBOUND CONSTRUCTORS
-(instancetype)initServiceMessage:(NSString*)servicemessage;

-(instancetype)initMessageTextWithMessage:(NSString*)message;


-(instancetype)initMessageWithImage:(UIImage*)picture;


-(instancetype)initMessageAudioWithAudioData:(NSData*)audioData
                                withDuration:(NSTimeInterval)durationInSeconds;

-(instancetype)initMessageDrawingWithDrawingData:(NSData*)drawingData
                     withImageRepresentationData:(NSData*)drawingImage
                                     withMessage:(NSString*)message;

//-(instancetype)initMessagePictureWithPictureData:(NSData*)pictureData
//                                     withMessage:(NSString*)message;



-(UIBezierPath*)messageDrawingPath;



@end
