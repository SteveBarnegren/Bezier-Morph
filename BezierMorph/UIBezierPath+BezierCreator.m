//
//  UIBezierPath+BezierCreator.m
//  BezierMorph
//
//  Created by Steven Barnegren on 20/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import "UIBezierPath+BezierCreator.h"

#pragma mark


typedef enum : NSUInteger {
    kMoveToPoint,
    kLineToPoint,
    kQuadCurveToPoint,
    kCurveToPoint,
    kCloseSubpath,
} e_BezierCurveType;

// Bezier Point
@interface BezierPoint : NSObject
@property e_BezierCurveType curveType;
@property CGPoint loc;
@property CGPoint cp1;
@property CGPoint cp2;
@end

@implementation BezierPoint

-(id)init{
    if (self = [super init]) {
        _loc = CGPointZero;
        _cp1 = CGPointZero;
        _cp2 = CGPointZero;
    }
    return self;
}
-(id)initWithLoc:(CGPoint)loc cp1:(CGPoint)cp1 cp2:(CGPoint)cp2{
    if (self = [super init]) {
        _loc = loc;
        _cp1 = cp1;
        _cp2 = cp2;
    }
    return self;
}
@end



@implementation UIBezierPath (BezierCreator)

+(UIBezierPath*)bezierPathWithScaledBezierPath:(UIBezierPath*)inputPath aroundPoint:(CGPoint)centrePoint scale:(float)scale{
    
    NSMutableArray *points = [inputPath getPointsInfo];
    
    UIBezierPath *outputPath = [UIBezierPath bezierPath];
 
    for (BezierPoint *point in points) {
        
        // scale loc
        {
            float xDiff = point.loc.x - centrePoint.x;
            xDiff *= scale;
            float yDiff = point.loc.y - centrePoint.y;
            yDiff *= scale;
            point.loc = CGPointMake(centrePoint.x + xDiff, centrePoint.y + yDiff);
        }
        // scale control point 1
        {
            float xDiff = point.cp1.x - centrePoint.x;
            xDiff *= scale;
            float yDiff = point.cp1.y - centrePoint.y;
            yDiff *= scale;
            point.cp1 = CGPointMake(centrePoint.x + xDiff, centrePoint.y + yDiff);
        }
        // scale control point 2
        {
            float xDiff = point.cp2.x - centrePoint.x;
            xDiff *= scale;
            float yDiff = point.cp2.y - centrePoint.y;
            yDiff *= scale;
            point.cp2 = CGPointMake(centrePoint.x + xDiff, centrePoint.y + yDiff);
        }
        
        // add to the output path
        if (point.curveType == kMoveToPoint) {
            [outputPath moveToPoint:point.loc];
        }
        else if (point.curveType == kLineToPoint){
            [outputPath addLineToPoint:point.loc];
        }
        else if (point.curveType == kCurveToPoint){
            [outputPath addCurveToPoint:point.loc controlPoint1:point.cp1 controlPoint2:point.cp2];
        }
        else if (point.curveType == kQuadCurveToPoint){
            [outputPath addQuadCurveToPoint:point.loc controlPoint:point.cp1];
        }
        else if (point.curveType == kCloseSubpath){
            [outputPath closePath];
        }

    }

    return outputPath;
    
}

+(UIBezierPath*)bezierPathWithReverseOfPath:(UIBezierPath*)inputPath{

    NSMutableArray *points = [inputPath getPointsInfo];

    NSLog(@"num points to reverse = %i", points.count);
    
    UIBezierPath *outputPath = [UIBezierPath bezierPath];
    
    BOOL shouldClosePath = NO;
    
    BezierPoint *prevPoint = nil;
    e_BezierCurveType prevCurveType = kCloseSubpath;
    
    for (BezierPoint *point in [points reverseObjectEnumerator]) {
        
        BOOL savePoint = YES;
        
        // complete the previous move
        if (point.curveType == kCloseSubpath){
            shouldClosePath = YES;
            savePoint = NO;
        }
        else if (!prevPoint) {
            NSLog(@"move");
            [outputPath moveToPoint:point.loc];
        }
        else if (prevCurveType == kMoveToPoint) {
            NSLog(@"move");
            [outputPath moveToPoint:point.loc];
        }
        else if (prevCurveType == kLineToPoint){
            NSLog(@"line");
            [outputPath addLineToPoint:point.loc];
        }
        else if (prevCurveType == kCurveToPoint){
            NSLog(@"curve");
            [outputPath addCurveToPoint:point.loc controlPoint1:prevPoint.cp1 controlPoint2:prevPoint.cp2];
        }
        else if (prevCurveType == kQuadCurveToPoint){
            NSLog(@"quad curve");
            [outputPath addQuadCurveToPoint:prevPoint.loc controlPoint:prevPoint.cp1];
        }
        
        if (savePoint) {
            prevPoint = point;
            prevCurveType = point.curveType;
        }
        
    }
    
    if (shouldClosePath) {
        NSLog(@"close");
        [outputPath closePath];
    }
    
    ;
    
    return outputPath;

}

-(NSMutableArray*)getPointsInfo{
    
    NSMutableArray *bezierPoints = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)(bezierPoints), CGPathApplierFunc);
    return bezierPoints;
    
}

void CGPathApplierFunc (void *info, const CGPathElement *element) {
    
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
        {
            BezierPoint *point = [[BezierPoint alloc]init];
            point.loc = points[0];
            point.curveType = kMoveToPoint;
            [bezierPoints addObject:point];
        }
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
        {
            BezierPoint *point = [[BezierPoint alloc]init];
            point.loc = points[0];
            point.curveType = kLineToPoint;
            [bezierPoints addObject:point];
        }
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
        {
            BezierPoint *point = [[BezierPoint alloc]init];
            point.loc = points[1];
            point.cp1 = points[0];
            point.curveType = kQuadCurveToPoint;
            [bezierPoints addObject:point];
        }
            break;
            
        case kCGPathElementAddCurveToPoint: // contains 3 points
        {
            BezierPoint *point = [[BezierPoint alloc]init];
            point.cp1 = points[0];
            point.cp2 = points[1];
            point.loc = points[2]; // loc
            point.curveType = kCurveToPoint;
            [bezierPoints addObject:point];
        }
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
        {
            BezierPoint *point = [[BezierPoint alloc]init];
            point.curveType = kCloseSubpath;
            [bezierPoints addObject:point];
        }
            break;
    }
}



@end
