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

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


#define		HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//#define		SCREEN_WIDTH						[UIScreen mainScreen].bounds.size.width
#define		SCREEN_HEIGHT						[UIScreen mainScreen].bounds.size.height



typedef NS_ENUM(NSUInteger, RC_TYPE) {
    RC_TYPE_STATUS = 1,
    RC_TYPE_TEXT,
    RC_TYPE_EMOJI,
    RC_TYPE_PICTURE,
    RC_TYPE_VIDEO,
    RC_TYPE_AUDIO,
    RC_TYPE_LOCATION
};

typedef NS_ENUM(NSUInteger, RC_STATUS) {
    RC_STATUS_LOADING = 1,
    RC_STATUS_SUCCEED,
    RC_STATUS_MANUAL,
};



typedef NS_ENUM(NSUInteger, RC_AUDIOSTATUS) {
    RC_AUDIOSTATUS_STOPPED = 1,
    RC_AUDIOSTATUS_PLAYING,
};




@interface RCMessages : NSObject


@property (strong, nonatomic) UIColor *chatBackgroundColor;


//---------------------------------------------------------------------------------
// Cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat cellMarginTop;

@property (assign, nonatomic) CGFloat cellHeaderHeight;
@property (assign, nonatomic) CGFloat cellHeaderLeft;
@property (assign, nonatomic) CGFloat cellHeaderRight;
@property (strong, nonatomic) UIColor *cellHeaderColor;
@property (strong, nonatomic) UIFont *cellHeaderFont;

@property (assign, nonatomic) CGFloat cellFooterHeight;
@property (assign, nonatomic) CGFloat cellFooterLeft;
@property (assign, nonatomic) CGFloat cellFooterRight;
@property (strong, nonatomic) UIColor *cellFooterColor;
@property (strong, nonatomic) UIFont *cellFooterFont;

@property (assign, nonatomic) CGFloat cellMarginBottom;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Bubble
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat bubbleHeaderHeight;
@property (assign, nonatomic) CGFloat bubbleHeaderLeft;
@property (assign, nonatomic) CGFloat bubbleHeaderRight;
@property (strong, nonatomic) UIColor *bubbleHeaderColor;
@property (strong, nonatomic) UIFont *bubbleHeaderFont;

@property (assign, nonatomic) CGFloat bubbleMarginLeft;
@property (assign, nonatomic) CGFloat bubbleMarginRight;
@property (assign, nonatomic) CGFloat bubbleRadius;

@property (assign, nonatomic) CGFloat bubbleFooterHeight;
@property (assign, nonatomic) CGFloat bubbleFooterLeft;
@property (assign, nonatomic) CGFloat bubbleFooterRight;
@property (strong, nonatomic) UIColor *bubbleFooterColor;
@property (strong, nonatomic) UIFont *bubbleFooterFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Avatar
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat avatarDiameter;
@property (assign, nonatomic) CGFloat avatarMarginLeft;
@property (assign, nonatomic) CGFloat avatarMarginRight;

@property (strong, nonatomic) UIColor *avatarBackColor;
@property (strong, nonatomic) UIColor *avatarTextColor;

@property (strong, nonatomic) UIFont *avatarFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Status cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat statusBubbleRadius;

@property (strong, nonatomic) UIColor *statusBubbleColor;
@property (strong, nonatomic) UIColor *statusTextColor;

@property (strong, nonatomic) UIFont *statusFont;

@property (assign, nonatomic) CGFloat statusInsetLeft;
@property (assign, nonatomic) CGFloat statusInsetRight;
@property (assign, nonatomic) CGFloat statusInsetTop;
@property (assign, nonatomic) CGFloat statusInsetBottom;
@property (assign, nonatomic) UIEdgeInsets statusInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Text cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat textBubbleWidthMin;
@property (assign, nonatomic) CGFloat textBubbleHeightMin;

@property (strong, nonatomic) UIColor *textBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *textBubbleColorIncoming;
@property (strong, nonatomic) UIColor *textTextColorOutgoing;
@property (strong, nonatomic) UIColor *textTextColorIncoming;

@property (strong, nonatomic) UIFont *textFont;

@property (assign, nonatomic) CGFloat textInsetLeft;
@property (assign, nonatomic) CGFloat textInsetRight;
@property (assign, nonatomic) CGFloat textInsetTop;
@property (assign, nonatomic) CGFloat textInsetBottom;
@property (assign, nonatomic) UIEdgeInsets textInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Emoji cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat emojiBubbleWidthMin;
@property (assign, nonatomic) CGFloat emojiBubbleHeightMin;

