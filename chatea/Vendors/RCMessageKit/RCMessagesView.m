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

#import "RCMessagesView.h"
#import "RCMessagesStatusCell.h"
#import "RCMessagesTextCell.h"
#import "RCMessagesEmojiCell.h"
#import "RCMessagesPictureCell.h"
#import "RCMessagesVideoCell.h"
#import "RCMessagesAudioCell.h"
#import "RCMessagesLocationCell.h"

#import "CTChatAudioPlayerRecorder.h"
#import "CTNetworkManager.h"
#import "CTPacketChat.h"

#import "CTDrawViewController.h"

#import "CTPictureViewController.h"
#import "CTVideoViewController.h"

@implementation NSDate(Util)

+ (NSDate *)dateWithTimestamp:(long long)timestamp {
    NSTimeInterval interval = (NSTimeInterval) timestamp / 1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

@end

@interface RCMessagesView()
<UIGestureRecognizerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIPopoverPresentationControllerDelegate,
CTChatAudioRecordingDelegate,
DrawViewDelegate>
{
	BOOL initialized;
	CGPoint centerView;
	CGFloat heightView;
    CGFloat widthView; // PR lucaji

//    NSTimer *timerAudio;
//    NSDate *dateAudioStart;
	CGPoint pointAudioStart;

    NSInteger typingCounter;
    BOOL forwarding;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewInputBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewInputHeightConstraint;

@property (assign, nonatomic) long long lastRead;
@property (assign, nonatomic) NSInteger insertCounter;

@property (strong, nonatomic) NSMutableArray<CTPacketChat*> *dbmessages;
@property (strong, nonatomic) NSMutableDictionary *rcmessages;

@property (strong, nonatomic) NSMutableDictionary *avatarInitials;
@property (strong, nonatomic) NSMutableDictionary *avatarImages;
@property (strong, nonatomic) NSMutableArray *avatarIds;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *speakerphoneButton;

@end


@implementation RCMessagesView

@synthesize viewTitle, labelTitle1, labelTitle2, buttonTitle;
@synthesize viewLoadEarlier;
@synthesize viewTypingIndicator;
@synthesize viewInput, buttonInputAttach, buttonInputAudio, buttonInputSend, textInput, viewInputAudio, labelInputAudio;

@synthesize lastRead, insertCounter;
@synthesize dbmessages, rcmessages;
@synthesize avatarInitials, avatarImages, avatarIds;

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
	
	self.navigationItem.titleView = viewTitle;
	
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
        self.bannerHeightConstraint.constant = 90.0;
    }
    
	[self.tableView registerClass:[RCMessagesStatusCell class] forCellReuseIdentifier:@"RCMessagesStatusCell"];
	[self.tableView registerClass:[RCMessagesTextCell class] forCellReuseIdentifier:@"RCMessagesTextCell"];
	[self.tableView registerClass:[RCMessagesEmojiCell class] forCellReuseIdentifier:@"RCMessagesEmojiCell"];
	[self.tableView registerClass:[RCMessagesPictureCell class] forCellReuseIdentifier:@"RCMessagesPictureCell"];
	[self.tableView registerClass:[RCMessagesVideoCell class] forCellReuseIdentifier:@"RCMessagesVideoCell"];
	[self.tableView registerClass:[RCMessagesAudioCell class] forCellReuseIdentifier:@"RCMessagesAudioCell"];
	[self.tableView registerClass:[RCMessagesLocationCell class] forCellReuseIdentifier:@"RCMessagesLocationCell"];
	
	self.tableView.tableHeaderView = viewLoadEarlier;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
	
    [self updateForwardDetails:NO];
    
    self.view.tintColor =
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.87 green:1.0 blue:0.72 alpha:1.0];

	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(audioRecorderGesture:)];
	gesture.minimumPressDuration = 0;
	gesture.cancelsTouchesInView = NO;
	[buttonInputAudio addGestureRecognizer:gesture];
	
	viewInputAudio.hidden = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

	[self inputPanelInit];
    
    NSLog(@"ADDING OBSERVER FOR CHAT MESSAGES");
    [NSNotificationCenter.defaultCenter addObserverForName:kCTNetworkChatMessageReceivedNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                    NSLog(@"Public chat received message notification handler");
                                                    NSDictionary*userInfo = note.userInfo;
                                                    id object = userInfo[kCTNetworkChatMessageReceivedNotificationObjectKey];
                                                    if (object && [object isKindOfClass:CTPacketChat.class])
                                                        [self receivedTranscript:object];
                                                    // if (self.visible)
                                                    //   [self.tableView reloadData];
                                                }];
    
    self.insertCounter = 0;
    
    dbmessages = [NSMutableArray array];
    
    rcmessages = [[NSMutableDictionary alloc] init];
    
    avatarInitials = [[NSMutableDictionary alloc] init];
    avatarImages = [[NSMutableDictionary alloc] init];
    avatarIds = [[NSMutableArray alloc] init];

    [self loadMessages];
    
    CTChatAudioPlayerRecorder.singleton.chatRecordingDelegate = self;
    
    self.title = UIDevice.currentDevice.name;
}

