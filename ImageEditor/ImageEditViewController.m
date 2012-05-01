//
//  ImageEditViewController.m
//  CybCommAudit
//
//  Created by USER on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageEditViewController.h"
#import "ViewController.h"

@implementation ImageEditViewController
@synthesize SelectedImage,PhotoTitle;
@synthesize FirstTimeInit,CurvesData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)Back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)AddLastCurve
{
    if([points count]>0)
    {
        [allDrawings addObject:points];
        [allDrawingsColor addObject:currentColor];
        points = [[NSMutableArray alloc] init];
    }
}

- (void)save
{
#ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving Image";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
    
        [self AddLastCurve];
        ViewController *parent = (ViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
        
        parent.SelectedImage = SelectedImage;
        parent.CurvesData = [curveConverter ConvertToStringFromArray:allDrawings Colors:allDrawingsColor];
        parent.EditPhotoComplete = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [navController popViewControllerAnimated:YES];
        });
    }); 
#endif
    
}

-(void) detectOrientation {
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        CGRect rect = myScrollView.frame;
        rect.origin.y = 0;
        rect.size.width = 480;
        rect.size.height = 225;
        myScrollView.frame = rect;
        
        [myScrollView setContentSize:CGSizeMake(480.0, 364.0)];
        myScrollView.showsHorizontalScrollIndicator = FALSE;
        myScrollView.showsVerticalScrollIndicator = FALSE;
        myScrollView.scrollEnabled = TRUE;
        myScrollView.bounces = FALSE;
    } else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        CGRect rect = myScrollView.frame;
        rect.size.width = 320;
        rect.size.height = 380;
        myScrollView.frame = rect;
        
        [myScrollView setContentSize:CGSizeMake(320.0, 364.0)];
        myScrollView.showsHorizontalScrollIndicator = FALSE;
        myScrollView.showsVerticalScrollIndicator = FALSE;
        myScrollView.scrollEnabled = FALSE;
        myScrollView.bounces = FALSE;
    }  
    
    CGFloat btnX = floor((myScrollView.frame.size.width - 3 * 63 - 4)/2);
    CGRect rect = btnChangeColor.frame;
    rect.origin.x = btnX;
    btnChangeColor.frame = rect;
    btnX = btnX + btnChangeColor.frame.size.width + 2;
    
    rect = btnErrasAll.frame;
    rect.origin.x = btnX;
    btnErrasAll.frame = rect;
    btnX = btnX + btnErrasAll.frame.size.width + 2;
    
    rect = btnUndoChange.frame;
    rect.origin.x = btnX;
    btnUndoChange.frame = rect;
    
    rect = imgPhoto.frame;
    rect.origin.x = (myScrollView.frame.size.width - rect.size.width)/2;
    imgPhoto.frame = rect;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentLastCurveIndex = 0;
    currentColor = [UIColor redColor]; 
    ScrollViewScrolling = FALSE;
    DrawingImage = FALSE;
    allDrawings = [[NSMutableArray alloc] init];
    allDrawingsColor = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Title";
    self.navigationController.navigationBarHidden = FALSE;
    navController = self.navigationController;
    navController.delegate = self;
    
    curveConverter = [[CurvesPointsConverter alloc] init];
    [myScrollView setContentSize:CGSizeMake(320.0, 380.0)];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == 1 || interfaceOrientation == 3)
        return YES;
    // Return YES for supported orientations
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(FirstTimeInit)
    {
        [super viewWillAppear:animated];
        self.navigationItem.title = PhotoTitle;
        self.navigationController.navigationBarHidden = FALSE;
        allDrawings = [[NSMutableArray alloc] init];
        allDrawingsColor = [[NSMutableArray alloc] init];
        currentLastCurveIndex = 0;
        
        if(CurvesData != NULL)
        {
            imgPhoto.image = [curveConverter GetImageByImage:SelectedImage StringData:CurvesData];
            NSMutableArray *allComponent = [curveConverter ConvertToArrayFromString:CurvesData];
            allDrawings = [allComponent objectAtIndex:0];
            allDrawingsColor = [allComponent objectAtIndex:1];
            currentLastCurveIndex = 0;
        }
        else
            imgPhoto.image = SelectedImage;
        
        DrawingImage = FALSE;
        FirstTimeInit = FALSE;
    }
    
    [self detectOrientation];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:YES];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:YES];
}

