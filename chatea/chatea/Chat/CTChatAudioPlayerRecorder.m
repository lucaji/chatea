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
//  SRTLocalRecorder+ChatVoiceRecorder.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 19/05/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//



#import "CTChatAudioPlayerRecorder.h"
#import "CTNetworkManager.h"

NSString * const kWCPreferences_SpeakerphoneMode = @"speakerphoneMode";
NSString * const kWCPreferences_AudioDefaultInputDeviceName = @"defaultInputDeviceName";

@import AVFoundation;

@interface CTChatAudioPlayerRecorder ()
<AVAudioRecorderDelegate,
AVAudioPlayerDelegate>

@property (nonatomic, readwrite) WCSpeakerphoneSetting speakerphoneMode;

@property (nonatomic) NSTimer *recordTimer;
@property (nonatomic, readwrite) BOOL isRecording;
@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic) NSDate* dateAudioStart;

@property (nonatomic) AVAudioRecorder *audioRecorder;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) AVAudioSession *audioSession;

@property (nonatomic, copy) dispatch_block_t completionBlock;
@end

NSString * const kWCChatMessageAudioMessageDidStartPlayingNotification = @"org.lucaji.chatea.kWCChatMessageAudioMessageDidStartPlayingNotification";
NSString * const kWCChatMessageAudioMessageDidStopPlayingNotification = @"org.lucaji.chatea.kWCChatMessageAudioMessageDidStopPlayingNotification";
NSString * const kWCChatMessageAudioRecordDidStartNotification = @"org.lucaji.chatea.kWCChatMessageAudioRecordDidStartNotification";
NSString * const kWCChatMessageAudioRecordDidStopNotification = @"org.lucaji.chatea.kWCChatMessageAudioRecordDidStopNotification";


@implementation CTChatAudioPlayerRecorder

-(void)speakerModeNormal {
    self.speakerphoneMode = WCSpeakerphoneSettingNormal;
}

-(void)speakerModeOff {
    self.speakerphoneMode = WCSpeakerphoneSettingOff;
}

-(void)speakerModeDefault {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    self.speakerphoneMode = (WCSpeakerphoneSetting)[defaults integerForKey:kWCPreferences_SpeakerphoneMode];
}

-(void)setSpeakerphoneMode:(WCSpeakerphoneSetting)speakerphoneMode {
    if (_speakerphoneMode == speakerphoneMode) { return; }
    _speakerphoneMode = speakerphoneMode;
    __autoreleasing NSError *sessionError = nil;
    switch (speakerphoneMode) {
        case WCSpeakerphoneSettingOff:
            [self.audioSession setActive:NO error:&sessionError];
            return;
        case WCSpeakerphoneSettingLoud:
            [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError];
            break;
        default:
            [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&sessionError];
            break;
    }
    if (sessionError) {
        sessionError = nil;
        [self.audioSession setActive:YES error:&sessionError];
        [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&sessionError];
        _speakerphoneMode = WCSpeakerphoneSettingNormal;
        
        if (sessionError) {
            NSString*logString = [NSString stringWithFormat:@"Audio error: %@", sessionError.localizedDescription];
            NSLog(@"%@", logString);
        }
        //        [self addLogMessage:logString withLogLevel:SRTLoggingLevelError];
    }
    [self.audioSession setActive:YES error:&sessionError];

}

-(void)persistSpeakerphoneMode:(WCSpeakerphoneSetting)speakerphoneMode {
    self.speakerphoneMode = speakerphoneMode;
    NSUserDefaults*defaults = NSUserDefaults.standardUserDefaults;
    [defaults setInteger:speakerphoneMode forKey:kWCPreferences_SpeakerphoneMode];
    [defaults synchronize];
}


+(instancetype)singleton {
    static CTChatAudioPlayerRecorder *_sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMyManager = [[self alloc] init];
    });
    return _sharedMyManager;
}