-(void)didReceiveMemoryWarning {
    [self actionClearChat];
    NSString *title = @"Chat Cleared";
    NSString *mess = @"The device was running low on memory: all messages are lost.";
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:mess
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) { }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateForwardDetails:(BOOL)forwarding_ {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    forwarding = forwarding_;
    
//    [self.tableView setEditing:forwarding animated:YES];
    
    self.buttonTitle.userInteractionEnabled = !forwarding;
    
    self.buttonInputAttach.userInteractionEnabled = !forwarding;
    self.buttonInputSend.userInteractionEnabled = !forwarding;
    self.textInput.userInteractionEnabled = !forwarding;
}

#pragma mark - messages repository

- (void)loadMessages {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray<CTPacketChat*>*messages = [NSMutableArray arrayWithArray:CTNetworkManager.singleton.transcripts];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->dbmessages = messages;
        self.insertCounter = messages.count;
        NSLog(@"Loaded %lu messages", (unsigned long)messages.count);
        [self.tableView reloadData];
    });
}

#pragma mark - DBMessage methods

- (NSInteger)index:(NSIndexPath *)indexPath {
    NSInteger count = MIN(insertCounter, [dbmessages count]);
    NSInteger offset = [dbmessages count] - count;
    return (indexPath.row + offset);
}

- (CTPacketChat *)dbmessage:(NSIndexPath *)indexPath {
    NSInteger index = [self index:indexPath];
    return dbmessages[index];
}

- (CTPacketChat *)dbmessageAbove:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
        NSIndexPath *indexAbove = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:0];
        return [self dbmessage:indexAbove];
    }
    return nil;
}

-(void)receivedTranscript:(CTPacketChat *)transcript {
    assert(NSThread.isMainThread);
    [self.dbmessages addObject:transcript];
    self.insertCounter += 1;
    [self refreshTableView1];
}

- (void)refreshTableView1 {
    assert(NSThread.isMainThread);
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self refreshTableView2];
    [self scrollToBottom:YES];
}

- (void)refreshTableView2 {
    assert(NSThread.isMainThread);
    NSLog(@"%s", __PRETTY_FUNCTION__);
    BOOL show = self.insertCounter < [self.dbmessages count];
    [self loadEarlierShow:show];
    [self.tableView reloadData];
}

- (void)messageSend:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audioPath duration:(NSTimeInterval)duration {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self typingIndicatorSave:@NO];
    [self.view endEditing:YES];
    if (picture != nil) {
        [CTNetworkManager.singleton broadcastImageMessage:picture withMessageText:text];
    } else if (audioPath != nil) {
        // already sent by CTChatAudioPlayerRecorder class
//        NSData *voiceData = [NSData dataWithContentsOfFile:audioPath];
//        if (voiceData)
//            [CTNetworkManager.singleton broadcastAudioMessage:voiceData withTime:duration];
    } else {
        [CTNetworkManager.singleton broadcastTextMessage:text];
    }
    
}

-(void)drawviewHasDismissed:(DrawView *)drawingView {
    UIImage*drawViewImage = [drawingView imageRepresentation];
    if (drawViewImage)
        [self messageSend:nil picture:drawViewImage video:nil audio:nil duration:0];
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    [self messageSend:nil picture:picture video:video audio:nil duration:0];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
    [self updateReferenceViews];
	[self inputPanelUpdate];
}

-(void)updateReferenceViews {
    centerView = self.tableView.center;
    heightView = self.tableView.frame.size.height;
    widthView = self.tableView.frame.size.width;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self dismissKeyboard];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!initialized)
	{
		initialized = YES;
		[self scrollToBottom:YES];
	}
	
	[self updateReferenceViews];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
    self.tableView.editing = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidDisappear:animated];
    
    //    [timer invalidate]; timer = nil;
    
//    if ([self isMovingFromParentViewController]) {
//        [self actionCleanup];
//    }
}

-(void)dealloc {
    [self actionCleanup];
}

#pragma mark - Load earlier methods


- (void)loadEarlierShow:(BOOL)show

