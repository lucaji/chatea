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


@interface RCMessage : NSObject


#pragma mark - Properties

@property (nonatomic) UIColor*bubble_backcolor;
@property (nonatomic) NSData*message_data;

@property (assign, nonatomic) RC_TYPE type;

@property (assign, nonatomic) BOOL incoming;
@property (assign, nonatomic) BOOL outgoing;

@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic) UIImage *picture_image;
@property (assign, nonatomic) CGFloat picture_width; // should be float
@property (assign, nonatomic) CGFloat picture_height;

@property (strong, nonatomic) NSString *video_path;
@property (strong, nonatomic) UIImage *video_thumbnail;
@property (assign, nonatomic) NSTimeInterval video_duration;

@property (strong, nonatomic) NSString *audio_path;
@property (assign, nonatomic) NSTimeInterval audio_duration;
@property (assign, nonatomic) RC_AUDIOSTATUS audio_status;

@property (assign, nonatomic) CLLocationDegrees latitude;
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (strong, nonatomic) UIImage *location_thumbnail;

@property (assign, nonatomic) RC_STATUS status;

#pragma mark - Initialization methods

- (instancetype)initWithStatus:(NSString *)text;

- (instancetype)initWithText:(NSString *)text incoming:(BOOL)incoming;

- (instancetype)initWithEmoji:(NSString *)text incoming:(BOOL)incoming;

- (instancetype)initWithPicture:(UIImage *)image incoming:(BOOL)incoming;

- (instancetype)initWithVideo:(NSString *)path duration:(NSInteger)duration incoming:(BOOL)incoming;

- (instancetype)initWithAudioData:(NSData *)data duration:(NSInteger)duration incoming:(BOOL)incoming;
- (instancetype)initWithAudioPath:(NSString *)path duration:(NSInteger)duration incoming:(BOOL)incoming;

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude incoming:(BOOL)incoming
			completion:(void (^)(void))completion;

@end
