//
//  SceneSelectorViewController.m
//  Autista
//
//  Copyright (c) 2014 The Groden Center, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  To view the GNU General Public License, visit <http://www.gnu.org/licenses/>.
//

#import <QuartzCore/QuartzCore.h>
#import "AVAudioPlayer+Fade.h"
#import "SceneSelectorViewController.h"
#import "FirstLaunchViewController.h"
#import "SceneViewController.h"
#import "AdminViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "Scene.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"
#import "AutistaIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <Instabug/Instabug.h>


@interface SceneSelectorViewController () {
    NSArray *_products;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation SceneSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self loadScenes];
    _prefs = [GlobalPreferences sharedGlobalPreferences];

    if (!_prefs.betaTesting){
        //[self reload];
        self.unlockAllButton.hidden=YES;
        self.unlockAllButton.userInteractionEnabled=NO;
    }
    else {
        self.unlockAllButton.hidden=YES;
        self.unlockAllButton.userInteractionEnabled=NO;
    }
    //[[AutistaIAPHelper sharedInstance] restoreCompletedTransactions];
    
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
	NSInteger numScenes = [_scenes count];
    ratio = 0.75; // ratio for resizing
	CGSize size = self.view.bounds.size;										// coordinates are flipped at this point
	CGFloat temp = size.width;
	size.width = size.height;
	size.height = temp;
    
    //CGFloat initialOffset = size.width *(1-ratio) / 2;
    //CGFloat gap = initialOffset / 2;
    CGFloat imgWidth = ratio * size.width;
    CGFloat imgHeight = ratio * size.height;
	//_scrollView.contentSize = CGSizeMake(initialOffset*2 + numScenes * imgWidth + gap*(numScenes - 1), size.height);
    
	_scrollView.contentSize = CGSizeMake(numScenes * size.width, size.height);
	
	for (int i = 0; i < numScenes; i++) {
		Scene *scene = [_scenes objectAtIndex:i];
		UIImage *sceneImage = [UIImage imageWithData:scene.sceneSelectorImage];
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
		[button setImage:sceneImage forState:UIControlStateNormal];
		//button.center = CGPointMake( initialOffset + imgWidth*i + gap*i + imgWidth/2, size.height / 2);
		button.center = CGPointMake(size.width / 2 + i * size.width, size.height / 2);
        
		button.layer.borderColor = [[UIColor whiteColor] CGColor];
		button.layer.borderWidth = 10;
		button.layer.shadowColor = [[UIColor blackColor] CGColor];
		button.layer.shadowOffset = CGSizeMake(0, 0);
		button.layer.shadowOpacity = 0.5;
		button.layer.shadowRadius = 5;
		button.layer.masksToBounds = NO;
		button.clipsToBounds = NO;
		button.tag = i;
		
		[button addTarget:self action:@selector(handleSceneTapped:) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:button];
	
        //RD
        //Dont recognize by _products[i] but by name of scene and of IAP or some associative array??
        //Also here all scenes are locked - one scene or first scene shud be unlocked??
        if (i>0) {
            /*
             SKProduct * product = (SKProduct *) _products[i-1];
             NSLog(@"Found product in viewDidLoad: %@ %@ %0.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
            
            if (!([[AutistaIAPHelper sharedInstance] productPurchased:product.productIdentifier])) {
                NSLog(@"Setting locks for unpurchased product: %@ %@ %0.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
             */
             UIButton *lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
             UIImage *lockNormal = [UIImage imageNamed:@"BtnLockNormal.png"];
             UIImage *lockHighlighted = [UIImage imageNamed:@"BtnLockHighlighted.png"];
             //lockButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
             [lockButton setImage:lockNormal forState:UIControlStateNormal];
             [lockButton setImage:lockHighlighted forState:UIControlStateHighlighted];
             //lockButton.center = CGPointMake( initialOffset + imgWidth*i + gap*i + imgWidth/2, size.height / 2);
             lockButton.center = CGPointMake(size.width / 2 + i * size.width, size.height / 2);
             lockButton.tag = i+numScenes;
             [lockButton addTarget:self action:@selector(handleLockTapped:) forControlEvents:UIControlEventTouchUpInside];
             if (!_prefs.betaTesting)
                 [_scrollView addSubview:lockButton];
                //NSLog(@"added lockbutton with tag : %d, scene : %@", lockButton.tag, scene.title);
            //}
        }
        
	}
	
	_pageControl.numberOfPages = numScenes;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseBackgroundMusic) name:@"StartingSayTypePuzzle" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeBackgroundMusic) name:@"EndedSayTypePuzzle" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopBackgroundMusic) name:@"AdminWantsBackgroundMusicOffNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackgroundMusic) name:@"AdminWantsBackgroundMusicNotification" object:nil];
    