@property (strong, nonatomic) UIColor *emojiBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *emojiBubbleColorIncoming;

@property (strong, nonatomic) UIFont *emojiFont;

@property (assign, nonatomic) CGFloat emojiInsetLeft;
@property (assign, nonatomic) CGFloat emojiInsetRight;
@property (assign, nonatomic) CGFloat emojiInsetTop;
@property (assign, nonatomic) CGFloat emojiInsetBottom;
@property (assign, nonatomic) UIEdgeInsets emojiInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Picture cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat pictureBubbleWidth;

@property (strong, nonatomic) UIColor *pictureBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *pictureBubbleColorIncoming;

@property (strong, nonatomic) UIImage *pictureImageManual;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Video cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat videoBubbleWidth;
@property (assign, nonatomic) CGFloat videoBubbleHeight;

@property (strong, nonatomic) UIColor *videoBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *videoBubbleColorIncoming;

@property (strong, nonatomic) UIImage *videoImagePlay;
@property (strong, nonatomic) UIImage *videoImageManual;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Audio cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat audioBubbleWidht;
@property (assign, nonatomic) CGFloat audioBubbleHeight;

@property (strong, nonatomic) UIColor *audioBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *audioBubbleColorIncoming;
@property (strong, nonatomic) UIColor *audioTextColorOutgoing;
@property (strong, nonatomic) UIColor *audioTextColorIncoming;

@property (strong, nonatomic) UIImage *audioImagePlay;
@property (strong, nonatomic) UIImage *audioImagePause;
@property (strong, nonatomic) UIImage *audioImageManual;

@property (strong, nonatomic) UIFont *audioFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Location cell
//---------------------------------------------------------------------------------
@property (assign, nonatomic) CGFloat locationBubbleWidth;
@property (assign, nonatomic) CGFloat locationBubbleHeight;

@property (strong, nonatomic) UIColor *locationBubbleColorOutgoing;
@property (strong, nonatomic) UIColor *locationBubbleColorIncoming;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Input view
//---------------------------------------------------------------------------------
@property (strong, nonatomic) UIColor *inputViewBackColor;
@property (strong, nonatomic) UIColor *inputTextBackColor;
@property (strong, nonatomic) UIColor *inputTextTextColor;

@property (strong, nonatomic) UIFont *inputFont;

@property (assign, nonatomic) CGFloat inputViewHeightMin;
@property (assign, nonatomic) CGFloat inputTextHeightMin;
@property (assign, nonatomic) CGFloat inputTextHeightMax;

@property (assign, nonatomic) CGFloat inputBorderWidth;
@property (assign, nonatomic) CGColorRef inputBorderColor;

@property (assign, nonatomic) CGFloat inputRadius;

@property (assign, nonatomic) CGFloat inputInsetLeft;
@property (assign, nonatomic) CGFloat inputInsetRight;
@property (assign, nonatomic) CGFloat inputInsetTop;
@property (assign, nonatomic) CGFloat inputInsetBottom;
@property (assign, nonatomic) UIEdgeInsets inputInset;
//---------------------------------------------------------------------------------

#pragma mark - Class methods

+ (RCMessages *)shared;

+(UIColor*)chatBackgroundColor;

//---------------------------------------------------------------------------------
// Cell
//---------------------------------------------------------------------------------
+ (CGFloat)cellMarginTop;

+ (CGFloat)cellHeaderHeight;
+ (CGFloat)cellHeaderLeft;
+ (CGFloat)cellHeaderRight;
+ (UIColor *)cellHeaderColor;
+ (UIFont *)cellHeaderFont;

+ (CGFloat)cellFooterHeight;
+ (CGFloat)cellFooterLeft;
+ (CGFloat)cellFooterRight;
+ (UIColor *)cellFooterColor;
+ (UIFont *)cellFooterFont;

+ (CGFloat)cellMarginBottom;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Bubble
//---------------------------------------------------------------------------------
+ (CGFloat)bubbleHeaderHeight;
+ (CGFloat)bubbleHeaderLeft;
+ (CGFloat)bubbleHeaderRight;
+ (UIColor *)bubbleHeaderColor;
+ (UIFont *)bubbleHeaderFont;

+ (CGFloat)bubbleMarginLeft;
+ (CGFloat)bubbleMarginRight;
+ (CGFloat)bubbleRadius;