{
//    viewLoadEarlier.hidden = !show;
//    CGRect frame = viewLoadEarlier.frame;
//    frame.size.height = show ? 50 : 0;
//    viewLoadEarlier.frame = frame;
//    [self.tableView reloadData];
}

#pragma mark - Message methods


- (RCMessage *)rcmessage:(NSIndexPath *)indexPath {
    CTPacketChat *dbmessage = [self dbmessage:indexPath];
    NSString *messageId = dbmessage.packetUniqueId;
    
    if (rcmessages[messageId] == nil) {
        BOOL incoming = (dbmessage.packetDirection == CTPacketDirectionReceive);
        
        
        RCMessage *rcmessage = nil;
        switch (dbmessage.messageType) {
            case CTChatMessageTypeService: {
                rcmessage = [[RCMessage alloc] initWithStatus:dbmessage.messageTextContent];
            } break;
            case CTChatMessageTypeText: {
                NSLog(@"creating new text message %@ inbound: %@", dbmessage.messageTextContent, incoming?@"YES":@"NO");
                
                rcmessage = [[RCMessage alloc] initWithText:dbmessage.messageTextContent incoming:incoming];
                
                
            } break;
            case CTChatMessageTypeEmoji: {
                //                rcmessage = [[RCMessage alloc] initWithEmoji:dbmessage.text incoming:incoming];
                
                
            } break;
            case CTChatMessageTypePicture: {
                UIImage* targetImage = nil;
                if (dbmessage.messagePictureImage)
                    targetImage = dbmessage.messagePictureImage;
                else {
                    targetImage = [UIImage imageWithData:dbmessage.messageDataPacket];
                }
                rcmessage = [[RCMessage alloc] initWithPicture:targetImage incoming:incoming];
            } break;
            case CTChatMessageTypeVideo: {
                //                rcmessage = [[RCMessage alloc] initWithVideo:nil durarion:dbmessage.video_duration incoming:incoming];
                //                [MediaLoader loadVideo:rcmessage dbmessage:dbmessage tableView:self.tableView];
            } break;
            case CTChatMessageTypeAudio: {
                NSData*audioData = dbmessage.messageDataPacket;
                rcmessage = [[RCMessage alloc] initWithAudioData:audioData duration:dbmessage.messageAudioDuration incoming:incoming];
                rcmessage.status = RC_STATUS_SUCCEED;
                //                rcmessage.bubble_backcolor = dbmessage.packetSenderRecorder.colorForHostModeLite;
                
            } break;
            case CTChatMessageTypeLocation: {
                //                rcmessage = [[RCMessage alloc] initWithLatitude:nil longitude:nil incoming:incoming completion:^{
                //                    [self.tableView reloadData];
                //                }];
                
            } break;
            default: break;
        }
        if (rcmessage)
            rcmessages[messageId] = rcmessage;
        else {
            NSLog(@"%s unable to add transcript", __PRETTY_FUNCTION__);
        }
    }
    return rcmessages[messageId];
}

#pragma mark - Avatar methods


- (NSString *)avatarInitials:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    CTPacketChat *dbmessage = [self dbmessage:indexPath];
    
    NSString*username = dbmessage.packetSender.peerUserName;
    if (avatarInitials[username] == nil)
        {
        if (username.length > 2)
            avatarInitials[username] = [username substringToIndex:2];
        else
            avatarInitials[username] = username;
        }
    
    return avatarInitials[username];
}


- (UIImage *)avatarImage:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    CTPacketChat *dbmessage = [self dbmessage:indexPath];
    return dbmessage.packetSender.peerAvatarImage;
}


- (void)loadAvatarImage:(NSString *)userId {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([avatarIds containsObject:userId]) return;
    else [avatarIds addObject:userId];
}

#pragma mark - Header, Footer methods


- (NSString *)textCellHeader:(NSIndexPath *)indexPath {
    if (indexPath.row % 3 == 0)
        {
        CTPacketChat *dbmessage = [self dbmessage:indexPath];
        NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:dbmessage.packetTimestamp];
        //        NSDate *date = [NSDate dateWithTimestamp:dbmessage.packetTimestamp];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM, HH:mm:ss"];
        return [dateFormatter stringFromDate:date];
        }
    else return nil;
}


- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath {
    RCMessage *rcmessage = [self rcmessage:indexPath];
    if (rcmessage.incoming)
        {
        CTPacketChat *dbmessage = [self dbmessage:indexPath];
        CTPacketChat *dbmessageAbove = [self dbmessageAbove:indexPath];
        if (dbmessageAbove != nil)
            {
            if ([dbmessage.packetUniqueId isEqualToString:dbmessageAbove.packetUniqueId])
                return nil;
            }
        return dbmessage.packetSender.peerUserName;
        }
    return nil;
}

- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath {
    return nil;
}

- (NSString *)textCellFooter:(NSIndexPath *)indexPath {
    RCMessage *rcmessage = [self rcmessage:indexPath];
    if (rcmessage.outgoing) {
        // UTPacketChat *dbmessage = [self dbmessage:indexPath];
        //        return (dbmessage.createdAt > lastRead) ? dbmessage.status : TEXT_READ;
    }
    return nil;
}

#pragma mark - Menu controller methods


- (NSArray *)menuItems:(NSIndexPath *)indexPath {
    if (forwarding) return nil;
    
    RCMenuItem *menuItemCopy = [[RCMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionMenuCopy:)];
    RCMenuItem *menuItemSave = [[RCMenuItem alloc] initWithTitle:@"Save" action:@selector(actionMenuSave:)];
    RCMenuItem *menuItemDelete = [[RCMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionMenuDelete:)];
    RCMenuItem *menuItemForward = [[RCMenuItem alloc] initWithTitle:@"Forward" action:@selector(actionMenuForward:)];
    
    menuItemCopy.indexPath = indexPath;
    menuItemSave.indexPath = indexPath;
    menuItemDelete.indexPath = indexPath;
    menuItemForward.indexPath = indexPath;
    
    RCMessage *rcmessage = [self rcmessage:indexPath];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (rcmessage.type == RC_TYPE_TEXT)        [array addObject:menuItemCopy];
    if (rcmessage.type == RC_TYPE_EMOJI)    [array addObject:menuItemCopy];
    
    if (rcmessage.type == RC_TYPE_PICTURE)    [array addObject:menuItemSave];
    if (rcmessage.type == RC_TYPE_VIDEO)    [array addObject:menuItemSave];
    if (rcmessage.type == RC_TYPE_AUDIO)    [array addObject:menuItemSave];
    
    if (rcmessage.outgoing)    [array addObject:menuItemDelete];
    
    [array addObject:menuItemForward];
    
    return array;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(actionMenuCopy:))        return YES;
    if (action == @selector(actionMenuSave:))        return NO;
    if (action == @selector(actionMenuDelete:))        return NO;
    if (action == @selector(actionMenuForward:))    return NO;
    return NO;
}


- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - Typing indicator methods


- (void)typingIndicatorShow:(BOOL)show animated:(BOOL)animated {
//    if (show) {
//        self.tableView.tableFooterView = viewTypingIndicator;
//        [self scrollToBottom:animated];
//    } else {
//        [UIView animateWithDuration:(animated ? 0.25 : 0) animations:^{
//            self.tableView.tableFooterView = nil;
//        }];
//    }
}

- (void)typingIndicatorUpdate {
    typingCounter++;
    [self typingIndicatorSave:@YES];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{ [self typingIndicatorStop]; });
}

- (void)typingIndicatorStop {
    typingCounter--;
    if (typingCounter == 0) [self typingIndicatorSave:@NO];
}

- (void)typingIndicatorSave:(NSNumber *)typing {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //    [firebase1 updateChildValues:@{[FUser currentId]:typing}];
}

#pragma mark - Keyboard methods


- (void)keyboardShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	
	CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	CGFloat heightKeyboard = keyboard.size.height;
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.viewInputBottomConstraint.constant = heightKeyboard;
        //self.view.center = CGPointMake(self->centerView.x, self->centerView.y - heightKeyboard);
	} completion:nil];
	
	[[UIMenuController sharedMenuController] setMenuItems:nil];
}


- (void)keyboardHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.viewInputBottomConstraint.constant = 0.0;
//        self.view.center = self->centerView;
	} completion:nil];
}


- (void)dismissKeyboard

{
	[self.view endEditing:YES];
}

#pragma mark - Input panel methods


- (void)inputPanelInit {
    self.tableView.backgroundColor = [RCMessages chatBackgroundColor];

	viewInput.backgroundColor = [RCMessages inputViewBackColor];
	textInput.backgroundColor = [RCMessages inputTextBackColor];
//    viewInput.tintColor = [UIColor SRHighlightGreeColor];
	
	textInput.font = [RCMessages inputFont];
	textInput.textColor = [RCMessages inputTextTextColor];
	
	textInput.textContainer.lineFragmentPadding = 0;
	textInput.textContainerInset = [RCMessages inputInset];
	
	textInput.layer.borderColor = [RCMessages inputBorderColor];
	textInput.layer.borderWidth = [RCMessages inputBorderWidth];
	
	textInput.layer.cornerRadius = [RCMessages inputRadius];
	textInput.clipsToBounds = YES;
}


