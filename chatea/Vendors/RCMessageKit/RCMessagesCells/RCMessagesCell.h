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

#import "RCMessages.h"
#import "RCMessagesView.h"

@interface RCMessagesCell : UITableViewCell

@property (strong, nonatomic) RCMessage *rcmessage;

#pragma mark -

@property (strong, nonatomic) UILabel *labelCellHeader;
@property (strong, nonatomic) UILabel *labelBubbleHeader;

@property (strong, nonatomic) UIView *viewBubble;

@property (strong, nonatomic) UIImageView *imageAvatar;
@property (strong, nonatomic) UILabel *labelAvatar;

@property (strong, nonatomic) UILabel *labelBubbleFooter;
@property (strong, nonatomic) UILabel *labelCellFooter;

#pragma mark -

- (void)bindData:(NSIndexPath *)indexPath messagesView:(RCMessagesView*)messagesView;

- (void)layoutSubviews:(CGSize)size;

+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView size:(CGSize)size;

@end
