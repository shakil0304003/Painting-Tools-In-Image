//
//  ViewController.m
//  PaintingTools
//
//  Created by USER on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize SelectedImage,CurvesData,EditPhotoComplete;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    isImageSelecting = NO;
    hasImage = FALSE;
    EditPhotoComplete = FALSE;
    curveConverter = [[CurvesPointsConverter alloc] init];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(EditPhotoComplete == TRUE)
    {
        imgView.image = [curveConverter GetImageByImage:SelectedImage StringData:CurvesData];
        [btnClick setTitle:@"" forState:UIControlStateNormal];
        EditPhotoComplete = FALSE;
        hasImage = TRUE;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)OpenSecondActionSheet
{
    UIActionSheet *actionSheet;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New Photo",@"Choose Existing Photo",nil];
    else
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing Photo",nil];
    
    [actionSheet showInView:self.view];
    isImageSelecting = YES;
}

-(void)OpenFirstActionSheet
{
    if(hasImage == FALSE)
    {
        [self OpenSecondActionSheet];
    }
    else
    {
        UIActionSheet *actionSheet;
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Current Image",@"Take Another Image",nil];
        
        isImageSelecting = NO;
        [actionSheet showInView:self.view];
    }
}

-(IBAction)Click:(id)sender
{
    [self OpenFirstActionSheet];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(isImageSelecting)
    {
        if(buttonIndex == 0)
        {
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.delegate = self;
            
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                //controller.mediaTypes = [NSArray arrayWithObjects:(NSString *) KUTTypeImage, nil];
                controller.allowsEditing = NO;
            }
            else
                controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            [self presentModalViewController:controller animated:YES];
            controller = nil;
        }
        else if(buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.delegate = self;
            
            controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            [self presentModalViewController:controller animated:YES];
            controller = nil;
        }    
    }
    else
    {
        if(buttonIndex == 0)
        {
            imageEditViewController.FirstTimeInit = YES;
            imageEditViewController.PhotoTitle = @"";
            imageEditViewController.SelectedImage = SelectedImage;
            imageEditViewController.CurvesData = CurvesData;
            
            [self.navigationController pushViewController:imageEditViewController animated:YES];
        }
        else if(buttonIndex == 1)
        {
            [self OpenSecondActionSheet];
        }
    }
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return imageCopy;
}

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    image = [self scaleAndRotateImage:image];
    
    if(imageEditViewController == nil)
        imageEditViewController = [[ImageEditViewController alloc] initWithNibName:@"ImageEditViewController" bundle:nil];
    
    imageEditViewController.FirstTimeInit = YES;
    imageEditViewController.PhotoTitle = @"";
    imageEditViewController.SelectedImage = image;
    imageEditViewController.CurvesData = NULL;
    image = nil;
    
    [self.navigationController pushViewController:imageEditViewController animated:YES];
    //[self presentModalViewController:imageEditViewController animated:YES];
} 

@end
