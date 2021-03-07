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

@implementation RCMessage

-(instancetype)init {
    self = [super init]; if (!self) return nil;
    [self commonInit];
    return self;
}

-(void)commonInit {
    _bubble_backcolor = nil;
    _message_data = nil;
    _text = nil;
    _picture_image = nil;
    _picture_width = 0.0f;
    _picture_height = 0.0f;
    
    _video_path = nil;
    _video_thumbnail = nil;
    _video_duration = 0.0f;
    
    _audio_path = nil;
    _audio_duration = 0.0f;
    
    _location_thumbnail = nil;

}

#pragma mark - Initialization methods

- (instancetype)initWithStatus:(NSString *)text {
	self = [super init];
    [self commonInit];
    
    self.bubble_backcolor = nil;
    self.message_data = nil;
	

	self.type = RC_TYPE_STATUS;
	

	self.incoming = NO;
	self.outgoing = NO;
	

	self.text = [NSString stringWithString:text];
	

	return self;
}



- (instancetype)initWithText:(NSString *)text incoming:(BOOL)incoming {
	self = [super init];
    [self commonInit];
    
    self.type = RC_TYPE_TEXT;
	

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.text = [NSString stringWithString:text];
	

	return self;
}



- (instancetype)initWithEmoji:(NSString *)text incoming:(BOOL)incoming {
	self = [super init];
    [self commonInit];
    self.type = RC_TYPE_EMOJI;
	

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.text = [NSString stringWithString:text];
	

	return self;
}



- (instancetype)initWithPicture:(UIImage *)image incoming:(BOOL)incoming {
	self = [super init];
    [self commonInit];
    self.type = RC_TYPE_PICTURE;
	
    self.status = RC_STATUS_SUCCEED;

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.picture_image = image;
	self.picture_width = image.size.width;
	self.picture_height = image.size.height;
	

	return self;
}



- (instancetype)initWithVideo:(NSString *)path duration:(NSInteger)duration incoming:(BOOL)incoming
{
    self = [super init];
    [self commonInit];
    self.type = RC_TYPE_VIDEO;
	

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.video_path = path;
	self.video_duration = duration;
	

	return self;
}



- (instancetype)initWithAudioData:(NSData *)data duration:(NSInteger)duration incoming:(BOOL)incoming
{
    self = [super init];
[self commonInit];
    self.type = RC_TYPE_AUDIO;
    

    self.incoming = incoming;
    self.outgoing = !incoming;
    

    self.message_data = data;
    self.audio_duration = duration;
    self.audio_status = RC_AUDIOSTATUS_STOPPED;
    

    return self;
}


- (instancetype)initWithAudioPath:(NSString *)path duration:(NSInteger)duration incoming:(BOOL)incoming
{
	self = [super init];
[self commonInit];
    self.type = RC_TYPE_AUDIO;
	

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.audio_path = path;
	self.audio_duration = duration;
	self.audio_status = RC_AUDIOSTATUS_STOPPED;
	

	return self;
}


- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude incoming:(BOOL)incoming
			completion:(void (^)(void))completion


{
	self = [super init];
[self commonInit];
    self.type = RC_TYPE_LOCATION;
	

	self.incoming = incoming;
	self.outgoing = !incoming;
	

	self.latitude = latitude;
	self.longitude = longitude;

	self.status = RC_STATUS_LOADING;
	

	MKCoordinateRegion region;
	region.center.latitude = self.latitude;
	region.center.longitude = self.longitude;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	

	MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
	options.region = region;
	options.size = CGSizeMake([RCMessages locationBubbleWidth], [RCMessages locationBubbleHeight]);
	options.scale = [UIScreen mainScreen].scale;
	

	MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
	[snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
			  completionHandler:^(MKMapSnapshot *snapshot, NSError *error)
	{
		if (snapshot != nil)
		{
			UIGraphicsBeginImageContextWithOptions(snapshot.image.size, YES, snapshot.image.scale);
			{
				[snapshot.image drawAtPoint:CGPointZero];

				MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
				CGPoint point = [snapshot pointForCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude)];
				point.x += pin.centerOffset.x - (pin.bounds.size.width / 2);
				point.y += pin.centerOffset.y - (pin.bounds.size.height / 2);
				[pin.image drawAtPoint:point];

				self.location_thumbnail = UIGraphicsGetImageFromCurrentImageContext();
			}
			UIGraphicsEndImageContext();

			self.status = RC_STATUS_SUCCEED;
			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion != nil) completion();
			});
		}
	}];
	return self;
}

@end