- (void)inputPanelUpdate {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status != AVAuthorizationStatusAuthorized) {
        [buttonInputAudio setImage:[UIImage imageNamed:@"permissionsmicrophone-denied"] forState:UIControlStateNormal];
    } else {
        [buttonInputAudio setImage:[UIImage imageNamed:@"rcmessages_audio"] forState:UIControlStateNormal];
    }

	CGFloat widthText = textInput.frame.size.width, heightText;
	CGSize sizeText = [textInput sizeThatFits:CGSizeMake(widthText, MAXFLOAT)];
	
	heightText = fmaxf([RCMessages inputTextHeightMin], sizeText.height);
	heightText = fminf([RCMessages inputTextHeightMax], heightText);
	
    CGFloat heightInput = heightText + ([RCMessages inputViewHeightMin] - [RCMessages inputTextHeightMin]);
	
    self.viewInputHeightConstraint.constant = heightInput;

	
//    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, heightView - heightInput);
//    self.tableView.frame = CGRectMake(0, 0, widthView, heightView - heightInput);

	
//    CGRect frameViewInput = viewInput.frame;
//    frameViewInput.origin.y = heightView - heightInput;
//    frameViewInput.size.height = heightInput;
//    viewInput.frame = frameViewInput;
	
//    [viewInput layoutIfNeeded];
	

	
//    CGRect frameAttach = buttonInputAttach.frame;
//    frameAttach.origin.y = heightInput - frameAttach.size.height;
//    buttonInputAttach.frame = frameAttach;
//
//    CGRect frameTextInput = textInput.frame;
//    frameTextInput.size.height = heightText;
//    textInput.frame = frameTextInput;
//
//    CGRect frameAudio = buttonInputAudio.frame;
//    frameAudio.origin.y = heightInput - frameAudio.size.height;
//    buttonInputAudio.frame = frameAudio;
//
//    CGRect frameSend = buttonInputSend.frame;
//    frameSend.origin.y = heightInput - frameSend.size.height;
//    buttonInputSend.frame = frameSend;
	
	buttonInputAudio.hidden = textInput.text.length > 0;
	buttonInputSend.hidden = !buttonInputAudio.isHidden;
	

	
//    CGPoint offset = CGPointMake(0, sizeText.height - heightText);
//    [textInput setContentOffset:offset animated:NO];
	
	[self scrollToBottom:NO];
}

#pragma mark - User actions (title)

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popoverVolume"] && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UIViewController* controller = segue.destinationViewController;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.popoverPresentationController.delegate = self;
        controller.popoverPresentationController.barButtonItem = self.speakerphoneButton;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (IBAction)speakerPhoneButtonAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"popoverVolume" sender:self];
    
//    UIAlertController*controller = [sender alertControllerForSpeakerphoneBarButtonItem];
//    controller.modalPresentationStyle = UIModalPresentationPopover;
//    controller.popoverPresentationController.delegate = self;
//    controller.popoverPresentationController.barButtonItem = sender;
//    [self presentViewController:controller animated:YES completion:nil];
}

-(void)actionClearChat {
    [CTNetworkManager.singleton clearChatContents];
    [self.dbmessages removeAllObjects];
    [self.rcmessages removeAllObjects];
    [self refreshTableView1];
}

- (IBAction)settingsButtonAction:(UIBarButtonItem *)sender {
    UIAlertController *controller = [UIAlertController
                                          alertControllerWithTitle:@"Quick Options"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) {
                                   }];
    [controller addAction:cancelAction];
    
    UIAlertAction *clearAction = [UIAlertAction
                                actionWithTitle:@"Clear Transcripts"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self actionClearChat];
                                }];
    [controller addAction:clearAction];
    
    UIAlertAction *settingsAction = [UIAlertAction
                                  actionWithTitle:@"Go to Settings..."
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
//                                      if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//                                          [self performSegueWithIdentifier:@"popOverSettings" sender: sender];
//                                      } else {
                                          [self performSegueWithIdentifier:@"pushSettings" sender: sender];
//                                      }
                                  }];
    [controller addAction:settingsAction];

    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.popoverPresentationController.delegate = self;
    controller.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:controller animated:YES completion:nil];

}

- (void)actionBack {
    [self.navigationController.navigationController popViewControllerAnimated:YES];
}


- (IBAction)actionTitle:(id)sender {
	[self actionTitle];
}


- (void)actionTitle {

}

#pragma mark - User actions (load earlier)


- (IBAction)actionLoadEarlier:(id)sender {
	[self actionLoadEarlier];
}


- (void)actionLoadEarlier {
    self.insertCounter += 10;
    [self refreshTableView2];
}

