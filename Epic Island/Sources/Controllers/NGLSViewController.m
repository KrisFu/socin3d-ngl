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
	UIProgressView        *_progress;
  CGPoint               _movement;
  CGFloat               _zoomDistance;
  CGFloat               _rotation;
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
  trans.x = _movement.x;
  trans.y = _movement.y;
  trans.z = _zoomDistance;
  
  float scale = 0.003;
  _camera.rotateY += _rotation;
  
    if (trans.z == 0)
    [_camera translateRelativeToX:trans.x * scale toY:-trans.y * scale toZ:0];
  else
    [_camera translateRelativeToX:0 toY:0 toZ:trans.z * scale];

  _movement = CGPointZero;
  _zoomDistance = 0;
  _rotation = 0;
  
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

  _movement = CGPointZero;
  
  UIButton *ASButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  ASButton.frame = CGRectMake(350, 50, 110, 32);
  [ASButton setTitle:@"AS" forState:UIControlStateNormal];
  ASButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  ASButton.tag = 0;
//  [self.view addSubview:ASButton];
  
  UIButton *COM1Button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  COM1Button.frame = CGRectMake(465, 50, 110, 32);
  [COM1Button setTitle:@"COM1" forState:UIControlStateNormal];
  COM1Button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  COM1Button.tag = 1;
//  [self.view addSubview:COM1Button];
  
  UIButton *COM2Button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  COM2Button.frame = CGRectMake(580, 50, 110, 32);
  [COM2Button setTitle:@"COM2" forState:UIControlStateNormal];
  COM2Button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  COM2Button.tag = 2;
//  [self.view addSubview:COM2Button];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Super call, must be called for a UIKit rule.
	[super touchesMoved:touches withEvent:event];

  UITouch *touchA, *touchB;
	CGPoint pointA, oldPointA;
  CGPoint movementA;

  touchA = [[event.allTouches allObjects] objectAtIndex:0];
  pointA = [touchA locationInView:self.view];
  oldPointA = [touchA previousLocationInView:self.view];

  movementA.x = (pointA.x - oldPointA.x);
  movementA.y = (pointA.y - oldPointA.y);

  if ([event.allTouches count] == 1)
    _movement = movementA;
	if ([event.allTouches count] == 2)
	{
    CGPoint pointB, oldPointB;
    CGPoint movementB;
    CGFloat distance, oldDistance;
    CGFloat slope, oldSlope;
    CGPoint relativeMovement;
    CGPoint AToBVector;
    
		touchB = [[event.allTouches allObjects] objectAtIndex:1];
    pointB = [touchB locationInView:self.view];
    oldPointB = [touchB previousLocationInView:self.view];

    movementB.x = (pointB.x - oldPointB.x);
    movementB.y = (pointB.y - oldPointB.y);

    relativeMovement.x = movementB.x - movementA.x;
    relativeMovement.y = movementB.y - movementA.y;

    AToBVector.x = oldPointB.x - oldPointA.x;
    AToBVector.y = oldPointB.y - oldPointA.y;

    if (((relativeMovement.x * relativeMovement.y >= 0) && (AToBVector.x * AToBVector.y >= 0)) //the 2 touches are in opposite directions, one in upper left, the other in bottom right
        || ((relativeMovement.x * relativeMovement.y <= 0) && (AToBVector.x * AToBVector.y <= 0))) //the 2 touches are in opposite directions, one in bottom left, the other in upper right
    {
      distance = distanceBetweenPoints(pointA, pointB);
      oldDistance = distanceBetweenPoints(oldPointA, oldPointB);
      _zoomDistance = distance - oldDistance;
    }
    else
    {
      if ((movementA.x * movementB.x >= 0) && (movementA.y * movementB.y >= 0))
      {
        //do nothing if both fingers are moving in the same direction
      }
      else //rotation
      {
        slope = (pointB.y - pointA.y) / (pointB.x - pointA.x);
        oldSlope = (oldPointB.y - oldPointA.y) / (oldPointB.x - oldPointA.x);

        if (slope > oldSlope)
          _rotation = 1;
        else
          _rotation = -1;
      }
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