- (void)DrawAllLayer
{
    UIGraphicsBeginImageContext(imgPhoto.frame.size);
    [SelectedImage drawInRect:CGRectMake(0, 0, imgPhoto.frame.size.width, imgPhoto.frame.size.height)];
    
    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //sets the line width for a graphic context
    CGContextSetLineWidth(ctx,3.0);

    
    for (int i=0; i<[allDrawings count]; i++) {
        points = [allDrawings objectAtIndex:i];
        
        CGColorRef color = [[allDrawingsColor objectAtIndex:i] CGColor];
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        
        //set the line colour
        CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
        //creates a new empty path in a graphics context
        CGContextBeginPath(ctx);
        
        CGPoint point =  [[points objectAtIndex:0] CGPointValue];
        
        //begin a new path at the point you specify
        CGContextMoveToPoint(ctx, point.x, point.y);
        
        
        
        for (int j=1; j<[points count]; j++) {
            CGPoint point =  [[points objectAtIndex:j] CGPointValue];
            
            //Appends a straight line segment from the current point to the provided point 
            CGContextAddLineToPoint(ctx, point.x,point.y);    
        }
        
        //paints a line along the current path
        CGContextStrokePath(ctx);
    }
    
    imgPhoto.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    points = [[NSMutableArray alloc] init];
}

-(IBAction)UndoChangeClick:(id)sender
{
    if([allDrawings count]>0 && [allDrawings count] > currentLastCurveIndex)
    {
        [allDrawings removeLastObject];
        [allDrawingsColor removeLastObject];
        [self DrawAllLayer];
    }
}

-(IBAction)EraseAllClick:(id)sender
{
    [allDrawings removeAllObjects];
    [allDrawingsColor removeAllObjects];
    currentLastCurveIndex = 0;
    imgPhoto.image = SelectedImage;
}