//    CGSize size = self.view.bounds.size;										// coordinates are flipped at this point
    activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    activityIndicator.center = CGPointMake(size.width / 2, size.height / 2);
    [self.view addSubview:activityIndicator];
    //NSLog(@"Added activity monitor to scrollview and now starting animation at coordinates : %f, %f", size.width / 2, size.height / 2);
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (_prefs.guidedModeEnabled == YES)								// most likely, admin changed this setting mid-stream
		[self dismissViewControllerAnimated:NO completion:nil];
	else {
		if (_selectedScene != nil) {
			NSInteger index = _selectedSceneButton.tag;
			CGSize size = _scrollView.frame.size;
			_selectedSceneButton.center = CGPointMake(size.width / 2 + index * size.width, size.height / 2);
			[_scrollView addSubview:_selectedSceneButton];
			
			[UIView animateWithDuration:0.5											// zoom back out
							 animations:^{
								 _selectedSceneButton.transform = CGAffineTransformIdentity;
							 }
							 completion:^(BOOL finished) {
								 _selectedSceneButton = nil;
								 _selectedScene = nil;
							 }
			 ];
		}
		else {
            _presentedScene = [_scenes objectAtIndex:0];
			[self initializeMusicPlayback:_presentedScene.sceneMusicFilename];
			[self playBackgroundMusic];
			
			[[EventLogger sharedLogger] logEvent:LogEventCodeScenePresented eventInfo:@{@"Scene": _presentedScene.title}];
		}
	}
}

- (void)reload {
    _products = nil;
    [[AutistaIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;

            //RD: enable lockButtons here - if disabled logic followed
            //RD: dealloc lockbutton etc / remove their targets n selectors on removing from view too?
            NSInteger numScenes = [_scenes count];
            //RD: i=1 hardcoed again .. shud be assciative array based (as to which scene is free)
//            if ([[AutistaIAPHelper sharedInstance] productPurchased:@"com.madratgames.testautista.unlockall"]) {
                self.unlockAllButton.hidden=YES;
                self.unlockAllButton.userInteractionEnabled=NO;

                for (int i = 1; i < numScenes; i++) {
                    //NSLog(@"In reload in unlockall removig lock from scene : %d", i);
                    UIView *v = [_scrollView viewWithTag:(i+numScenes)];
                    [v removeFromSuperview];
                }
//            }
//            else {
//                NSInteger unlockedScenes=0;
//                NSInteger numScenes = [_scenes count];
//
//                for (int i = 1; i < numScenes; i++) {
//                    SKProduct * product = (SKProduct *) _products[i-1];
//                    
//                    if ([[AutistaIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
//                        //NSLog(@"In reload .. removing lock for scene : %d", i);
//                        UIView *v = [_scrollView viewWithTag:(i+numScenes)];
//                        [v removeFromSuperview];
//                        unlockedScenes++;
//                    }
//                }
//                if (unlockedScenes > numScenes-3) {
//                    self.unlockAllButton.hidden=YES;
//                    self.unlockAllButton.userInteractionEnabled=NO;
//                }
            }
//        }
    }];
}