#pragma mark - User actions (cell tap)


- (void)actionTapCell:(NSIndexPath *)indexPath

{

}

#pragma mark - User actions (bubble tap)


- (void)actionTapBubble:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (forwarding) { return; }
    if (CTChatAudioPlayerRecorder.singleton.isRecording) {
        [self audioRecorderStop:YES];
    }
    [CTChatAudioPlayerRecorder.singleton stopPlaying];

    RCMessage *rcmessage = [self rcmessage:indexPath];
    
    switch (rcmessage.type) {
        case RC_TYPE_STATUS: {
            
        } break;
            
        case RC_TYPE_TEXT: {
            
            break;
        }
        case RC_TYPE_EMOJI: {
            
            break;
        }
        case RC_TYPE_PICTURE: {
            if (rcmessage.status == RC_STATUS_MANUAL) {
                // [MediaLoader loadPictureManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
                // [self.tableView reloadData];
            } else if (rcmessage.status == RC_STATUS_SUCCEED) {
                /// Display image
                CTPictureViewController *pictureView = [[CTPictureViewController alloc] initWith:rcmessage.picture_image];
                [self presentViewController:pictureView animated:YES completion:nil];
            }
        } break;
        case RC_TYPE_VIDEO: {
            if (rcmessage.status == RC_STATUS_MANUAL) {
                // [MediaLoader loadVideoManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
                // [self.tableView reloadData];
            } else if (rcmessage.status == RC_STATUS_SUCCEED) {
                NSURL *url = [NSURL fileURLWithPath:rcmessage.video_path];
                CTVideoViewController *videoView = [[CTVideoViewController alloc] initWith:url];
                [self presentViewController:videoView animated:YES completion:nil];
            }
        } break;
        case RC_TYPE_AUDIO: {
            RCMessagesAudioCell*audioCell = [self.tableView cellForRowAtIndexPath:indexPath];
            CTChatAudioPlayerRecorder.singleton.chatPlayingCellDelegate = audioCell;
            [audioCell audioCellUserDidTap];
//            if (rcmessage.status == RC_STATUS_MANUAL) {
//                // [MediaLoader loadAudioManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
//                // [self.tableView reloadData];
//            } else if (rcmessage.status == RC_STATUS_SUCCEED) {
//                if (rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED) {
//                    rcmessage.audio_status = RC_AUDIOSTATUS_PLAYING;
//                    [self.tableView reloadData];
//                    [[CTChatAudioPlayerRecorder singleton] speakChatMessageData:rcmessage.message_data withCompletion:^{
//                        rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
//                        [self.tableView reloadData];
//                    }];
//                } else if (rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING) {
//                    [[CTChatAudioPlayerRecorder singleton] stopPlaying];
//                    rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
//                    [self.tableView reloadData];
//                }
//            }
        } break;
        case RC_TYPE_LOCATION: {
            //        CLLocation *location = [[CLLocation alloc] initWithLatitude:rcmessage.latitude longitude:rcmessage.longitude];
            //        MapView *mapView = [[MapView alloc] initWith:location];
            //        NavigationController *navController = [[NavigationController alloc] initWithRootViewController:mapView];
            //        [self presentViewController:navController animated:YES completion:nil];
        } break;
    }

}

#pragma mark - User actions (avatar tap)


- (void)actionTapAvatar:(NSIndexPath *)indexPath {

}

#pragma mark - User actions (menu)

- (void)actionMenuCopy:(id)sender {
    NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
    RCMessage *rcmessage = [self rcmessage:indexPath];
    
    [[UIPasteboard generalPasteboard] setString:rcmessage.text];
}


