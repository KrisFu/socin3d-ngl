/*
 *	NGLSMovementView.h
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/8/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "NGLSRuntime.h"

@interface NGLSMovementView : UIView
{
@private
	float					_radius;
	UIImageView				*_viewIn, *_viewOut;
	UITouch					*_touch;
}

@property (nonatomic) CGPoint innerPosition;
@property (nonatomic) CGPoint outerPosition;
@property (nonatomic, assign) UITouch *touch;
@property (nonatomic, readonly) NGLvec2 movement;

@end