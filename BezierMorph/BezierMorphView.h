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
    kMorphingBezierTimingFunctionLinear,
    // Sine
    kMorphingBezierTimingFunctionSineIn,
    kMorphingBezierTimingFunctionSineOut,
    kMorphingBezierTimingFunctionSineInOut,
    // Exponential
    kMorphingBezierTimingFunctionExponentialIn,
    kMorphingBezierTimingFunctionExponentialOut,
    kMorphingBezierTimingFunctionExponentialInOut,
    // Back
    kMorphingBezierTimingFunctionBackIn,
    kMorphingBezierTimingFunctionBackOut,
    kMorphingBezierTimingFunctionBackInOut,
    // Bounce
    kMorphingBezierTimingFunctionBounceIn,
    kMorphingBezierTimingFunctionBounceOut,
    kMorphingBezierTimingFunctionBounceInOut,
    // Elastic
    kMorphingBezierTimingFunctionElasticIn,
    kMorphingBezierTimingFunctionElasticOut,
    kMorphingBezierTimingFunctionElasticInOut
} e_MorphingBezierTimingFunction;



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

@interface BezierMorphView : UIView
@property float accuracy;
@property int lengthSamplingDivisions;


// Morphing
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration timingFunc:(e_MorphingBezierTimingFunction)tf;
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration;

// Morphing With Draw Block
-(void)morphFromPath:(UIBezierPath *)path1 toPath:(UIBezierPath *)path2 duration:(float)duration timingFunc:(e_MorphingBezierTimingFunction)tf drawBlock:(DrawBlock)drawBlock;




@end