- (void)initializeMusicPlayback:(NSString *)audioFilename
{
	NSString* fileName = [[audioFilename lastPathComponent] stringByDeletingPathExtension];
	NSString* extension = [audioFilename pathExtension];
	
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:extension]];
	
	NSError *error;
	musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	musicPlayer.numberOfLoops = -1;														// negative to loop indefinitely, remember to call stop
	if (error) {
		TFLog(@"Error in musicPlayer: %@", [error localizedDescription]);
	}
	else {
		musicPlayer.delegate = self;
		musicPlayer.volume = 0.5;
		[musicPlayer prepareToPlay];
	}
}

- (void)playBackgroundMusic
{
	if (_prefs.backgroundMusicEnabled == YES) {
        //NSLog (@"Got Admin wants bg sound On notification (or in Scene Selector n BG Music on)");
		[musicPlayer playWithFadeDuration:1];
    }
}

- (void)stopBackgroundMusic {
    //NSLog (@"Admin wants bg sound Off notification");
	if (_prefs.backgroundMusicEnabled == NO) {
        //NSLog (@"Inside if of stopBgMusic notification");
		[musicPlayer stopWithFadeDuration:1];
    }
}

- (void)pauseBackgroundMusic {
    //NSLog (@"got Say start notification");
	if (_prefs.backgroundMusicEnabled == YES) {
        //NSLog (@"Inside if of pauseBgMusic notification");
		[musicPlayer stopWithFadeDuration:1];
    }
}

- (void)resumeBackgroundMusic {
    //NSLog (@"Got Say end notification");
	if (_prefs.backgroundMusicEnabled == YES)
		[musicPlayer playWithFadeDuration:1];
}

- (void)playMusicForScene:(Scene *)scene
{
	if (_prefs.backgroundMusicEnabled == YES) {
		[self initializeMusicPlayback:scene.sceneMusicFilename];
		[musicPlayer playWithFadeDuration:1];
	}
}

- (IBAction)infoTapped:(id)sender {
    //NSLog(@"Tapped Info button");
    
    //To test crashing in TestFlight
    //assert(! "crashing on purpose to test crash logs reporting.");
    AudioServicesPlaySystemSound(0x450);
    [TestFlight passCheckpoint:@"Info button Tapped"];

    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstLaunchViewController"];
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)feedbackTapped:(id)sender {
    //NSLog(@"Tapped Feedback button");
    AudioServicesPlaySystemSound(0x450);
    [TestFlight passCheckpoint:@"Feedback button Tapped"];

    [Instabug ShowFeedbackFormWithScreenshot:YES];
}

- (void)loadScenes
{
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Scene" inManagedObjectContext:context]];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
	[fetchRequest setSortDescriptors:sortDescriptors];

	_scenes = [context executeFetchRequest:fetchRequest error:nil];
}

- (void)handleSceneTapped:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	_selectedSceneButton = (UIButton *)sender;
	NSInteger index = _selectedSceneButton.tag;
	
	_selectedSceneButton.center = _scrollView.center;						// center in scrollview to reset x offset
	[self.view addSubview:_selectedSceneButton];							// move to top of view controller's view stack
	
	[UIView animateWithDuration:0.5											// zoom to full screen
					 animations:^{
						 _selectedSceneButton.transform = CGAffineTransformMakeScale(1.333, 1.333);
					 }
					 completion:^(BOOL finished) {
						 SceneViewController *sceneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SceneViewController"];
						 _selectedScene = [_scenes objectAtIndex:index];
						 sceneVC.scene = _selectedScene;
						 
						 [[EventLogger sharedLogger] logEvent:LogEventCodeSceneSelected eventInfo:@{@"Scene": _selectedScene.title}];
						 
						 [self presentModalViewController:sceneVC animated:NO];
					 }
	];
}

