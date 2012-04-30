/*
 *	main.m
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/7/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "NGLSAppDelegate.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"NGLSAppDelegate");
	[pool release];
	return retVal;
}
