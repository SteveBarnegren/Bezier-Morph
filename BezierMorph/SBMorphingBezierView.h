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
 - 10% saving with _matchShapeRotations = NO and _adjustForCentreOffset = NO;

 
 */


// Change these so that they all use a common prefix (enum type name, and options)
typedef enum : NSUInteger {
    SBTimingFunctionLinear,
    // Sine
    SBTimingFunctionSineIn,
    SBTimingFunctionSineOut,
    SBTimingFunctionSineInOut,
    // Exponential
    SBTimingFunctionExponentialIn,
    SBTimingFunctionExponentialOut,
    SBTimingFunctionExponentialInOut,
    // Back
    SBTimingFunctionBackIn,
    SBTimingFunctionBackOut,
    SBTimingFunctionBackInOut,
    // Bounce
    SBTimingFunctionBounceIn,
    SBTimingFunctionBounceOut,
    SBTimingFunctionBounceInOut,
    // Elastic
    SBTimingFunctionElasticIn,
    SBTimingFunctionElasticOut,
    SBTimingFunctionElasticInOut
} SBTimingFunctions;

// Bezier Morph View

typedef void (^DrawBlock)(UIBezierPath *path, float t);
typedef void (^DrawBlockMP)(NSArray *paths, float t);
typedef void (^CompletionBlock)();

@interface SBMorphingBezierView : UIView

// Basic drawing properties
@property float strokeWidth;
@property(nonatomic, strong) UIColor *strokeColour;
@property (nonatomic, strong) UIColor *fillColour;

// performance settings
@property float accuracy;
@property int lengthSamplingDivisions;
@property BOOL matchShapeRotations;
@property BOOL adjustForCentreOffset;

// Morphing
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration timingFunc:(SBTimingFunctions)tf;
-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration;

// Morphing With Draw Block
-(void)morphFromPath:(UIBezierPath *)path1 toPath:(UIBezierPath *)path2 duration:(float)duration timingFunc:(SBTimingFunctions)tf drawBlock:(DrawBlock)drawBlock completionBlock:(CompletionBlock)completionBlock;
-(void)stopMorphing;

// Morphing Multiple Paths
-(void)morphFromPaths:(NSArray*)startPaths toPaths:(NSArray*)endPaths duration:(float)duration timingFunc:(SBTimingFunctions)tf drawBlock:(DrawBlockMP)drawBlock completionBlock:(CompletionBlock)completionBlock;



@end