- (void)actionMenuSave:(id)sender {
    NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
    RCMessage *rcmessage = [self rcmessage:indexPath];
    
    if (rcmessage.type == RC_TYPE_PICTURE)
        {
        if (rcmessage.status == RC_STATUS_SUCCEED)
            UIImageWriteToSavedPhotosAlbum(rcmessage.picture_image, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    
    if (rcmessage.type == RC_TYPE_VIDEO)
        {
        if (rcmessage.status == RC_STATUS_SUCCEED)
            // UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(NSString *videoPath)
            UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.video_path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    
    if (rcmessage.type == RC_TYPE_AUDIO)
        {
        if (rcmessage.status == RC_STATUS_SUCCEED)
            {
            //            NSString *path = [File temp:@"mp4"];
            //            [File copy:rcmessage.audio_path dest:path overwrite:YES];
            //            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

- (void)actionMenuDelete:(id)sender {
    NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
    [self messageDelete:indexPath];
}

- (void)messageDelete:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)actionMenuForward:(id)sender {
    
}


#pragma mark - User actions (input panel)


- (IBAction)actionInputAttach:(id)sender {
	[self actionAttachMessage];
}


- (IBAction)actionInputSend:(id)sender {
	if (textInput.text.length > 0) {
		[self actionSendMessage:textInput.text];
		[self dismissKeyboard];
		textInput.text = nil;
		[self inputPanelUpdate];
	}
}


- (void)actionAttachMessage {
    [self.view endEditing:YES];
    NSString *title = @"Add content";
    NSString *mess = @"Choose a media content to attach and send.";
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:mess
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) {}];
    [alertController addAction:cancelAction];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *takePhotoAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedString(@"Take a photo", nil)
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action) {
                                              if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                  
                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                  picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                                  picker.delegate = self;
                                                  picker.allowsEditing = YES;
                                                  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                  // picker.mediaTypes = @[kUTTypeImage];
                                                  [self presentViewController:picker animated:YES completion:nil];
                                                  
                                                  
                                              }
                                          }];
        [alertController addAction:takePhotoAction];
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertAction *pickPhotoAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedString(@"Photo from library", nil)
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action) {
                                              if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                  picker.delegate = self;
                                                  picker.allowsEditing = YES;
                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                  
                                                  [self presentViewController:picker animated:YES completion:nil];
                                              }
                                          }];
        [alertController addAction:pickPhotoAction];
    }
    UIAlertAction *drawingAction = [UIAlertAction
                                    actionWithTitle:@"New Sketch"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        UIStoryboard*storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                        CTDrawViewController*vc = [storyboard instantiateViewControllerWithIdentifier:@"DrawViewVCID"];
                                        vc.delegate = self;
                                        [self presentViewController:vc animated:YES completion:nil];
                                    }];
    [alertController addAction:drawingAction];
    
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = self.buttonInputAttach;
        popPresenter.sourceRect = self.buttonInputAttach.bounds;
    }
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];

}


- (void)actionSendAudio:(NSString *)path withDuration:(NSTimeInterval)duration {
    [self messageSend:nil picture:nil video:nil audio:path duration:duration];
}


- (void)actionSendMessage:(NSString *)text {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, text);
    [self messageSend:text picture:nil video:nil audio:nil duration:0];
}


- (void)actionSelectMember {
	
}

- (void)actionStickers {
    //    StickersView *stickersView = [[StickersView alloc] init];
    //    stickersView.delegate = self;
    //    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:stickersView];
    //    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didSelectSticker:(NSString *)sticker {
    //    UIImage *picture = [UIImage imageNamed:sticker];
    //    [self messageSend:nil picture:picture video:nil audio:nil];
}

- (void)actionLocation {
    [self messageSend:nil picture:nil video:nil audio:nil duration:0];
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView

{
	[self dismissKeyboard];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(insertCounter, [dbmessages count]);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessage *rcmessage = [self rcmessage:indexPath];
	
	if (rcmessage.type == RC_TYPE_STATUS)	return [RCMessagesStatusCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_TEXT)		return [RCMessagesTextCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_EMOJI)	return [RCMessagesEmojiCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_PICTURE)	return [RCMessagesPictureCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_VIDEO)	return [RCMessagesVideoCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_AUDIO)	return [RCMessagesAudioCell height:indexPath messagesView:self];
	if (rcmessage.type == RC_TYPE_LOCATION)	return [RCMessagesLocationCell height:indexPath messagesView:self];
	
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessage *rcmessage = [self rcmessage:indexPath];
	
	if (rcmessage.type == RC_TYPE_STATUS)	return [self tableView:tableView cellStatusForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_TEXT)		return [self tableView:tableView cellTextForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_EMOJI)	return [self tableView:tableView cellEmojiForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_PICTURE)	return [self tableView:tableView cellPictureForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_VIDEO)	return [self tableView:tableView cellVideoForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_AUDIO)	return [self tableView:tableView cellAudioForRowAtIndexPath:indexPath];
	if (rcmessage.type == RC_TYPE_LOCATION)	return [self tableView:tableView cellLocationForRowAtIndexPath:indexPath];
	
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellStatusForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesStatusCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellTextForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesTextCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellEmojiForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesEmojiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesEmojiCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellPictureForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesPictureCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellVideoForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesVideoCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellAudioForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesAudioCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellLocationForRowAtIndexPath:(NSIndexPath *)indexPath

{
	RCMessagesLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCMessagesLocationCell" forIndexPath:indexPath];
	[cell bindData:indexPath messagesView:self];
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath

{
	RCMessage *rcmessage = [self rcmessage:indexPath];
	
	return (rcmessage.type != RC_TYPE_STATUS);
}

#pragma mark - Helper methods


- (void)scrollToBottom:(BOOL)animated

{
	if ([self.tableView numberOfRowsInSection:0] > 0)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0] - 1) inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
	}
}