//RD
- (void)handleLockTapped:(id)sender
{
    // if reload is complete then execute else show msg of waiting or do waiting animation - but how to kill animation after sometime?
    AudioServicesPlaySystemSound(0x450);
    if (_products) {
        [activityIndicator startAnimating];

        _lockedSceneButton = (UIButton *)sender;
        NSInteger numScenes = [_scenes count];

        SKProduct *product = _products[(_lockedSceneButton.tag - numScenes) - 1];
        [[AutistaIAPHelper sharedInstance] buyProduct:product];

        //NSLog(@"Buying %@...", product.productIdentifier);
        /*dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        
        dispatch_async(queue, ^{
            [[AutistaIAPHelper sharedInstance] buyProduct:product];
            NSLog(@"Started dispatch_async");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Stopping dispatch_async");
                [activityIndicator stopAnimating];
            });
            
        });*/
    }
    //RD
    else {
        [self reload];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase list not ready." message:@"Please try after a few minutes! If problem persists, check your connection or restart the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert addButtonWithTitle:@"Yes"];
        [alert show];
        //NSLog(@"_products is empty so doing nothing. tap again after a while");
    }
}

- (IBAction)handleUnlockAllTapped:(id)sender {
    AudioServicesPlaySystemSound(0x450);
    if (_products) {
        [activityIndicator startAnimating];
        
        NSInteger numScenes = [_scenes count];
        SKProduct * product = (SKProduct *) _products[numScenes-1];
        [[AutistaIAPHelper sharedInstance] buyProduct:product];
    }
    //RD
    else {
        [self reload];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase list not ready." message:@"Please try after a few minutes! If problem persists, check your connection or restart the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}


//RD
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    //RD - interfering with other notifications (mainly BG music on/off etc)
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    //what if its already purchsed or user declines to buy - will below code still work? .. maybe put isAnimating ..
    NSRange match;
    match = [notification.object rangeOfString: @"Transaction Failed"];

    if (match.location == NSNotFound) {
        NSString * productIdentifier = notification.object;
        NSInteger numScenes = [_scenes count];
        
        if ([productIdentifier isEqualToString:@"com.madratgames.testautista.unlockall"]) {
            self.unlockAllButton.hidden=YES;
            self.unlockAllButton.userInteractionEnabled=NO;

            for (int i = 1; i < numScenes; i++) {
                TFLog(@"In unlockall in productPurchased .. Removing lock for product with id : %@ and tag : %d", productIdentifier, (i+numScenes));
                UIView *v = [_scrollView viewWithTag:(i+numScenes)];
                [v removeFromSuperview];
            }
        }
        else {
            NSInteger unlockedScenes=0;
            NSInteger numScenes = [_scenes count];

            for (int i = 1; i < numScenes; i++) {
                SKProduct * product = (SKProduct *) _products[i-1];

                if ([product.productIdentifier isEqualToString:productIdentifier]) {
                    TFLog(@"Removing lock for product with id : %@ and tag : %d", productIdentifier, (i+numScenes));
                    UIView *v = [_scrollView viewWithTag:(i+numScenes)];
                    [v removeFromSuperview];
                    unlockedScenes++;
                }
            }
            if (unlockedScenes > numScenes-3) {
                self.unlockAllButton.hidden=YES;
                self.unlockAllButton.userInteractionEnabled=NO;
            }
        }
    }
    else {
        NSString * msg;
        msg = [notification.object stringByReplacingOccurrencesOfString:@"Transaction Failed " withString:@""];
        if (![msg isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alert addButtonWithTitle:@"Ok"];
            [alert show];
        }
    }
    [activityIndicator stopAnimating];
}

#pragma mark - ScrollViewDelegate Methods