-(instancetype)init {
    self = [super init]; if (!self) return nil;
    self.recordTimer = nil;
    self.audioRecorder = nil;
    self.audioPlayer = nil;
    self.completionBlock = nil;
    
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults registerDefaults:@{ kWCPreferences_SpeakerphoneMode:@(WCSpeakerphoneSettingNormal) }];
    
    self.audioSession = AVAudioSession.sharedInstance;
    
    __autoreleasing NSError*sessionError = nil;
    if (@available(iOS 10.0, *)) {
        [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                                              mode:AVAudioSessionModeVoiceChat
                                           options:AVAudioSessionCategoryOptionAllowBluetooth error:&sessionError];
    } else {
        [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    }
    if (sessionError) {
        NSString*logString = [NSString stringWithFormat:@"%@", sessionError.localizedDescription];
        NSLog(@"%@", logString);
        //        [self addLogMessage:logString withLogLevel:SRTLoggingLevelError];
    }
    
    NSString*defaultInputDeviceName = [defaults objectForKey:kWCPreferences_AudioDefaultInputDeviceName];
    NSLog(@"choosing default input device name = %@",defaultInputDeviceName);
    [self chooseDefaultInputDeviceWithName:defaultInputDeviceName storeAsDefault:defaultInputDeviceName == nil];

    [self.audioSession setActive:YES error:&sessionError];

    
    [self speakerModeDefault];

    return self;
}

-(NSError*)chooseDefaultInputDeviceWithName:(NSString*)defaultInputDeviceName storeAsDefault:(BOOL)persist {
    NSArray<AVAudioSessionPortDescription*>* inputs = AVAudioSession.sharedInstance.availableInputs;
    AVAudioSessionPortDescription*defaultInput = inputs.firstObject;
    if (defaultInputDeviceName) {
        for (AVAudioSessionPortDescription*input in inputs) {
            if ([input.portName isEqualToString:defaultInputDeviceName]) {
                defaultInput = input;
                break;
            }
        }
    }
    __autoreleasing NSError*sessionError = nil;
    [self.audioSession setPreferredInput:defaultInput error:&sessionError];
    if ((defaultInputDeviceName == nil || persist) && sessionError == nil) {
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        [defaults setObject:defaultInput.portName forKey:kWCPreferences_AudioDefaultInputDeviceName];
        [defaults synchronize];
    }
    
    return sessionError;
}

#pragma mark - Audio

