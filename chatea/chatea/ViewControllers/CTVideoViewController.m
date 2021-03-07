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
//  CTVideoViewController.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 15/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//




#import "CTVideoViewController.h"
@import AVKit;
@import AVFoundation;


@interface CTVideoViewController()
{
	NSURL *url;
	AVPlayerViewController *controller;
}
@end


@implementation CTVideoViewController


- (id)initWith:(NSURL *)url_

{
	self = [super init];
	
	url = url_;
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDone) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated

{
	[super viewWillAppear:animated];
	
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
	
	controller = [[AVPlayerViewController alloc] init];
	controller.player = [AVPlayer playerWithURL:url];
	[controller.player play];
	
	[self addChildViewController:controller];
	[self.view addSubview:controller.view];
	controller.view.frame = self.view.frame;
}


- (void)viewWillDisappear:(BOOL)animated

{
	[super viewWillDisappear:animated];
	
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - User actions


- (void)actionDone

{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
