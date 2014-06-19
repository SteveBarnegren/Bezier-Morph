//
//  BezierMorphView.h
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 - Draw all Shapes anti-clockwise
 
 */

// Does this need to be in header?
typedef enum : NSUInteger {
    kMoveToPoint,
    kLineToPoint,
    kQuadCurveToPoint,
    kCurveToPoint,
    kCloseSubpath,
} e_CurveType;

// Change these so that they all use a common prefix (enum type name, and options)
typedef enum : NSUInteger {
    SBMorphingBezierTimingFunctionLinear,
    // Sine
    SBMorphingBezierTimingFunctionSineIn,
    SBMorphingBezierTimingFunctionSineOut,
    SBMorphingBezierTimingFunctionSineInOut,
    // Exponential
    SBMorphingBezierTimingFunctionExponentialIn,
    SBMorphingBezierTimingFunctionExponentialOut,
    SBMorphingBezierTimingFunctionExponentialInOut,
    // Back
    SBMorphingBezierTimingFunctionBackIn,
    SBMorphingBezierTimingFunctionBackOut,
    SBMorphingBezierTimingFunctionBackInOut,
    // Bounce
    SBMorphingBezierTimingFunctionBounceIn,
    SBMorphingBezierTimingFunctionBounceOut,
    SBMorphingBezierTimingFunctionBounceInOut,
    // Elastic
    SBMorphingBezierTimingFunctionElasticIn,
    SBMorphingBezierTimingFunctionElasticOut,
    SBMorphingBezierTimingFunctionElasticInOut
} SBMorphingBezierTimingFunction;



// Do these extensions really need to go in header?

// Bezier Extension
@interface UIBezierPath (Morph)
-(NSMutableArray*)getAllPoints;
@end

// Bezier Point
@interface BezierPoint : NSObject
@property e_CurveType curveType;
@property CGPoint loc;
@property CGPoint cp1;
@property CGPoint cp2;
@end

// Point connection
@interface PointConnection : NSObject
@property CGPoint p1;
@property CGPoint p2;
@end


// Bezier Morph View

typedef void (^DrawBlock)(UIBezierPath *path, float t);

@interface SBMorphingBezierView : UIView
@property float accuracy;
@property int lengthSamplingDivisions;
// Basic drawing properties
@property float strokeWidth;
@property(nonatomic, strong) UIColor *strokeColour;
@property (nonatomic, strong) UIColor *fillColour;


// Morphing
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration timingFunc:(SBMorphingBezierTimingFunction)tf;
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration;

// Morphing With Draw Block
-(void)morphFromPath:(UIBezierPath *)path1 toPath:(UIBezierPath *)path2 duration:(float)duration timingFunc:(SBMorphingBezierTimingFunction)tf drawBlock:(DrawBlock)drawBlock;

-(void)stopMorphing;



// Multiple paths!!!



@end