-(NSDictionary*)chatRecordingPresetDictionary {
    NSDictionary*preset = @{
                            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                            /*
                             enum {
                             kAudioFormatLinearPCM               = 'lpcm',
                             kAudioFormatAC3                     = 'ac-3',
                             kAudioFormat60958AC3                = 'cac3',
                             kAudioFormatAppleIMA4               = 'ima4',
                             kAudioFormatMPEG4AAC                = 'aac ',
                             kAudioFormatMPEG4CELP               = 'celp',
                             kAudioFormatMPEG4HVXC               = 'hvxc',
                             kAudioFormatMPEG4TwinVQ             = 'twvq',
                             kAudioFormatMACE3                   = 'MAC3',
                             kAudioFormatMACE6                   = 'MAC6',
                             kAudioFormatULaw                    = 'ulaw',
                             kAudioFormatALaw                    = 'alaw',
                             kAudioFormatQDesign                 = 'QDMC',
                             kAudioFormatQDesign2                = 'QDM2',
                             kAudioFormatQUALCOMM                = 'Qclp',
                             kAudioFormatMPEGLayer1              = '.mp1',
                             kAudioFormatMPEGLayer2              = '.mp2',
                             kAudioFormatMPEGLayer3              = '.mp3',
                             kAudioFormatTimeCode                = 'time',
                             kAudioFormatMIDIStream              = 'midi',
                             kAudioFormatParameterValueStream    = 'apvs',
                             kAudioFormatAppleLossless           = 'alac'
                             kAudioFormatMPEG4AAC_HE             = 'aach',
                             kAudioFormatMPEG4AAC_LD             = 'aacl',
                             kAudioFormatMPEG4AAC_ELD            = 'aace',
                             kAudioFormatMPEG4AAC_ELD_SBR        = 'aacf',
                             kAudioFormatMPEG4AAC_HE_V2          = 'aacp',
                             kAudioFormatMPEG4AAC_Spatial        = 'aacs',
                             kAudioFormatAMR                     = 'samr',
                             kAudioFormatAudible                 = 'AUDB',
                             kAudioFormatiLBC                    = 'ilbc',
                             kAudioFormatDVIIntelIMA             = 0x6D730011,
                             kAudioFormatMicrosoftGSM            = 0x6D730031,
                             kAudioFormatAES3                    = 'aes3'
                             };
                             */

                            AVSampleRateKey : @(8000.0f),
                            AVNumberOfChannelsKey : @(1),

                            // LINEAR PCM FORMAT SETTINGS
                            /*
                             NSString *const AVLinearPCMBitDepthKey; // An NSNumber integer that indicates the bit depth for a linear PCM audio format—one of 8, 16, 24, or 32.
                             NSString *const AVLinearPCMIsBigEndianKey; // A Boolean value that indicates whether the audio format is big endian (YES) or little endian (NO).
                             NSString *const AVLinearPCMIsFloatKey; // A Boolean value that indicates that the audio format is floating point (YES) or fixed point (NO).
                             NSString *const AVLinearPCMIsNonInterleavedKey; // A Boolean value that indicates that the audio format is non-interleaved (YES) or interleaved (NO).
                             */

                            // ENCODER SETTINGS
                            AVEncoderAudioQualityKey : @(AVAudioQualityLow),
                            /*
                             enum {
                             AVAudioQualityMin       = 0,
                             AVAudioQualityLow       = 0x20,
                             AVAudioQualityMedium    = 0x40,
                             AVAudioQualityHigh      = 0x60,
                             AVAudioQualityMax       = 0x7F
                             };
                             typedef NSInteger AVAudioQuality;
                             */
                            //AVEncoderBitRateKey : @(0), // An integer that identifies the audio bit rate.
                            //AVEncoderBitRatePerChannelKey : @(1), // An integer that identifies the audio bit rate per channel.


                            AVEncoderBitRateStrategyKey : AVAudioBitRateStrategy_Constant, // The value is an AVAudioBitRateStrategy constant.
                            /*
                             AVAudioBitRateStrategy_Constant;
                             AVAudioBitRateStrategy_LongTermAverage;
                             AVAudioBitRateStrategy_VariableConstrained;
                             AVAudioBitRateStrategy_Variable;
                             */
                            //AVEncoderBitDepthHintKey : @(8), // An integer ranging from 8 through 32.

                            // SAMPLE RATE CONVERTER
                            AVSampleRateConverterAudioQualityKey : @(AVAudioQualityMedium),
                            /*
                             enum {
                             AVAudioQualityMin       = 0,
                             AVAudioQualityLow       = 0x20,
                             AVAudioQualityMedium    = 0x40,
                             AVAudioQualityHigh      = 0x60,
                             AVAudioQualityMax       = 0x7F
                             };
                             typedef NSInteger AVAudioQuality;
                             */


                            AVEncoderAudioQualityForVBRKey : @(AVAudioQualityMedium),
                            /*
                             enum {
                             AVAudioQualityMin       = 0,
                             AVAudioQualityLow       = 0x20,
                             AVAudioQualityMedium    = 0x40,
                             AVAudioQualityHigh      = 0x60,
                             AVAudioQualityMax       = 0x7F
                             };
                             typedef NSInteger AVAudioQuality;
                             */

                            AVSampleRateConverterAlgorithmKey : AVSampleRateConverterAlgorithm_Normal,
                            /*
                             AVSampleRateConverterAlgorithm_Normal;
                             AVSampleRateConverterAlgorithm_Mastering;
                             */

                            };
    return preset;
}

-(NSDictionary*)audioRecordingPresetDictionaryHighLossless:(BOOL)losslessFlag {
    NSDictionary*preset = @{ AVFormatIDKey : @(kAudioFormatAppleLossless),
                             AVSampleRateKey : @(48000.0),
                             AVNumberOfChannelsKey : @(2),
                             AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
                             AVSampleRateConverterAlgorithmKey : AVSampleRateConverterAlgorithm_Normal,
                             AVEncoderAudioQualityForVBRKey : @(AVAudioQualityHigh),
                             AVSampleRateConverterAudioQualityKey : @(AVAudioQualityHigh)
                             };
    return preset;
}



