/*
 *	NGLSViewController.m
 *	Epic Island
 *	
 *	Created by Diney Bomfim on 1/7/12.
 *	Copyright 2012 DB-Interactive. All rights reserved.
 */

#import "NGLSViewController.h"
#define MESH_SCALE        0.005

@interface NGLSViewController()

- (IBAction)onBtnLevel:(id)sender;
- (BOOL)isShowingLevel:(NSString*)levelName;
- (void)showLevel:(NSString*)levelName;
- (void)hideLevel:(NSString*)levelName;
@end

@implementation NGLSViewController
{
  NSMutableArray        *_levelNameArray;
	NGLMesh               *_groundMesh;
	NGLCamera             *_camera;
	NGLSMovementView      *_left, *_right;
	UIProgressView        *_progress;
  CGPoint               _movementA;
//  CGPoint               _oldPointA;
  CGPoint               _movementB;
//  CGPoint               _oldPointB;
  CGPoint               _touchStartPointA;
  CGPoint               _touchStartPointB;

  CGFloat               _distance;
  CGFloat               _oldDistance;
}

typedef enum
{
  upRight,
  upLeft,
  downLeft,
  downRight
} Direction;

- (void) drawView
{
	//*************************
	//	NinevehGL Stuff
	//*************************
	// Getting the scalar movement from the controls
	NGLvec3 trans;
  trans.x = _movementA.x;
  trans.y = _movementA.y;
  
	NGLvec2 pan;
  pan.x = 0;
  pan.y = 0;

  if ((_movementA.x * _movementB.x < 0) && (_movementA.y * _movementB.y < 0))
    trans.z = _movementA.x;
  else if(!(CGPointEqualToPoint(_movementB, CGPointZero)))// if (!((_movementA.x * _movementB.x > 0) && (_movementA.y * _movementB.y > 0)))
  {
//    Direction directionA, directionB;
    BOOL isClockwise;
    
//    if (_movementA.x > 0)
//    {
//      if (_movementA.y > 0)
//        directionA = upRight;
//      else
//        directionB = downRight;
//    }
//    else
//    {
//      if (_movementA.y > 0)
//        directionA = upLeft;
//      else
//        directionA = downLeft;
//    }
//    
    if (_movementB.x > 0)
    {
      if (_movementB.y > 0)
        isClockwise = NO;
//        directionA = upRight;
      else
        isClockwise = YES;
//        directionB = downRight;
    }
    else
    {
      if (_movementB.y > 0)
        isClockwise = NO;
//        directionA = upLeft;
      else
        isClockwise = YES;
//        directionA = downLeft;
    }
    
    NSLog(@"%d", isClockwise);
    
    if (isClockwise)
    {
      pan.x = 1;
      pan.y = 1;
    }
    else
    {
      pan.x = -1;
      pan.y = -1;
    }
  }
  
	// Updating the camera rotations

//  _camera.rotateY += trans.x;
//  _camera.rotateX += trans.y;

//  NSLog(@"%f", _camera.rotateX);

	// Updating the camera movement
  float scale = 0.003;

  if (pan.x != 0)
    _camera.rotateY += pan.x;
  else if (trans.z == 0)
    [_camera translateRelativeToX:trans.x * scale toY:-trans.y * scale toZ:0];
  else
    [_camera translateRelativeToX:0 toY:0 toZ:trans.z * scale];

//  _camera.rotateY += pan.x * scale;
//	_camera.rotateX += pan.y * scale;

  _movementA = CGPointZero;
  _movementB = CGPointZero;

	[_camera drawCamera];
}

- (void) meshLoadingWillStart:(NGLParsing)parsing
{
	// Initializing the Progress Bar class from UIKit.
	CGSize size = self.view.bounds.size;
	_progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	_progress.frame = CGRectMake(20, size.height * 0.6f, size.width - 40, 20);
	
	[self.view addSubview:_progress];
}

- (void) meshLoadingProgress:(NGLParsing)parsing
{
	// Updating the progress percentage.
	_progress.progress = parsing.progress;
}

