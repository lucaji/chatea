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
//  CTPictureViewController.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 15/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//



#import "CTPictureViewController.h"
#import "CTPhotoItem.h"

@interface CTPictureViewController()
{
	BOOL isMessages;
	BOOL statusBarIsHidden;
}
@end


@implementation CTPictureViewController


- (id)initWith:(UIImage *)picture

{
	isMessages = NO;
	
	CTPhotoItem *photoItem = [[CTPhotoItem alloc] init];
	
	photoItem.image = picture;
	
	self = [super initWithPhotos:@[photoItem]];
	
	return self;
}


- (id)initWith:(NSString *)objectId chatId:(NSString *)chatId

{
//	isMessages = YES;
//	
//	CTPhotoItem *initialPhoto;
//	NSMutableArray *photoItems = [[NSMutableArray alloc] init];
//	
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@ AND type == %@ AND isDeleted == NO", chatId, MESSAGE_PICTURE];
//	RLMResults *dbmessages = [[DBMessage objectsWithPredicate:predicate] sortedResultsUsingKeyPath:FMESSAGE_CREATEDAT ascending:YES];
//	
//	NSDictionary *attributesTitle = @{NSForegroundColorAttributeName:[UIColor whiteColor],
//									 NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
//	
//	NSDictionary *attributesCredit = @{NSForegroundColorAttributeName:[UIColor grayColor],
//									   NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]};
//	
//	for (DBMessage *dbmessage in dbmessages)
//	{
//		NSString *path = [DownloadManager pathImage:dbmessage.picture];
//		if (path != nil)
//		{
//			NSString *title = dbmessage.senderName;
//			//-------------------------------------------------------------------------------------------------------------------------------------
//			NSDate *date = [NSDate dateWithTimestamp:dbmessage.createdAt];
//			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//			[dateFormatter setDateFormat:@"dd MMMM, HH:mm"];
//			NSString *credit = [dateFormatter stringFromDate:date];
//			//-------------------------------------------------------------------------------------------------------------------------------------
//			CTPhotoItem *photoItem = [[CTPhotoItem alloc] init];
//			photoItem.image = [[UIImage alloc] initWithContentsOfFile:path];
//			photoItem.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:title attributes:attributesTitle];
//			photoItem.attributedCaptionCredit = [[NSAttributedString alloc] initWithString:credit attributes:attributesCredit];
//			photoItem.objectId = dbmessage.objectId;
//			//-------------------------------------------------------------------------------------------------------------------------------------
//			if ([dbmessage.objectId isEqualToString:objectId]) initialPhoto = photoItem;
//			//-------------------------------------------------------------------------------------------------------------------------------------
//			[photoItems addObject:photoItem];
//		}
//	}
//	
//	self = [super initWithPhotos:photoItems initialPhoto:initialPhoto delegate:nil];
	
	return nil;
}


- (void)viewDidLoad

{
	[super viewDidLoad];
	
	statusBarIsHidden = [UIApplication sharedApplication].isStatusBarHidden;
	
	if (isMessages)
	{
		UIBarButtonItem *buttonMore = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self
																					action:@selector(actionMore)];
		UIBarButtonItem *buttonDelete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self
																					  action:@selector(actionDelete)];
		self.rightBarButtonItems = @[buttonMore, buttonDelete];
	}
	else self.rightBarButtonItem = nil;
	
	[self updateOverlayViewConstraints];
}


- (BOOL)prefersStatusBarHidden

{
	return statusBarIsHidden;
}


- (UIStatusBarStyle)preferredStatusBarStyle

{
	return UIStatusBarStyleLightContent;
}

#pragma mark - Initialization methods


- (void)updateOverlayViewConstraints

{
	for (NSLayoutConstraint *constraint in self.overlayView.constraints)
	{
		if ([constraint.firstItem isKindOfClass:[UINavigationBar class]])
		{
			if (constraint.firstAttribute == NSLayoutAttributeTop)
			{
				constraint.constant = 20;
			}
		}
	}
}

#pragma mark - User actions


- (void)actionMore

{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	[alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionSave]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Forward" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionForward]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionShare]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - User actions (save)


- (void)actionSave

{
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
}

#pragma mark - User actions (forward)


- (void)actionForward

{
}

#pragma mark - SelectUsersDelegate


- (void)didSelectUsers:(NSMutableArray *)users groups:(NSMutableArray *)groups

{
}

#pragma mark - User actions (share)


- (void)actionShare

{
}

#pragma mark - User actions (delete)


- (void)actionDelete

{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	[alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self actionDeletePhoto]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	
	[self presentViewController:alert animated:YES completion:nil];
}


- (void)actionDeletePhoto

{
}

@end