-(BOOL)startRecordChatMessage {
    assert(NSThread.isMainThread);
    if (self.audioPlayer.isPlaying) {
        [self stopPlaying];
    }

    if (self.audioRecorder.isRecording) {
        NSLog(@"CTChatAudioPlayerRecorder:recordChat already recording. stopping.");
        [self stopRecordVoice:NO];
        return false;
    }
    __autoreleasing NSError *recorderSetupError = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.chatCafPathURL
                                                settings:self.chatRecordingPresetDictionary
                                                   error:&recorderSetupError];
    self.audioRecorder.delegate = self;

    if (nil == self.audioRecorder) {
        NSString*logString = [NSString stringWithFormat:@"%@", recorderSetupError.localizedDescription];
         NSLog(@"%@", logString);
//        [self addLogMessage:logString withLogLevel:SRTLoggingLevelError];
        return false;
    }
    self.audioRecorder.meteringEnabled = NO;

    [self.audioRecorder prepareToRecord];
    
    self.dateAudioStart = [NSDate date];
    
    if (![self.audioRecorder record]) {
        NSLog(@"could not start recording chat message.");
        return false;
    }
    self.isRecording = YES;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
    return true;
}

- (NSURL *)chatCafPathURL {
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.aac"];
    return [NSURL URLWithString:cafPath];
}


- (void)stopRecordVoice:(BOOL)sending {
    assert(NSThread.isMainThread);
    NSData *voiceData = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.isRecording = NO;

    if (self.audioRecorder && self.audioRecorder.isRecording) {
        [self.audioRecorder stop];

        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.dateAudioStart];
        if (duration >= 1.0 && duration <= 20.0 && sending) {
            NSLog(@"CTChatAudioPlayerRecorder:broadcastingVoiceMessage");
            voiceData = [NSData dataWithContentsOfFile:self.chatCafPathURL.path];
            [CTNetworkManager.singleton broadcastAudioMessage:voiceData withTime:duration];
        }
        [self.audioRecorder deleteRecording];
    }
    self.audioRecorder = nil;
    self.dateAudioStart = nil;
}

-(void)onTick:(NSTimer *)timer {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.dateAudioStart];
    int millisec = (int) (interval * 100) % 100;
    int seconds = (int) interval % 60;
    int minutes = (int) interval / 60;
    NSString*formattedDuration = [NSString stringWithFormat:@"%01d:%02d,%02d", minutes, seconds, millisec];
    if (self.chatRecordingDelegate) {
        [self.chatRecordingDelegate recordingTimeUpdated:interval formattedTime:formattedDuration];
    }
    if (seconds >= 20) {
        [self stopRecordVoice:YES];
    }
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    assert(NSThread.isMainThread);
    [self stopPlaying];
}

-(BOOL)speakChatMessageData:(NSData *)songData withCompletion:(dispatch_block_t)completion {
    assert(NSThread.isMainThread);
    [self stopPlaying];
    if (self.speakerphoneMode == WCSpeakerphoneSettingOff) {
        completion();
        return NO;
    }
    self.completionBlock = completion;
    if (songData && self.audioPlayer == nil) {
        __autoreleasing NSError *playerError = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:songData error:&playerError];
        if (self.audioPlayer) {
            self.audioPlayer.delegate = self;
//            self.player.volume = 1.0f;

            if (![self.audioPlayer play]) {
                return NO;
            }
            self.isPlaying = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kWCChatMessageAudioMessageDidStartPlayingNotification object:nil];
        } else {
            NSString*logString = [NSString stringWithFormat:@"%@", playerError.localizedDescription];
            NSLog(@"%@", logString);
            //            [self addLogMessage:logString withLogLevel:SRTLoggingLevelError];
            return NO;
        }
        return YES;
    }
    return NO;
}


- (void)stopPlaying {
    assert(NSThread.isMainThread);
    if (self.audioPlayer && self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        if (self.completionBlock) {
            self.completionBlock();
        }
        
        if (self.chatPlayingCellDelegate != nil) {
            [self.chatPlayingCellDelegate playDidStop];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kWCChatMessageAudioMessageDidStopPlayingNotification object:nil];
    }
    self.isPlaying = NO;
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    self.completionBlock = nil;
    self.chatPlayingCellDelegate = nil;
}


@end
