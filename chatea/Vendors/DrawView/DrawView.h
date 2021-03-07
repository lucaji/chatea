//
//  DrawView.h
//  DrawView
//
//  Created by Frank Michael on 4/8/14.
//  Updated by lucaji on 20170420.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface DrawView : UIView


/// Stroke Color
@property (nonatomic) UIColor *strokeColor;
/// Stroke width
@property (nonatomic) CGFloat strokeWidth;
/// If the drawing view can be drawn on. By default canEdit is true.
@property (nonatomic) BOOL canEdit;
/// Debug value to add a box around the path when drawing a existing path.
@property (nonatomic) BOOL debugBox;
/// Refresh the current drawing mode.
- (void)refreshCurrentMode;
/// Draw a CGPath that already exists. canEdit is set to false if this is called.
- (void)drawPath:(CGPathRef)path;
/// Draw a UIBezierPath that already exists. canEdit is set to false if this is called.
- (void)drawBezier:(UIBezierPath *)path;
/// Animate the current path.
- (void)animatePath;

/// Clear current drawing view.
- (void)clearDrawing;
- (void)undoDrawing;

/// Current UIBezierPath
- (UIBezierPath *_Nullable)bezierPathRepresentation;
/// Current UIImage of drawing view
- (UIImage *_Nullable)imageRepresentation;
/// flagged when has been modified
@property (nonatomic) BOOL wasEdited;
@end

NS_ASSUME_NONNULL_END