#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text

{
	if ([text isEqualToString:@"@"])
		[self actionSelectMember];
	return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
	[self inputPanelUpdate];
	[self typingIndicatorUpdate];
}

#pragma mark - Audio recorder methods


- (void)audioRecorderGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            if (status != AVAuthorizationStatusAuthorized) {
                BOOL aDenied = status == AVAuthorizationStatusDenied;
                
                // Check permissions
                NSString *title = @"Please grant microphone access";
                NSString *mess = @"This is needed to send voice messages.";
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:title
                                                      message:mess
                                                      preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action) { }];
                [alertController addAction:cancelAction];
                if (aDenied) {
                    UIAlertAction *requestCameraPermissions = [UIAlertAction
                                                               actionWithTitle:NSLocalizedString(@"Grant Microphone Access in Settings", @"request audio permissions iOS Settings (Denied)")
                                                               style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   NSOperatingSystemVersion ios10_0_0 = (NSOperatingSystemVersion){10, 0, 0};
                                                                   BOOL latestOS = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_0];
                                                                   
                                                                   UIApplication *application = [UIApplication sharedApplication];
                                                                   NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
                                                                   
                                                                   if (latestOS) {
                                                                       [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                                                                          }];
                                                                   } else {
                                                                       [application openURL:URL];
                                                                   }
#pragma clang diagnostic pop
                                                               }];
                    [alertController addAction:requestCameraPermissions];
                } else {
                    UIAlertAction *requestAudioPermissions = [UIAlertAction
                                                              actionWithTitle:NSLocalizedString(@"Grant Microphone Access", @"request audio permissions")
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                                                      if (granted)
                                                                          dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                              [self->buttonInputAudio setImage:[UIImage imageNamed:@"rcmessages_audio"] forState:UIControlStateNormal];
                                                                          });
                                                                  }];
                                                              }];
                    [alertController addAction:requestAudioPermissions];
                }
                
                alertController.modalPresentationStyle = UIModalPresentationPopover;
                alertController.popoverPresentationController.delegate = self;
                alertController.popoverPresentationController.sourceView = buttonInputAudio;
                alertController.popoverPresentationController.sourceRect = buttonInputAudio.bounds;
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }

            
            pointAudioStart = [gestureRecognizer locationInView:self.view];
            [self audioRecorderStart];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            if (status == AVAuthorizationStatusAuthorized){
                CGPoint pointAudioStop = [gestureRecognizer locationInView:self.view];
                CGFloat distanceAudio = sqrtf(powf(pointAudioStop.x - pointAudioStart.x, 2) + pow(pointAudioStop.y - pointAudioStart.y, 2));
                [self audioRecorderStop:(distanceAudio < 50)];
            }
            break;
        }
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self audioRecorderStop:NO];
            break;
    }
}

- (void)audioRecorderStart {
    if ([CTChatAudioPlayerRecorder.singleton startRecordChatMessage]) {
//        dateAudioStart = [NSDate date];
        
//        timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.07 target:self selector:@selector(audioRecorderUpdate) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:timerAudio forMode:NSRunLoopCommonModes];
        
//        [self audioRecorderUpdate];
        
        viewInputAudio.hidden = NO;
    }
}


- (void)audioRecorderStop:(BOOL)sending {
    NSLog(@"audioRecorderStop:sending %@", sending?@"YES":@"NO");
    [CTChatAudioPlayerRecorder.singleton stopRecordVoice:sending];
    
//    [timerAudio invalidate];
//    timerAudio = nil;
	
//    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:dateAudioStart];
//    if ((sending) && (duration >= 1)) {
    [self actionSendAudio:@"" withDuration:0.0];
//    } else {
//        [audioRecorder deleteRecording];
//    }
	viewInputAudio.hidden = YES;
}


- (void)recordingTimeUpdated:(NSTimeInterval)time formattedTime:(NSString*)formattedDuration {
    assert(NSThread.isMainThread);

    //    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:dateAudioStart];
//    int millisec = (int) (interval * 100) % 100;
//    int seconds = (int) interval % 60;
//    int minutes = (int) interval / 60;
//    if (seconds >= 20) {
//        [self audioRecorderStop:YES];
//    }
	labelInputAudio.text = formattedDuration;
}

- (void)actionCleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTNetworkChatMessageReceivedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
