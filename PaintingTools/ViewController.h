//
//  ViewController.h
//  PaintingTools
//
//  Created by USER on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageEditViewController.h"
#import "CurvesPointsConverter.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIImageView *imgView;
    IBOutlet UIButton *btnClick;
    ImageEditViewController *imageEditViewController;
    CurvesPointsConverter *curveConverter;
    BOOL hasImage;
    BOOL isImageSelecting;
}

@property (nonatomic, retain) UIImage *SelectedImage;
@property (nonatomic, retain) NSString *CurvesData;
@property (nonatomic, assign) BOOL EditPhotoComplete;

-(IBAction)Click:(id)sender;

@end
