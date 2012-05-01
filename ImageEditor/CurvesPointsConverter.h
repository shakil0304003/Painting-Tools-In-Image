//
//  CurvesPointsConverter.h
//  CybCommAudit
//
//  Created by USER on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurvesPointsConverter : NSObject

-(NSString*)ConvertToStringFromArray:(NSMutableArray*)curves Colors:(NSMutableArray*)colors;
-(NSMutableArray*)ConvertToArrayFromString:(NSString*)data;
- (UIImage*)GetImageByImage:(UIImage*)orginalImage StringData:(NSString*)data;

@end
