//
//  CurvesPointsConverter.m
//  CybCommAudit
//
//  Created by USER on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurvesPointsConverter.h"

@implementation CurvesPointsConverter

-(NSString*)ConvertToStringFromArray:(NSMutableArray*)curves Colors:(NSMutableArray*)colors
{
    NSString *stringOutput = @"";
    
    for (int i=0; i<[curves count]; i++) {
        
        if(i!=0)
            stringOutput = [NSString stringWithFormat:@"%@#",stringOutput];
        
        NSMutableArray *points = [curves objectAtIndex:i];
        CGColorRef color = [[colors objectAtIndex:i] CGColor];
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        stringOutput = [NSString stringWithFormat:@"%@%f,%f,%f",stringOutput,red,green,blue];
        
        for (int j=1; j<[points count]; j++) {
            CGPoint point =  [[points objectAtIndex:j] CGPointValue];
            
            stringOutput = [NSString stringWithFormat:@"%@&%f,%f",stringOutput,point.x,point.y];  
        }
        
    }
    
    return stringOutput;
}

-(NSMutableArray*)ConvertToArrayFromString:(NSString*)data
{
    NSMutableArray *curves = [[NSMutableArray alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    NSArray *listItems = [data componentsSeparatedByString:@"#"];
    
    for (int i=0; i< [listItems count]; i++) {
        NSArray *values = [[listItems objectAtIndex:i] componentsSeparatedByString:@"&"];
        NSMutableArray *points = [[NSMutableArray alloc] init];
       
        NSArray *items = [[values objectAtIndex:0] componentsSeparatedByString:@","];
        
        if([items count] > 2)
        {    
            UIColor *color = [UIColor colorWithRed:[[items objectAtIndex:0] floatValue] green:[[items objectAtIndex:1] floatValue] blue:[[items objectAtIndex:2] floatValue] alpha:1];
            [colors addObject:color];
            
            for (int j=1; j<[values count]; j++) {
                items = [[values objectAtIndex:j] componentsSeparatedByString:@","];
                CGPoint point = CGPointMake([[items objectAtIndex:0] floatValue], [[items objectAtIndex:1] floatValue]);
                [points addObject:[NSValue valueWithCGPoint:point]];
            }
        
            [curves addObject:points];
        }
    }
    
    return [[NSMutableArray alloc] initWithObjects:curves,colors, nil];
}

- (UIImage*)GetImageByImage:(UIImage*)orginalImage StringData:(NSString*)data
{
    CGFloat width = 320;
    CGFloat height = 320;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [orginalImage drawInRect:CGRectMake(0, 0, width, height)];
    
    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //sets the line width for a graphic context
    CGContextSetLineWidth(ctx,3.0);
    
    NSMutableArray *allComponent = [self ConvertToArrayFromString:data];
    NSMutableArray *allDrawings = [allComponent objectAtIndex:0];
    NSMutableArray *allDrawingsColor = [allComponent objectAtIndex:1];
    
    for (int i=0; i<[allDrawings count]; i++) {
        NSMutableArray *points = [allDrawings objectAtIndex:i];
        
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
    
    orginalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return orginalImage;
}

@end
