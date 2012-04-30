/*
 *	NGLSMovementView.m
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/8/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import "NGLSMovementView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLSMovementView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic innerPosition, outerPosition, touch, movement;

- (CGPoint) innerPosition { return _viewIn.center; }
- (void) setInnerPosition:(CGPoint)value
{
	// Corrects the center in relation to this view.
	CGPoint newCenter = CGPointMake(value.x - self.frame.origin.x, value.y - self.frame.origin.y);
	CGPoint origin = _viewOut.center;
	float angle;
	
	// Limits the movements inside the big circle.
	if (distanceBetweenPoints(newCenter, origin) > _radius)
	{
		// Angle of the newCenter in relation to the origin.
		// This angle will be used to calculate the X and Y around the circle edge.
		angle = atan2f(newCenter.y - origin.y, newCenter.x - origin.x);
		newCenter = CGPointMake(origin.x + _radius * cosf(angle), origin.y + _radius * sinf(angle));
	}
	
	_viewIn.center = newCenter;
}

- (CGPoint) outerPosition { return self.center; }
- (void) setOuterPosition:(CGPoint)value
{
	// Just work when the touch is not set.
	if (_touch == nil)
	{
		self.center = value;
	}
}

- (UITouch *) touch { return _touch; }
- (void) setTouch:(UITouch *)value
{
	// Holds a touch and just enable changes when the old touch is discarded (set to nil).
	if (_touch == nil || value == nil)
	{
		_touch = value;
		_viewIn.center = _viewOut.center;
	}
}

- (NGLvec2) movement
{
	NGLvec2 moveVector = kNGLvec2Zero;
	
	// Just return the movement if a touch is happening.
	if (_touch != nil)
	{
		// Getting the circle positions.
		CGPoint smallCircle = _viewIn.center;
		CGPoint bigCircle = _viewOut.center;
		float scalarDistance = distanceBetweenPoints(smallCircle, bigCircle) / _radius;
		float angle;
		
		// Calculating the angle of the touch in relation to the center of the outer circle
		angle = atan2f(smallCircle.y - bigCircle.y, smallCircle.x - bigCircle.x);
		
		// Gets the scalar sin and cos, which is already normalized to [-1.0, 1.0].
		// Then multiply by the scalar distance of the center of the circle.
		// It works like and acceleration factor.
		float xAcceleration = -sinf(angle) * scalarDistance;
		float yAcceleration = cosf(angle) * scalarDistance;
		
		moveVector = (NGLvec2) {xAcceleration, yAcceleration};
	}
	
	return moveVector;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		UIImage *imageIn = [UIImage imageNamed:@"move_control_in.png"];
		UIImage *imageOut = [UIImage imageNamed:@"move_control_out.png"];
		
		_viewIn = [[UIImageView alloc] initWithImage:imageIn];
		_viewOut = [[UIImageView alloc] initWithImage:imageOut];
		
		// Settings.
		self.frame = _viewOut.frame;
		_viewIn.center = _viewOut.center;
		_radius = _viewOut.frame.size.width * 0.5f;
		
		[self addSubview:_viewIn];
		[self addSubview:_viewOut];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	[_viewIn release];
	[_viewOut release];
	
	[super dealloc];
}

@end