-(IBAction)ChangeColor:(id)sender
{
    controller = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:currentColor];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)DrawLastLayerLastLine
{
    UIGraphicsBeginImageContext(imgPhoto.frame.size);
    [imgPhoto.image drawInRect:CGRectMake(0, 0, imgPhoto.frame.size.width, imgPhoto.frame.size.height)];
    
    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //sets the line width for a graphic context
    CGContextSetLineWidth(ctx,3.0);
    
    CGColorRef color = [currentColor CGColor];
    const CGFloat *components = CGColorGetComponents(color);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
        
    //set the line colour
    CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
    //creates a new empty path in a graphics context
    CGContextBeginPath(ctx);
        
    CGPoint point =  [[points objectAtIndex:([points count] - 2)] CGPointValue];
        
    //begin a new path at the point you specify
    CGContextMoveToPoint(ctx, point.x, point.y);
    point =  [[points objectAtIndex:([points count]-1)] CGPointValue];
            
    //Appends a straight line segment from the current point to the provided point 
    CGContextAddLineToPoint(ctx, point.x,point.y);    
        
    //paints a line along the current path
    CGContextStrokePath(ctx);
    
    imgPhoto.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)moveScrollView:(CGFloat)moveY {
    [myScrollView scrollRectToVisible:CGRectMake(0.0, myScrollView.contentOffset.y - moveY, myScrollView.frame.size.width, myScrollView.frame.size.height) animated:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if(pt.x >= myScrollView.frame.origin.x && pt.x <= myScrollView.frame.origin.x + myScrollView.frame.size.width &&
       pt.y >= myScrollView.frame.origin.y && pt.y <= myScrollView.frame.origin.y + myScrollView.frame.size.height)
    {
        pt = [[touches anyObject] locationInView:myScrollView];
        
        if(pt.x >= imgPhoto.frame.origin.x && pt.x <= imgPhoto.frame.origin.x + imgPhoto.frame.size.width &&
           pt.y >=imgPhoto.frame.origin.y && pt.y <= imgPhoto.frame.origin.y + imgPhoto.frame.size.height)
        {
            [self AddLastCurve];
            DrawingImage = TRUE;
            pt.x = pt.x - imgPhoto.frame.origin.x;
            pt.y = pt.y - imgPhoto.frame.origin.y;
            points = [[NSMutableArray alloc] init];
            [points addObject:[NSValue valueWithCGPoint:pt]];
        }
        else
        {
            ScrollViewScrolling = YES;
            LastY = pt.y;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if(pt.x >= myScrollView.frame.origin.x && pt.x <= myScrollView.frame.origin.x + myScrollView.frame.size.width &&
       pt.y >= myScrollView.frame.origin.y && pt.y <= myScrollView.frame.origin.y + myScrollView.frame.size.height)
    {
        pt = [[touches anyObject] locationInView:myScrollView];
        
        if(DrawingImage == TRUE)
        {
            if(pt.x >= imgPhoto.frame.origin.x && pt.x <= imgPhoto.frame.origin.x + imgPhoto.frame.size.width &&
               pt.y >=imgPhoto.frame.origin.y && pt.y <= imgPhoto.frame.origin.y + imgPhoto.frame.size.height)
            {
                pt.x = pt.x - imgPhoto.frame.origin.x;
                pt.y = pt.y - imgPhoto.frame.origin.y;
                [points addObject:[NSValue valueWithCGPoint:pt]];
                [self DrawLastLayerLastLine];
                [self AddLastCurve];
            }
            else 
            {
                if(ScrollViewScrolling == YES)
                {
                    [self moveScrollView:pt.y - LastY];
                    LastY = pt.y;
                    ScrollViewScrolling = FALSE;
                }
            }
            
            DrawingImage = FALSE;
        }
        else if(pt.x >= btnChangeColor.frame.origin.x && pt.x<= btnChangeColor.frame.origin.x + btnChangeColor.frame.size.width &&
                pt.y >= btnChangeColor.frame.origin.y && pt.y<= btnChangeColor.frame.origin.y + btnChangeColor.frame.size.height)
        {
            [self ChangeColor:btnChangeColor];
        }
        else if(pt.x >= btnErrasAll.frame.origin.x && pt.x<= btnErrasAll.frame.origin.x + btnErrasAll.frame.size.width &&
                pt.y >= btnErrasAll.frame.origin.y && pt.y<= btnErrasAll.frame.origin.y + btnErrasAll.frame.size.height)
        {
            [self EraseAllClick:btnErrasAll];
        }
        else if(pt.x >= btnUndoChange.frame.origin.x && pt.x<= btnUndoChange.frame.origin.x + btnUndoChange.frame.size.width &&
                pt.y >= btnUndoChange.frame.origin.y && pt.y<= btnUndoChange.frame.origin.y + btnUndoChange.frame.size.height)
        {
            [self UndoChangeClick:btnUndoChange];
        }
        else 
        {
            if(ScrollViewScrolling == YES)
            {
                [self moveScrollView:pt.y - LastY];
                LastY = pt.y;
                ScrollViewScrolling = FALSE;
            }
        }
        
        [self AddLastCurve];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if(pt.x >= myScrollView.frame.origin.x && pt.x <= myScrollView.frame.origin.x + myScrollView.frame.size.width &&
       pt.y >= myScrollView.frame.origin.y && pt.y <= myScrollView.frame.origin.y + myScrollView.frame.size.height)
    {
        pt = [[touches anyObject] locationInView:myScrollView];
        
        if(DrawingImage == TRUE)
        {
            if(pt.x >= imgPhoto.frame.origin.x && pt.x <= imgPhoto.frame.origin.x + imgPhoto.frame.size.width &&
               pt.y >=imgPhoto.frame.origin.y && pt.y <= imgPhoto.frame.origin.y + imgPhoto.frame.size.height)
            {
                pt.x = pt.x - imgPhoto.frame.origin.x;
                pt.y = pt.y - imgPhoto.frame.origin.y;
                [points addObject:[NSValue valueWithCGPoint:pt]];
                [self DrawLastLayerLastLine];
            }
            else 
            {
                if(ScrollViewScrolling == YES)
                {
                    [self moveScrollView:pt.y - LastY];
                    LastY = pt.y;
                }
            }
        }
        else 
        {
            if(ScrollViewScrolling == YES)
            {
                [self moveScrollView:pt.y - LastY];
                LastY = pt.y;
            }
        }
    }
}

#pragma mark - Hayashi311ColorPickerDelegate

- (void)setSelectedColor:(UIColor*)color{
    currentColor = color;
}
@end