+ (CGFloat)bubbleFooterHeight;
+ (CGFloat)bubbleFooterLeft;
+ (CGFloat)bubbleFooterRight;
+ (UIColor *)bubbleFooterColor;
+ (UIFont *)bubbleFooterFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Avatar
//---------------------------------------------------------------------------------
+ (CGFloat)avatarDiameter;
+ (CGFloat)avatarMarginLeft;
+ (CGFloat)avatarMarginRight;

+ (UIColor *)avatarBackColor;
+ (UIColor *)avatarTextColor;

+ (UIFont *)avatarFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Status cell
//---------------------------------------------------------------------------------
+ (CGFloat)statusBubbleRadius;

+ (UIColor *)statusBubbleColor;
+ (UIColor *)statusTextColor;

+ (UIFont *)statusFont;

+ (CGFloat)statusInsetLeft;
+ (CGFloat)statusInsetRight;
+ (CGFloat)statusInsetTop;
+ (CGFloat)statusInsetBottom;
+ (UIEdgeInsets)statusInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Text cell
//---------------------------------------------------------------------------------
+ (CGFloat)textBubbleWidthMin;
+ (CGFloat)textBubbleHeightMin;

+ (UIColor *)textBubbleColorOutgoing;
+ (UIColor *)textBubbleColorIncoming;
+ (UIColor *)textTextColorOutgoing;
+ (UIColor *)textTextColorIncoming;

+ (UIFont *)textFont;

+ (CGFloat)textInsetLeft;
+ (CGFloat)textInsetRight;
+ (CGFloat)textInsetTop;
+ (CGFloat)textInsetBottom;
+ (UIEdgeInsets)textInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Emoji cell
//---------------------------------------------------------------------------------
+ (CGFloat)emojiBubbleWidthMin;
+ (CGFloat)emojiBubbleHeightMin;

+ (UIColor *)emojiBubbleColorOutgoing;
+ (UIColor *)emojiBubbleColorIncoming;

+ (UIFont *)emojiFont;

+ (CGFloat)emojiInsetLeft;
+ (CGFloat)emojiInsetRight;
+ (CGFloat)emojiInsetTop;
+ (CGFloat)emojiInsetBottom;
+ (UIEdgeInsets)emojiInset;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Picture cell
//---------------------------------------------------------------------------------
+ (CGFloat)pictureBubbleWidth;

+ (UIColor *)pictureBubbleColorOutgoing;
+ (UIColor *)pictureBubbleColorIncoming;

+ (UIImage *)pictureImageManual;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Video cell
//---------------------------------------------------------------------------------
+ (CGFloat)videoBubbleWidth;
+ (CGFloat)videoBubbleHeight;

+ (UIColor *)videoBubbleColorOutgoing;
+ (UIColor *)videoBubbleColorIncoming;

+ (UIImage *)videoImagePlay;
+ (UIImage *)videoImageManual;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Audio cell
//---------------------------------------------------------------------------------
+ (CGFloat)audioBubbleWidht;
+ (CGFloat)audioBubbleHeight;

+ (UIColor *)audioBubbleColorOutgoing;
+ (UIColor *)audioBubbleColorIncoming;
+ (UIColor *)audioTextColorOutgoing;
+ (UIColor *)audioTextColorIncoming;

+ (UIImage *)audioImagePlay;
+ (UIImage *)audioImagePause;
+ (UIImage *)audioImageManual;

+ (UIFont *)audioFont;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Location cell
//---------------------------------------------------------------------------------
+ (CGFloat)locationBubbleWidth;
+ (CGFloat)locationBubbleHeight;

+ (UIColor *)locationBubbleColorOutgoing;
+ (UIColor *)locationBubbleColorIncoming;
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Input view
//---------------------------------------------------------------------------------
+ (UIColor *)inputViewBackColor;
+ (UIColor *)inputTextBackColor;
+ (UIColor *)inputTextTextColor;

+ (UIFont *)inputFont;

+ (CGFloat)inputViewHeightMin;
+ (CGFloat)inputTextHeightMin;
+ (CGFloat)inputTextHeightMax;

+ (CGFloat)inputBorderWidth;
+ (CGColorRef)inputBorderColor;

+ (CGFloat)inputRadius;

+ (CGFloat)inputInsetLeft;
+ (CGFloat)inputInsetRight;
+ (CGFloat)inputInsetTop;
+ (CGFloat)inputInsetBottom;
+ (UIEdgeInsets)inputInset;
//---------------------------------------------------------------------------------

@end
