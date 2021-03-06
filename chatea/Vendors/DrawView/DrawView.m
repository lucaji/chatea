//
//  DrawView.m
//  DrawView
//
//  Created by Frank Michael on 4/8/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "DrawView.h"

@interface DrawView () <CAAnimationDelegate> {
    NSMutableArray *paths;
    UIBezierPath *bezierPath;
    CAShapeLayer *animateLayer;
    BOOL isAnimating;
    BOOL isDrawingExisting;
}
@end

@implementation DrawView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setupUI];
    }
    return self;
}
#pragma mark - UI Configuration
- (void)setupUI{
    // Array of all the paths the user will draw.
    paths = [NSMutableArray new];
    // Default colors for drawing.
    self.backgroundColor = [UIColor whiteColor];
    _strokeColor = [UIColor blackColor];
    _canEdit = YES;
    _wasEdited = NO;
}
- (void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor = strokeColor;
}
#pragma mark - View Drawing
- (void)drawRect:(CGRect)rect{
    // Drawing code
    if (!isAnimating){
        [_strokeColor setStroke];
        if (!isDrawingExisting){
            // Need to merge all the paths into a single path.
            for (UIBezierPath *path in paths){
                [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
            }
        }else{
            [bezierPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
        }
    }
}

- (void)drawPath:(CGPathRef)path{
    isDrawingExisting = YES;
    _canEdit = NO;
    bezierPath = [UIBezierPath new];
    bezierPath.CGPath = path;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineWidth = _strokeWidth;
    bezierPath.miterLimit = 0.0f;
    // If iPad apply the scale first so the paths bounds is in its final state.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        [bezierPath setLineWidth:_strokeWidth];
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(2, 2);
        [bezierPath applyTransform:scaleTransform];
    }

//    // Center the drawing within the view.
//    CGRect charBounds = bezierPath.bounds;
//    CGFloat charX = CGRectGetMidX(charBounds);
//    CGFloat charY = CGRectGetMidY(charBounds);
//    CGRect cellBounds = self.bounds;
//    CGFloat centerX = CGRectGetMidX(cellBounds);
//    CGFloat centerY = CGRectGetMidY(cellBounds);
//    
//    [bezierPath applyTransform:CGAffineTransformMakeTranslation(centerX-charX, centerY-charY)];

    [self setNeedsDisplay];
    
    // Debugging bounds view.
    if (_debugBox){
        UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(bezierPath.bounds.origin.x, bezierPath.bounds.origin.y, bezierPath.bounds.size.width, bezierPath.bounds.size.height)];
        [blockView setBackgroundColor:[UIColor blackColor]];
        [blockView setAlpha:0.5];
        [self addSubview:blockView];
    }
}
- (void)drawBezier:(UIBezierPath *)path{
    [self drawPath:path.CGPath];
}
- (void)undoDrawing {
    [paths removeLastObject];
    [self setNeedsDisplay];
}


- (void)refreshCurrentMode{
    [self setNeedsDisplay];
}

- (void)clearDrawing {
    bezierPath = nil;
    paths = nil;
    [self setNeedsDisplay];
    [self setupUI];
}
#pragma mark - View Draw Reading
- (UIImage *)imageRepresentation{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
- (UIBezierPath * _Nullable)bezierPathRepresentation{
    if (bezierPath == nil || paths.count == 0) return nil;
    if (paths.count > 0) {
        UIBezierPath *singleBezPath = [UIBezierPath new];
        for (UIBezierPath *path in paths){
            [singleBezPath appendPath:path];
        }
        return singleBezPath;
    }
    return bezierPath;
}
#pragma mark - Animation
- (void)animatePath{
    UIBezierPath *animatingPath = [UIBezierPath new];
    if (_canEdit){
        for (UIBezierPath *path in paths){
            [animatingPath appendPath:path];
        }
    }else{
        animatingPath = bezierPath;
    }
    // Clear out the existing view.
    isAnimating = YES;
    [self setNeedsDisplay];
    // Create shape layer that stores the path.
    animateLayer = [[CAShapeLayer alloc] init];
    animateLayer.fillColor = nil;
    animateLayer.path = animatingPath.CGPath;
    animateLayer.strokeColor = [_strokeColor CGColor];
    animateLayer.lineWidth = _strokeWidth;
    animateLayer.miterLimit = 0.0f;
    animateLayer.lineCap = @"round";
    // Create animation of path of the stroke end.
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.duration = 3.0;
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.delegate = self;
    [animateLayer addAnimation:animation forKey:@"strokeEnd"];
    [self.layer addSublayer:animateLayer];
}
#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    isAnimating = NO;
    [animateLayer removeFromSuperlayer];
    animateLayer = nil;
    [self setNeedsDisplay];
}
#pragma mark - Touch Detecting
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_canEdit){
        _wasEdited = YES;
        bezierPath = [[UIBezierPath alloc] init];
        [bezierPath setLineCapStyle:kCGLineCapRound];
        [bezierPath setLineWidth:_strokeWidth];
        [bezierPath setMiterLimit:0];
        
        UITouch *currentTouch = [[touches allObjects] objectAtIndex:0];
        [bezierPath moveToPoint:[currentTouch locationInView:self]];
        [paths addObject:bezierPath];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_canEdit){
        _wasEdited = YES;
        UITouch *movedTouch = [[touches allObjects] objectAtIndex:0];
        [bezierPath addLineToPoint:[movedTouch locationInView:self]];
        [self setNeedsDisplay];
    }
}

@end
