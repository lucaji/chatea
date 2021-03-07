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
//  CTSpeakerphoneBarButtonItem.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 09/07/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//


#import "CTSpeakerphoneBarButtonItem.h"
#import "CTChatAudioPlayerRecorder.h"
@import AVFoundation;

@implementation CTSpeakerphoneBarButtonItem

-(instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [super initWithImage:image style:style target:target action:action]; if (!self)return nil;
    [self updateSpeakerphoneIcon];
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self updateSpeakerphoneIcon];
}

-(UIAlertController*)alertControllerForSpeakerphoneBarButtonItem {
    WCSpeakerphoneSetting mode = CTChatAudioPlayerRecorder.singleton.speakerphoneMode;
    NSString*currentModeString = nil;
    switch (mode) {
        case WCSpeakerphoneSettingLoud:
            currentModeString = @"The speakerphone is active.";
            break;
        case WCSpeakerphoneSettingNormal:
            currentModeString = @"The speakerphone is off.";
            break;
        default:
            currentModeString = @"Audio is off.";
            break;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Set the volume"
                                          message:currentModeString
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) {
                                   }];
    [alertController addAction:cancelAction];

    if (mode != WCSpeakerphoneSettingOff) {
        UIAlertAction *offAction = [UIAlertAction
                                    actionWithTitle:@"Silent"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        [CTChatAudioPlayerRecorder.singleton persistSpeakerphoneMode:WCSpeakerphoneSettingOff];
                                        [self updateSpeakerphoneIcon];
                                    }];
        [alertController addAction:offAction];
    }
    if (mode != WCSpeakerphoneSettingNormal) {
        UIAlertAction *normalAction = [UIAlertAction
                                       actionWithTitle:@"Normal"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [CTChatAudioPlayerRecorder.singleton persistSpeakerphoneMode:WCSpeakerphoneSettingNormal];
                                           [self updateSpeakerphoneIcon];
                                       }];
        [alertController addAction:normalAction];
    }
    if (mode != WCSpeakerphoneSettingLoud) {
        UIAlertAction *loudAction = [UIAlertAction
                                     actionWithTitle:@"Speakerphone"
                                     style:UIAlertActionStyleDestructive
                                     handler:^(UIAlertAction *action) {
                                         [CTChatAudioPlayerRecorder.singleton persistSpeakerphoneMode:WCSpeakerphoneSettingLoud];
                                         [self updateSpeakerphoneIcon];
                                     }];
        [alertController addAction:loudAction];
    }

    return alertController;
}

-(void)updateSpeakerphoneIcon {
    switch (CTChatAudioPlayerRecorder.singleton.speakerphoneMode) {
        case WCSpeakerphoneSettingNormal:
            self.image = [UIImage imageNamed:@"speakerphone-low"];
            break;
        case WCSpeakerphoneSettingLoud:
            self.image = [UIImage imageNamed:@"speakerphone"];
            break;
        default:
            self.image = [UIImage imageNamed:@"speakerphone-off"];
            break;
    }

}

@end
