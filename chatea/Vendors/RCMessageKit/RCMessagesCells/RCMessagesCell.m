//
// Copyright (c) 2017 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RCMessagesCell.h"


@interface RCMessagesCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end


@implementation RCMessagesCell

@synthesize labelCellHeader, labelBubbleHeader;
@synthesize viewBubble;
@synthesize imageAvatar, labelAvatar;
@synthesize labelBubbleFooter, labelCellFooter;


- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_ {
	indexPath = indexPath_;
	messagesView = messagesView_;
	
	//RCMessage *
    self.rcmessage = [messagesView rcmessage:indexPath];
	
	self.backgroundColor = [UIColor clearColor];
	
	if (labelCellHeader == nil)	{
		labelCellHeader = [[UILabel alloc] init];
		labelCellHeader.font = [RCMessages cellHeaderFont];
		labelCellHeader.textColor = [RCMessages cellHeaderColor];
		labelCellHeader.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:labelCellHeader];
		[self cellGestureRecognizer];
	}
	
	labelCellHeader.text = [messagesView textCellHeader:indexPath];
		
	if (labelBubbleHeader == nil) {
		labelBubbleHeader = [[UILabel alloc] init];
		labelBubbleHeader.font = [RCMessages bubbleHeaderFont];
		labelBubbleHeader.textColor = [RCMessages bubbleHeaderColor];
		[self.contentView addSubview:labelBubbleHeader];
	}
	
	labelBubbleHeader.textAlignment = self.rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelBubbleHeader.text = [messagesView textBubbleHeader:indexPath];
	

	
	if (viewBubble == nil)
	{
		viewBubble = [[UIView alloc] init];
		viewBubble.layer.cornerRadius = [RCMessages bubbleRadius];
		[self.contentView addSubview:viewBubble];
		[self bubbleGestureRecognizer];
	}
	

	
	if (imageAvatar == nil)
	{
		imageAvatar = [[UIImageView alloc] init];
		imageAvatar.layer.masksToBounds = YES;
		imageAvatar.layer.cornerRadius = [RCMessages avatarDiameter] / 2;
		imageAvatar.backgroundColor = [RCMessages avatarBackColor];
		imageAvatar.userInteractionEnabled = YES;
		[self.contentView addSubview:imageAvatar];
		[self avatarGestureRecognizer];
	}
	
	imageAvatar.image = [messagesView avatarImage:indexPath];
    imageAvatar.tintColor = [UIColor darkTextColor];

	
	if (labelAvatar == nil)
	{
		labelAvatar = [[UILabel alloc] init];
		labelAvatar.font = [RCMessages avatarFont];
		labelAvatar.textColor = [RCMessages avatarTextColor];
		labelAvatar.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:labelAvatar];
	}
	
	labelAvatar.text = (imageAvatar.image == nil) ? [messagesView avatarInitials:indexPath] : nil;
	

	
	if (labelBubbleFooter == nil)
	{
		labelBubbleFooter = [[UILabel alloc] init];
		labelBubbleFooter.font = [RCMessages bubbleFooterFont];
		labelBubbleFooter.textColor = [RCMessages bubbleFooterColor];
		[self.contentView addSubview:labelBubbleFooter];
	}
	
	labelBubbleFooter.textAlignment = self.rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelBubbleFooter.text = [messagesView textBubbleFooter:indexPath];
	

	
	if (labelCellFooter == nil)
	{
		labelCellFooter = [[UILabel alloc] init];
		labelCellFooter.font = [RCMessages cellFooterFont];
		labelCellFooter.textColor = [RCMessages cellFooterColor];
		[self.contentView addSubview:labelCellFooter];
	}
	
	labelCellFooter.textAlignment = self.rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelCellFooter.text = [messagesView textCellFooter:indexPath];
	
}