- (void)scrollToPage:(int)page
{
    if (page < 0) return;
    if (page >= _pageControl.numberOfPages) return;

	CGRect frame = _scrollView.frame;
/*
    CGFloat initialOffset = frame.size.width *(1-ratio) / 2;
    CGFloat gap = initialOffset / 2;
    CGFloat imgWidth = ratio * frame.size.width;
    CGFloat pageStart = initialOffset +imgWidth * (page -1) +  gap * (page-1) + imgWidth-gap;
*/
	CGPoint newPoint = CGPointMake(frame.size.width * page, 0);
    //CGPoint newPoint = CGPointMake(pageStart, 0);

	[_scrollView setContentOffset:newPoint animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	
	if (_pageControlUsed) {													 // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }

    CGFloat pageWidth = _scrollView.frame.size.width;						// Switch the indicator when more than 50% of the previous/next page is visible
    /*CGFloat initialOffset = pageWidth *(1-ratio) / 2;
    CGFloat gap = initialOffset / 2;
    */
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	//int page = floor(_scrollView.contentOffset.x / (pageWidth * ratio + gap)) + 1;
    //NSLog(@"Page : %d", page);
	if (page < 0) return;
	if (page >= _pageControl.numberOfPages) return;
    
    [self checkNextPrev:page];
   
	_pageControl.currentPage = page;
    //_pageControlUsed = YES;
    //[self scrollToPage:page];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_pageControlUsed = NO;													// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
	
	Scene *scene = [_scenes objectAtIndex:_pageControl.currentPage];
	
	if (scene != _presentedScene) {											// if we are presenting a different scene than last time around,
		_presentedScene = scene;											// switch the music
		
		[musicPlayer stopWithFadeDuration:1];
		[self performSelector:@selector(playMusicForScene:) withObject:scene afterDelay:1.5];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodeScenePresented eventInfo:@{@"Scene": _presentedScene.title}];
	}
}

- (IBAction)changePage:(id)sender
{
    int page = _pageControl.currentPage;
    _pageControlUsed = YES;													// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.

	CGRect frame = _scrollView.frame;										// update the scroll view to the appropriate page
    
    /*CGFloat initialOffset = frame.size.width *(1-ratio) / 2;
    CGFloat gap = initialOffset / 2;
    CGFloat imgWidth = ratio * frame.size.width;
    CGFloat pageStart = initialOffset +imgWidth * (page -1) +  gap * (page-1) + imgWidth-gap;
 
    [self scrollToPage:page];
    CGPoint newPoint = CGPointMake(pageStart, 0);
	[_scrollView setContentOffset:newPoint animated:YES];
*/
    [self scrollToPage:page];
    [self checkNextPrev:page];

    frame.origin.x = frame.size.width * page;
    //frame.origin.x  = pageStart;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

-(void) checkNextPrev:(int) page {
    NSInteger numScenes = [_scenes count];

    if (page == 0) {
        self.prevButton.hidden = YES;
        self.nextButton.hidden = NO;
    }
    if ((page > 0) && (page < numScenes-1)) {
        self.prevButton.hidden = NO;
        self.nextButton.hidden = NO;
    }
    if (page == numScenes-1) {
        self.prevButton.hidden = NO;
        self.nextButton.hidden = YES;
    }
}

- (IBAction)prevTapped:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
    //unhide next whenever its tapped
    self.nextButton.hidden=NO;

    _pageControl.currentPage--;
    int page = _pageControl.currentPage;
    _pageControlUsed = YES;

	CGRect frame = _scrollView.frame;
    [self scrollToPage:page];
    [self checkNextPrev:page];

    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)nextTapped:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
    //unhide prev whenever its tapped
    self.prevButton.hidden=NO;
    
    _pageControl.currentPage++;
    int page = _pageControl.currentPage;
    _pageControlUsed = YES;
    
 	CGRect frame = _scrollView.frame;
    [self scrollToPage:page];
    [self checkNextPrev:page];

    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)handleAdminButtonPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	_adminOverlayTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showAdminOverlay) userInfo:nil repeats:NO];
}

- (IBAction)handleAdminButtonReleased:(id)sender
{
	[_adminOverlayTimer invalidate];
}

- (void)showAdminOverlay
{
	[_adminOverlayTimer invalidate];
	
	AdminViewController *adminVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdminViewController"];
	[self presentViewController:adminVC animated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeRight;
//}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
