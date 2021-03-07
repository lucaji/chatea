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

#import "RCMessagesLocationCell.h"


@interface RCMessagesLocationCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end


@implementation RCMessagesLocationCell

@synthesize imageView, spinner;


- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_

{
	indexPath = indexPath_;
	messagesView = messagesView_;
	
//    RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	

	
	[super bindData:indexPath messagesView:messagesView];
	
	self.viewBubble.backgroundColor = self.rcmessage.incoming ? [RCMessages locationBubbleColorIncoming] : [RCMessages locationBubbleColorOutgoing];
	

	
	if (imageView == nil)
	{
		imageView = [[UIImageView alloc] init];
		imageView.layer.masksToBounds = YES;
		imageView.layer.cornerRadius = [RCMessages bubbleRadius];
		[self.viewBubble addSubview:imageView];
	}
	
	if (spinner == nil)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self.viewBubble addSubview:spinner];
	}
	

	
	if (self.rcmessage.status == RC_STATUS_LOADING)
	{
		imageView.image = nil;
		[spinner startAnimating];
	}
	
	if (self.rcmessage.status == RC_STATUS_SUCCEED)
	{
		imageView.image = self.rcmessage.location_thumbnail;
		[spinner stopAnimating];
	}
	
}


- (void)layoutSubviews

{
	CGSize size = [RCMessagesLocationCell size:indexPath messagesView:messagesView];
	
	[super layoutSubviews:size];
	
	imageView.frame = CGRectMake(0, 0, size.width, size.height);
	
	CGFloat widthSpinner = spinner.frame.size.width;
	CGFloat heightSpinner = spinner.frame.size.height;
	CGFloat xSpinner = (size.width - widthSpinner) / 2;
	CGFloat ySpinner = (size.height - heightSpinner) / 2;
	spinner.frame = CGRectMake(xSpinner, ySpinner, widthSpinner, heightSpinner);
}

#pragma mark - Size methods


+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	CGSize size = [self size:indexPath messagesView:messagesView];
	return [RCMessagesCell height:indexPath messagesView:messagesView size:size];
}


+ (CGSize)size:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView

{
	return CGSizeMake([RCMessages locationBubbleWidth], [RCMessages locationBubbleHeight]);
}

@end
