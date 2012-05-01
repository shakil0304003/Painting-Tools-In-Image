//
//  ImageEditViewController.h
//  CybCommAudit
//
//  Created by USER on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRColorPickerViewController.h"
#import "MBProgressHUD.h"
#import "CurvesPointsConverter.h"

@interface ImageEditViewController : UIViewController<UINavigationControllerDelegate,HRColorPickerViewControllerDelegate>
{
    UINavigationController *navController;
    IBOutlet UIImageView *imgPhoto;
    IBOutlet UIScrollView *myScrollView;
    IBOutlet UIButton *btnChangeColor;
    IBOutlet UIButton *btnErrasAll;
    IBOutlet UIButton *btnUndoChange;
    BOOL DrawingImage;
    BOOL ScrollViewScrolling;
    NSMutableArray *points;
    NSMutableArray *allDrawings;
    NSMutableArray *allDrawingsColor;
    HRColorPickerViewController* controller;
    UIColor *currentColor;
    CGFloat LastY;
    CurvesPointsConverter *curveConverter;
    NSInteger currentLastCurveIndex;
}

@property (nonatomic, retain) UIImage *SelectedImage;
@property (nonatomic, retain) NSString *CurvesData;
@property (retain) NSString *PhotoTitle;
@property (assign) BOOL FirstTimeInit;

-(IBAction)UndoChangeClick:(id)sender;
-(IBAction)EraseAllClick:(id)sender;
-(IBAction)ChangeColor:(id)sender;

@end
