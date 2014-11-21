//
//  UIBezierPath+BezierCreator.h
//  BezierMorph
//
//  Created by Steven Barnegren on 20/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (BezierCreator)

+(UIBezierPath*)bezierPathWithScaledBezierPath:(UIBezierPath*)inputPath aroundPoint:(CGPoint)centrePoint scale:(float)scale;
+(UIBezierPath*)bezierPathWithReverseOfPath:(UIBezierPath*)inputPath;



@end