- (void) meshLoadingDidFinish:(NGLParsing)parsing
{
	// Removing the Progress Bar.
	_progress.progress = parsing.progress;
	[_progress removeFromSuperview];
	nglRelease(_progress);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) loadView
{
	// Following the UIKit specifications, this method should not call the super.
	
	// Creates the NGLView manually, with the screen's size and sets the delegate.
	NGLView *nglView = [[NGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nglView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	nglView.delegate = self;
	
	// Sets the NGLView as the root view of this View Controller hierarchy.
	self.view = nglView;
	
	[nglView release];
}

- (void) viewDidLoad
{
	// Super call, must be called for a UIKit rule.
	[super viewDidLoad];
	
	self.view.multipleTouchEnabled = YES;
  
  _levelNameArray = [[NSMutableArray alloc] init];
  [_levelNameArray addObject:@"AS6_ROOF"];
  [_levelNameArray addObject:@"AS6_L5"];
  [_levelNameArray addObject:@"AS6_L4"];
  [_levelNameArray addObject:@"AS6_L3"];
  [_levelNameArray addObject:@"AS6_L2"];
  [_levelNameArray addObject:@"AS6_L1"];
  
  [_levelNameArray addObject:@"COM1_ROOF"];
  [_levelNameArray addObject:@"COM1_L3"];
  [_levelNameArray addObject:@"COM1_L2"];
  [_levelNameArray addObject:@"COM1_L1"];
  [_levelNameArray addObject:@"COM1_B1"];
  
  [_levelNameArray addObject:@"COM2_L4"];
  [_levelNameArray addObject:@"COM2_L3"];
  [_levelNameArray addObject:@"COM2_L2"];
  [_levelNameArray addObject:@"COM2_L1"];
  [_levelNameArray addObject:@"COM2_B1"];
	
	//*************************
	//	NinevehGL Stuff
	//*************************
	// Setting up some global adjusts.
	nglGlobalLightEffects(NGLLightEffectsOFF);
  nglGlobalAntialias(NGLAntialiasNone);
  nglGlobalFlush();
		
  float scale = MESH_SCALE;
	_groundMesh = [[NGLMesh alloc] initWithFile:@"SPL.dae" settings:nil delegate:self];
  _groundMesh.scaleX = scale;
  _groundMesh.scaleY = scale;
  _groundMesh.scaleZ = scale;
	
	// Initializing the camera and placing it into a good initial position.
  if (_groundMesh != nil)       _camera = [[NGLCamera alloc] initWithMeshes:_groundMesh, nil];
  else                          _camera = [[NGLCamera alloc] init];
	_camera.y = 0.7;
	_camera.rotateX = -35;
  
  [self performSelector:@selector(showLevel:) withObject:@"COM1_L1" afterDelay:1];
  [self performSelector:@selector(showLevel:) withObject:@"COM2_L1" afterDelay:2];
  [self performSelector:@selector(showLevel:) withObject:@"AS6_L1" afterDelay:3];
    
  // The buttons
  int btnWidth = 110;
  int btnHeight = 32;
  int btnSpacing = 5;
  int rowIndex = 0;
  int colIndex = 0;
  int prevColIndex = 0;
  for (int i=0; i < _levelNameArray.count; i++)
  {
    //indexing
    NSString *levelName = [_levelNameArray objectAtIndex:i];
    colIndex = 0;
    if ([levelName hasPrefix:@"COM1"])        colIndex = 1;
    else if ([levelName hasPrefix:@"COM2"])   colIndex = 2;
    if (colIndex != prevColIndex) {
      rowIndex = 0;
      prevColIndex = colIndex;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:levelName forState:UIControlStateNormal];
    button.frame = CGRectMake(btnSpacing + colIndex*(btnSpacing+btnWidth), 45+btnSpacing + rowIndex*(btnSpacing+btnHeight), btnWidth, btnHeight);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;    
    [button addTarget:self action:@selector(onBtnLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    BOOL isShowing = [self isShowingLevel:levelName];
    button.alpha = isShowing ? 1.0 : 0.4;
    
    rowIndex++;
  }
  
	// Starts the debug monitor
	[[NGLDebug debugMonitor] startWithView:(NGLView *)self.view];

  _movementA = CGPointZero;
//  _oldPointA = CGPointZero;
  _movementB = CGPointZero;
//  _oldPointB = CGPointZero;
  _touchStartPointA = CGPointZero;
  _touchStartPointB = CGPointZero;
}

- (void) viewDidAppear:(BOOL)animated
{
	// Super call, must be called for a UIKit rule.
	[super viewDidAppear:animated];
	
	// Setting the right and left control areas. They are circular areas near to the screen's corners.
	CGSize size = self.view.bounds.size;
	CGPoint leftCorner = CGPointMake(50, size.height - 50);
	CGPoint rightCorner = CGPointMake(size.width - 50, size.height - 50);
	float radius = size.width * 0.2f;
	
	// Placing the controllers at the screen, if necessary.
	if (_left == nil &&  _right == nil)
	{
		_left = [[NGLSMovementView alloc] init];
		_right = [[NGLSMovementView alloc] init];
		_left.outerPosition = CGPointMake(leftCorner.x + radius * 0.5f, leftCorner.y - radius * 0.5);
		_right.outerPosition = CGPointMake(rightCorner.x - radius * 0.5f, rightCorner.y - radius * 0.5);
		
//		[self.view addSubview:_left];
//		[self.view addSubview:_right];
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Super call, must be called if we have no plans to override all touch methods, it's an UIKit rule.
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch;
	CGPoint point;
	
	// Setting the right and left control areas. They are circular areas near to the screen's corners.
	CGSize size = self.view.bounds.size;
//	CGPoint leftCorner = CGPointMake(50, size.height - 50);
//	CGPoint rightCorner = CGPointMake(size.width - 50, size.height - 50);
//	float radius = size.width * 0.2f;

	for (touch in touches)
	{
		// Getting the touch position.
		point = [touch locationInView:self.view];

    if ((_touchStartPointA.x == 0) && (_touchStartPointA.y == 0))
      _touchStartPointA = point;
    else
      _touchStartPointB = point;

		// Calculating if the current touch position is inside the circular control area.
//		if (distanceBetweenPoints(point, leftCorner) <= radius)
//		{
//			_left.outerPosition = point;
//			_left.touch = touch;
//		}
//		else if (distanceBetweenPoints(point, rightCorner) <= radius)
//		{
//			_right.outerPosition = point;
//			_right.touch = touch;
//		}
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Super call, must be called for a UIKit rule.
	[super touchesMoved:touches withEvent:event];
	
  UITouch *touchA, *touchB;
	CGPoint pointA, oldPointA;

  touchA = [[touches allObjects] objectAtIndex:0];
  pointA = [touchA locationInView:self.view];
  oldPointA = [touchA previousLocationInView:self.view];

  _movementA.x = (pointA.x - oldPointA.x);
  _movementA.y = (pointA.y - oldPointA.y);

	// Pinch gesture.
	if ([touches count] == 2)
	{
    CGPoint pointB, oldPointB;
		touchB = [[touches allObjects] objectAtIndex:1];
    pointB = [touchB locationInView:self.view];
    oldPointB = [touchB previousLocationInView:self.view];

    _movementB.x = (pointB.x - oldPointB.x);
    _movementB.y = (pointB.y - oldPointB.y);

    CGPoint tempPoint;
    if (_touchStartPointA.x > _touchStartPointB.x)
    {
      tempPoint = _movementA;
      _movementA = _movementB;
      _movementB = tempPoint;
    }
    
	}

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Super call, must be called for a UIKit rule.
	[super touchesEnded:touches withEvent:event];

  _touchStartPointA = CGPointZero;
  _touchStartPointB = CGPointZero;
	
	UITouch *touch;
	
	for (touch in touches)
	{
		// Reseting the touch control.
		if (_left.touch == touch)
		{
			_left.touch = nil;
		}
		else if (_right.touch == touch)
		{
			_right.touch = nil;
		}
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	// Just allow rotations on Landscape mode.
	if (UIDeviceOrientationIsLandscape(orientation))
	{
		[_camera adjustToScreenAnimated:NO];
		return YES;
	}
	
	return NO;
}

- (void) dealloc
{
	[_groundMesh release];
	[_camera release];
	
	[super dealloc];
}




//
// Called when a level button is pressed
//
- (IBAction)onBtnLevel:(id)sender
{
  if (![sender isKindOfClass:[UIButton class]])
    return;
  UIButton *button = (UIButton*)sender;
  NSString *levelName = [button titleLabel].text;
  BOOL isShowing = [self isShowingLevel:levelName];
  
  if (isShowing)    [self hideLevel:levelName];
  else              [self showLevel:levelName];
  
  isShowing = !isShowing;
  [UIView animateWithDuration:0.3 animations:^{
    button.alpha = isShowing ? 1.0 : 0.4;
  }];
}

- (BOOL)isShowingLevel:(NSString*)levelName
{
  NSString *fileName = [NSString stringWithFormat:@"%@.dae", levelName];
  for (NGLMesh *mesh in _camera.allMeshes) {
    if (![[mesh.fileNamed lowercaseString] isEqualToString:[fileName lowercaseString]])
      continue;
    return YES;
  }
  return NO;
}

- (void)hideLevel:(NSString*)levelName
{
  if (![self isShowingLevel:levelName])
    return;
  
  NSString *fileName = [NSString stringWithFormat:@"%@.dae", levelName];
  for (NGLMesh *mesh in _camera.allMeshes) {
    if (![[mesh.fileNamed lowercaseString] isEqualToString:[fileName lowercaseString]])
      continue;
    [_camera removeMesh:mesh];
    break;
  }
  
  for (UIButton* subview in self.view.subviews)
  {
    if (![subview isKindOfClass:[UIButton class]])
      continue;
    if (![subview.titleLabel.text isEqualToString:levelName])
      continue;
    subview.alpha = 0.4;
    break;
  }
  
  //Special case
  if ([levelName isEqualToString:@"COM1_L1"])
    [_camera removeMesh:_groundMesh];
}

- (void)showLevel:(NSString*)levelName
{
  if ([self isShowingLevel:levelName])
    return;
  
  //Load new one
  NSString *fileName = [NSString stringWithFormat:@"%@.dae", levelName];
  NGLMesh *mesh = [[NGLMesh alloc] initWithFile:fileName settings:nil delegate:nil];
  float scale = MESH_SCALE;
  mesh.scaleX = scale;
  mesh.scaleY = scale;
  mesh.scaleZ = scale;
  
  [_camera addMesh:mesh];
  [mesh release];
  
  for (UIButton* subview in self.view.subviews)
  {
    if (![subview isKindOfClass:[UIButton class]])
      continue;
    if (![subview.titleLabel.text isEqualToString:levelName])
      continue;
    subview.alpha = 1;
    break;
  }
  
  //Special case
  if ([levelName isEqualToString:@"COM1_L1"])
    [_camera addMesh:_groundMesh];
}

@end