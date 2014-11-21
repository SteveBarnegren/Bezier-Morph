//
//  Paths.m
//  BezierMorph
//
//  Created by Steven Barnegren on 21/11/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import "Paths.h"

@implementation Paths


-(UIBezierPath*)jigsawPathInFrame:(CGRect)frame{
    
    //CGRect frame = [self frameWithWidthPct:0.5 heightPct:0.4 xOffset:0.05 yOffset:0];
    
    //// jigsaw Drawing
    UIBezierPath* jigsawPath = [UIBezierPath bezierPath];
    [jigsawPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46231 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25304 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53297 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24983 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17898 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25505 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21764 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46874 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08565 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46301 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14935 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47379 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14098 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34784 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00228 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46294 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02229 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39973 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00169 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21667 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08398 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29357 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00293 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23416 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03173 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23526 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17477 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20516 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20549 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15278 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24713 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23695 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25150 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18679 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28744 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20452 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22537 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00350 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47611 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + -0.00336 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42236 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07053 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48804 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00743 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50699 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04555 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52144 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22097 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57121 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.10906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43656 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21558 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47015 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65222 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22664 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67724 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.11385 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69357 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00032 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65325 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.06730 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61357 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60396 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + -0.00399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24074 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99784 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00833 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91622 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27089 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99291 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28473 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94073 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35985 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78716 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23108 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89370 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22569 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77333 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42057 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90660 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46481 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79798 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44728 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88983 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44950 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98706 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92269 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39610 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97281 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52256 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00660 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71984 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71490 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77823 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81560 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70698 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73517 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65732 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.80666 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69504 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60861 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78424 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73830 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.80598 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50093 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41974 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45556 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72283 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50739 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78817 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55089 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.72924 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53808 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70778 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43568 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame))];
    [jigsawPath closePath];
    
    return jigsawPath;
    
}



@end
