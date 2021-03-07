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

#import "RCMessagesAudioCell.h"

@interface RCMessagesAudioCell() {
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end


@implementation RCMessagesAudioCell

@synthesize imageStatus, labelDuration, spinner, imageManual;


- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_ {
	indexPath = indexPath_;
	messagesView = messagesView_;
	
//    RCMessage *rcmessage = [messagesView rcmessage:indexPath];

	[super bindData:indexPath messagesView:messagesView];
	
    /// Handle bubbcle color customization
    if (self.rcmessage.bubble_backcolor) {
        self.viewBubble.backgroundColor = self.rcmessage.bubble_backcolor;
    } else {
        self.viewBubble.backgroundColor = self.rcmessage.incoming ? [RCMessages textBubbleColorIncoming] : [RCMessages textBubbleColorOutgoing];
    }
    
	if (imageStatus == nil){
		imageStatus = [[UIImageView alloc] init];
		[self.viewBubble addSubview:imageStatus];
	}
	
	if (labelDuration == nil) {
		labelDuration = [[UILabel alloc] init];
		labelDuration.font = [RCMessages audioFont];
		labelDuration.textAlignment = NSTextAlignmentRight;
		[self.viewBubble addSubview:labelDuration];
	}
	
	if (spinner == nil) {
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self.viewBubble addSubview:spinner];
	}
	
	if (imageManual == nil) {
		imageManual = [[UIImageView alloc] initWithImage:[RCMessages audioImageManual]];
		[self.viewBubble addSubview:imageManual];
	}

	labelDuration.textColor = self.rcmessage.incoming ? [RCMessages audioTextColorIncoming] : [RCMessages audioTextColorOutgoing];
	
	if (self.rcmessage.audio_duration < 60)
		labelDuration.text = [NSString stringWithFormat:@"0:%02ld", (long) self.rcmessage.audio_duration];
	else labelDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long) self.rcmessage.audio_duration / 60, (long) self.rcmessage.audio_duration % 60];
	
    if (self.rcmessage.status == RC_STATUS_LOADING) {
        imageStatus.hidden = YES;
        labelDuration.hidden = YES;
        [spinner startAnimating];
        imageManual.hidden = YES;
    }
    
    if (self.rcmessage.status == RC_STATUS_SUCCEED) {
        imageStatus.hidden = NO;
        labelDuration.hidden = NO;
        [spinner stopAnimating];
        imageManual.hidden = YES;
    }
    
    if (self.rcmessage.status == RC_STATUS_MANUAL) {
        imageStatus.hidden = YES;
        labelDuration.hidden = YES;
        [spinner stopAnimating];
        imageManual.hidden = NO;
    }
    
    [self updateStatus];
    
    self.tintColor = [UIColor darkTextColor];
}

-(void)updateStatus {
    if (self.rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED) imageStatus.image = [RCMessages audioImagePlay];
    if (self.rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING) imageStatus.image = [RCMessages audioImagePause];
}


- (void)layoutSubviews {
	CGSize size = [RCMessagesAudioCell size:indexPath messagesView:messagesView];
	
	[super layoutSubviews:size];
	
	CGFloat widthStatus = imageStatus.image.size.width;
	CGFloat heightStatus = imageStatus.image.size.height;
	CGFloat yStatus = (size.height - heightStatus) / 2;
	imageStatus.frame = CGRectMake(10, yStatus, widthStatus, heightStatus);
	
	labelDuration.frame = CGRectMake(size.width - 100, 0, 90, size.height);
	
	CGFloat widthSpinner = spinner.frame.size.width;
	CGFloat heightSpinner = spinner.frame.size.height;
	CGFloat xSpinner = (size.width - widthSpinner) / 2;
	CGFloat ySpinner = (size.height - heightSpinner) / 2;
	spinner.frame = CGRectMake(xSpinner, ySpinner, widthSpinner, heightSpinner);
	
	CGFloat widthManual = imageManual.image.size.width;
	CGFloat heightManual = imageManual.image.size.height;
	CGFloat xManual = (size.width - widthManual) / 2;
	CGFloat yManual = (size.height - heightManual) / 2;
	imageManual.frame = CGRectMake(xManual, yManual, widthManual, heightManual);
}

#pragma mark - Size methods


+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView{
	CGSize size = [self size:indexPath messagesView:messagesView];
	return [RCMessagesCell height:indexPath messagesView:messagesView size:size];
}


+ (CGSize)size:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView {
	return CGSizeMake([RCMessages audioBubbleWidht], [RCMessages audioBubbleHeight]);
}

-(void)audioCellUserDidTap {
    if (self.rcmessage.status == RC_STATUS_MANUAL) {
        // [MediaLoader loadAudioManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
        // [self.tableView reloadData];
    } else if (self.rcmessage.status == RC_STATUS_SUCCEED) {
        if (self.rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED) {
            self.rcmessage.audio_status = RC_AUDIOSTATUS_PLAYING;

            [[CTChatAudioPlayerRecorder singleton] speakChatMessageData:self.rcmessage.message_data withCompletion:^{
                self.rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
                [self updateStatus];
            }];
        } else if (self.rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING) {
            [[CTChatAudioPlayerRecorder singleton] stopPlaying];
            self.rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
        }
    }
    [self updateStatus];
}

- (void)playDidStart {
    self.rcmessage.audio_status = RC_AUDIOSTATUS_PLAYING;
    [self updateStatus];
}

- (void)playDidStop {
    self.rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
    [self updateStatus];
}

-(void)dealloc {
    
    self.rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
}

@end
