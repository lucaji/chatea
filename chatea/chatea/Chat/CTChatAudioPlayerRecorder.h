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
//  CTChatAudioRecordingDelegate.h
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 19/05/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTChatAudioRecordingDelegate
-(void)recordingTimeUpdated:(NSTimeInterval)time formattedTime:(NSString*)formattedDuration;
@end

@protocol CTChatAudioPlayingDelegate

-(void)playDidStart;
-(void)playDidStop;

@optional
-(void)playingTimeUpdated:(NSTimeInterval)time formattedTime:(NSString*)time;
@end

/// Notifications
extern NSString * const kWCChatMessageAudioMessageDidStartPlayingNotification;
extern NSString * const kWCChatMessageAudioMessageDidStopPlayingNotification;
extern NSString * const kWCChatMessageAudioRecordDidStartNotification;
extern NSString * const kWCChatMessageAudioRecordDidStopNotification;

typedef NS_ENUM(NSInteger, WCSpeakerphoneSetting) {
    WCSpeakerphoneSettingOff = 0,
    WCSpeakerphoneSettingNormal,
    WCSpeakerphoneSettingLoud
};


@interface CTChatAudioPlayerRecorder : NSObject

@property (nonatomic, weak) id<CTChatAudioRecordingDelegate>chatRecordingDelegate;
@property (nonatomic, weak) id<CTChatAudioPlayingDelegate>chatPlayingCellDelegate;

@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) BOOL isPlaying;

-(void)speakerModeDefault;
-(void)speakerModeOff;
-(void)speakerModeNormal;

@property (nonatomic, readonly) WCSpeakerphoneSetting speakerphoneMode;
-(void)persistSpeakerphoneMode:(WCSpeakerphoneSetting)speakerphoneMode;

+(instancetype)singleton;

-(nullable NSError*)chooseDefaultInputDeviceWithName:(NSString*)defaultInputDeviceName storeAsDefault:(BOOL)persist;

-(BOOL)startRecordChatMessage;
-(void)stopRecordVoice:(BOOL)sending;

-(BOOL)speakChatMessageData:(NSData *)songData withCompletion:(nullable dispatch_block_t)completion;

//-(void)playSoundPath:(NSString*)path withCompletion:(nullable dispatch_block_t)completion;

-(void)stopPlaying;


@end

NS_ASSUME_NONNULL_END
