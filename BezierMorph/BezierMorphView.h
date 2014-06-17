//
//  BezierMorphView.h
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import <UIKit/UIKit.h>

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


// Bezier Morph View
@interface BezierMorphView : UIView

@end
