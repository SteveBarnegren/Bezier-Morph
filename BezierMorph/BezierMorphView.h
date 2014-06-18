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



typedef enum : NSUInteger {
    kMoveToPoint,
    kLineToPoint,
    kQuadCurveToPoint,
    kCurveToPoint,
    kCloseSubpath,
} e_CurveType;





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
@interface BezierMorphView : UIView
@property float accuracy;
@property int lengthSamplingDivisions;


-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration;


@end
