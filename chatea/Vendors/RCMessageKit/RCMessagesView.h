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

#import "RCMessage.h"
#import "RCMenuItem.h"

@class GADBannerView;

@interface RCMessagesView : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle1;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle2;
@property (weak, nonatomic) IBOutlet UIButton *buttonTitle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *viewLoadEarlier;
@property (weak, nonatomic) IBOutlet UIView *viewTypingIndicator;

@property (weak, nonatomic) IBOutlet UIView *viewInput;
@property (weak, nonatomic) IBOutlet UIButton *buttonInputAttach;
@property (weak, nonatomic) IBOutlet UIButton *buttonInputAudio;
@property (weak, nonatomic) IBOutlet UIButton *buttonInputSend;
@property (weak, nonatomic) IBOutlet UITextView *textInput;
@property (weak, nonatomic) IBOutlet UIView *viewInputAudio;
@property (weak, nonatomic) IBOutlet UILabel *labelInputAudio;

#pragma mark - Load earlier methods

- (void)loadEarlierShow:(BOOL)show;

#pragma mark - Message methods

- (RCMessage *)rcmessage:(NSIndexPath *)indexPath;

#pragma mark - Avatar methods

- (NSString *)avatarInitials:(NSIndexPath *)indexPath;
- (UIImage *)avatarImage:(NSIndexPath *)indexPath;

#pragma mark - Header, Footer methods

- (NSString *)textCellHeader:(NSIndexPath *)indexPath;
- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath;
- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath;
- (NSString *)textCellFooter:(NSIndexPath *)indexPath;

#pragma mark - Menu controller methods

- (NSArray *)menuItems:(NSIndexPath *)indexPath;

#pragma mark - Typing indicator methods

- (void)typingIndicatorShow:(BOOL)show animated:(BOOL)animated;

#pragma mark - User actions (cell tap)

- (void)actionTapCell:(NSIndexPath *)indexPath;

#pragma mark - User actions (bubble tap)

- (void)actionTapBubble:(NSIndexPath *)indexPath;

#pragma mark - User actions (avatar tap)

- (void)actionTapAvatar:(NSIndexPath *)indexPath;

#pragma mark - Helper methods

- (void)scrollToBottom:(BOOL)animated;

@end
