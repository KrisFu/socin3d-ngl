/*
 *	NGLSAppDelegate.h
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/7/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "NGLSViewController.h"

@interface NGLSAppDelegate : UIResponder <UIApplicationDelegate>
{
	UIWindow *_window;
	NGLSViewController *_viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NGLSViewController *viewController;

@end