- (void)layoutSubviews:(CGSize)size
{
	[super layoutSubviews];
//    RCMessage *rcmessage = [messagesView rcmessage:indexPath];

	CGFloat yposition = [RCMessages cellMarginTop];

//    CGFloat widthCellHeader = SCREEN_WIDTH - [RCMessages cellHeaderLeft] - [RCMessages cellHeaderRight];
    CGFloat widthCellHeader = self.contentView.frame.size.width - [RCMessages cellHeaderLeft] - [RCMessages cellHeaderRight];
	CGFloat heightCellHeader = [RCMessagesCell heightCellHeader:indexPath messagesView:messagesView];
	labelCellHeader.frame = CGRectMake([RCMessages cellHeaderLeft], yposition, widthCellHeader, heightCellHeader);
	
	yposition += heightCellHeader;
	

	
//    CGFloat widthBubbleHeader = SCREEN_WIDTH - [RCMessages bubbleHeaderLeft] - [RCMessages bubbleHeaderRight];
    CGFloat widthBubbleHeader = self.contentView.frame.size.width - [RCMessages bubbleHeaderLeft] - [RCMessages bubbleHeaderRight];
	CGFloat heightBubbleHeader = [RCMessagesCell heightBubbleHeader:indexPath messagesView:messagesView];
	labelBubbleHeader.frame = CGRectMake([RCMessages bubbleHeaderLeft], yposition, widthBubbleHeader, heightBubbleHeader);
	
	yposition += heightBubbleHeader;
	

	
    
//    CGFloat xBubble = rcmessage.incoming ? [RCMessages bubbleMarginLeft] : (SCREEN_WIDTH - [RCMessages bubbleMarginRight] - size.width);
    CGFloat xBubble = self.rcmessage.incoming ? [RCMessages bubbleMarginLeft] : (self.contentView.frame.size.width - [RCMessages bubbleMarginRight] - size.width);
	viewBubble.frame = CGRectMake(xBubble, yposition, size.width, size.height);
	
	yposition += size.height;
	

	
	CGFloat diameter = [RCMessages avatarDiameter];
//    CGFloat xAvatar = rcmessage.incoming ? [RCMessages avatarMarginLeft] : (SCREEN_WIDTH - [RCMessages avatarMarginRight] - diameter);
    CGFloat xAvatar = self.rcmessage.incoming ? [RCMessages avatarMarginLeft] : (self.contentView.frame.size.width - [RCMessages avatarMarginRight] - diameter);
	imageAvatar.frame = CGRectMake(xAvatar, yposition - diameter, diameter, diameter);
	labelAvatar.frame = CGRectMake(xAvatar, yposition - diameter, diameter, diameter);
	

	
//    CGFloat widthBubbleFooter = SCREEN_WIDTH - [RCMessages bubbleFooterLeft] - [RCMessages bubbleFooterRight];
    CGFloat widthBubbleFooter = self.contentView.frame.size.width - [RCMessages bubbleFooterLeft] - [RCMessages bubbleFooterRight];
	CGFloat heightBubbleFooter = [RCMessagesCell heightBubbleFooter:indexPath messagesView:messagesView];
	labelBubbleFooter.frame = CGRectMake([RCMessages bubbleFooterLeft], yposition, widthBubbleFooter, heightBubbleFooter);
	
	yposition += heightBubbleFooter;
	

	
//    CGFloat widthCellFooter = SCREEN_WIDTH - [RCMessages cellFooterLeft] - [RCMessages cellFooterRight];
    CGFloat widthCellFooter = self.contentView.frame.size.width - [RCMessages cellFooterLeft] - [RCMessages cellFooterRight];
	CGFloat heightCellFooter = [RCMessagesCell heightCellFooter:indexPath messagesView:messagesView];
	labelCellFooter.frame = CGRectMake([RCMessages cellFooterLeft], yposition, widthCellFooter, heightCellFooter);
	
}

#pragma mark - Size methods


+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView size:(CGSize)size

{
	CGFloat heightCellHeader = [self heightCellHeader:indexPath messagesView:messagesView];
	CGFloat heightBubbleHeader = [self heightBubbleHeader:indexPath messagesView:messagesView];
	CGFloat heightBubbleFooter = [self heightBubbleFooter:indexPath messagesView:messagesView];
	CGFloat heightCellFooter = [self heightCellFooter:indexPath messagesView:messagesView];
	
	return [RCMessages cellMarginTop] + heightCellHeader + heightBubbleHeader + size.height +
															heightBubbleFooter + heightCellFooter + [RCMessages cellMarginBottom];
}


+ (CGFloat)heightCellHeader:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	return ([messagesView textCellHeader:indexPath] != nil) ? [RCMessages cellHeaderHeight] : 0;
}


+ (CGFloat)heightBubbleHeader:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	return ([messagesView textBubbleHeader:indexPath] != nil) ? [RCMessages bubbleHeaderHeight] : 0;
}


+ (CGFloat)heightBubbleFooter:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	return ([messagesView textBubbleFooter:indexPath] != nil) ? [RCMessages bubbleFooterHeight] : 0;
}


+ (CGFloat)heightCellFooter:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	return ([messagesView textCellFooter:indexPath] != nil) ? [RCMessages cellFooterHeight] : 0;
}

#pragma mark - Gesture recognizer methods


- (void)cellGestureRecognizer

{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapCell)];
	[self.contentView addGestureRecognizer:tapGesture];
	tapGesture.cancelsTouchesInView = NO;
}


- (void)bubbleGestureRecognizer

{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapBubble)];
	[self.viewBubble addGestureRecognizer:tapGesture];
	tapGesture.cancelsTouchesInView = NO;
	
	UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongBubble:)];
	[self.viewBubble addGestureRecognizer:longGesture];
}


- (void)avatarGestureRecognizer

{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapAvatar)];
	[self.imageAvatar addGestureRecognizer:tapGesture];
	tapGesture.cancelsTouchesInView = NO;
}

#pragma mark - User actions


- (void)actionTapCell

{
	[messagesView.view endEditing:YES];
	[messagesView actionTapCell:indexPath];
}


- (void)actionTapBubble

{
	[messagesView.view endEditing:YES];
	[messagesView actionTapBubble:indexPath];
}


- (void)actionTapAvatar

{
	[messagesView.view endEditing:YES];
	[messagesView actionTapAvatar:indexPath];
}


- (void)actionLongBubble:(UILongPressGestureRecognizer *)gestureRecognizer

{
	switch (gestureRecognizer.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			[self actionMenu];
			break;
		}
		case UIGestureRecognizerStateChanged:	break;
		case UIGestureRecognizerStateEnded:		break;
		case UIGestureRecognizerStatePossible:	break;
		case UIGestureRecognizerStateCancelled:	break;
		case UIGestureRecognizerStateFailed:	break;
	}
}


- (void)actionMenu

{
	if (![messagesView.textInput isFirstResponder])
	{
		UIMenuController *menuController = [UIMenuController sharedMenuController];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		CGFloat x = viewBubble.frame.origin.x + viewBubble.frame.size.width / 2;
		CGFloat y = viewBubble.frame.origin.y;
		CGRect rect = CGRectMake(x, y, 0, 0);
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[menuController setMenuItems:[messagesView menuItems:indexPath]];
		[menuController setTargetRect:rect inView:self.contentView];
		[menuController setMenuVisible:YES animated:YES];
	}
	else [messagesView.textInput resignFirstResponder];
}

-(void)prepareForReuse {
    self.rcmessage = nil;
    indexPath = nil;
    messagesView = nil;
    [super prepareForReuse];
}

@end
