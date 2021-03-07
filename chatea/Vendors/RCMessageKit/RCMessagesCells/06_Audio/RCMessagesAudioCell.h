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
#import "CTChatAudioPlayerRecorder.h"


@interface RCMessagesAudioCell : RCMessagesCell <CTChatAudioPlayingDelegate>


@property (strong, nonatomic) UIImageView *imageStatus;
@property (strong, nonatomic) UILabel *labelDuration;
@property (strong, nonatomic) UIImageView *imageManual;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

- (void)bindData:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView;

+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView;

-(void)audioCellUserDidTap;

@end