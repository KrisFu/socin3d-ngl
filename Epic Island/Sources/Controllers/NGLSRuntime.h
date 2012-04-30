/*
 *	NGLSRuntime.h
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/9/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import <Foundation/Foundation.h>

static inline float distanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
	float xDistace = fabs(pointA.x - pointB.x);
	float yDistance = fabs(pointA.y - pointB.y);
	
	return sqrt(xDistace * xDistace + yDistance * yDistance);
}