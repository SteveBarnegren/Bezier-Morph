//
//  BezierMorphView.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import "BezierMorphView.h"


#pragma mark UIBezierPath Extension
@implementation UIBezierPath (Morph)

-(NSMutableArray*)getAllPoints{
   // UIBezierPath *yourPath; // Assume this has some points in it
    //CGPath yourCGPath = yourPath.CGPath;
    NSMutableArray *bezierPoints = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)(bezierPoints), MyCGPathApplierFunc);
    
    return bezierPoints;
   
}

void MyCGPathApplierFunc (void *info, const CGPathElement *element) {
    
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            {
                NSLog(@"move to point");
                BezierPoint *point = [[BezierPoint alloc]init];
                point.loc = points[0];
                point.curveType = kMoveToPoint;
                [bezierPoints addObject:point];
            }
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            {
                NSLog(@"line to point");
                BezierPoint *point = [[BezierPoint alloc]init];
                point.loc = points[0];
                point.curveType = kLineToPoint;
                [bezierPoints addObject:point];
            }
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            {
                NSLog(@"quad curve to point");
                BezierPoint *point = [[BezierPoint alloc]init];
                point.loc = points[1];
                point.cp1 = points[0];
                point.curveType = kQuadCurveToPoint;
                [bezierPoints addObject:point];
            }
            break;

        case kCGPathElementAddCurveToPoint: // contains 3 points
            {
                NSLog(@"curve to point");
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
                NSLog(@"close subpath");
                BezierPoint *point = [[BezierPoint alloc]init];
                point.curveType = kCloseSubpath;
                [bezierPoints addObject:point];
            }
            break;
    }
}


@end


#pragma mark Bezier Point
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



@implementation BezierMorphView

-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
/*
    UIBezierPath *bezierPath = [[UIBezierPath alloc]init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addQuadCurveToPoint:CGPointMake(300, 300) controlPoint:CGPointMake(100, 200)];
 */
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(40, 40, 200, 200)];
       
    
    NSMutableArray *points = [bezierPath getAllPoints];
    
    
    // draw the path with just lines between close points
    int index = 0;
    
    for (BezierPoint *point in points) {
        
        if (point.curveType == kMoveToPoint) {
        }
        else if (point.curveType == kLineToPoint){
            BezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnLinep1:prevPoint.loc p2:point.loc]; // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                CGPoint point = [value CGPointValue];
                [self debugDrawDotAt:point];
            }
        }
        else if (point.curveType == kCurveToPoint){
        }
        else if (point.curveType == kQuadCurveToPoint){
        
            BezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnQuadBezier:point previousPoint:prevPoint];
            // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                CGPoint point = [value CGPointValue];
                [self debugDrawDotAt:point];
            }
        }
        else if (point.curveType == kCloseSubpath){
            NSLog(@"draw close subpath");
            //close subpath is a line with no location, just connect the previous point to the first point
            CGPoint previousLoc = ((BezierPoint*)[points objectAtIndex:index-1]).loc;
            CGPoint firstLoc = ((BezierPoint*)[points firstObject]).loc;
            NSMutableArray *segPointsArray =  [self calculateAllPointsOnLinep1:previousLoc p2:firstLoc];
            // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                CGPoint point = [value CGPointValue];
                [self debugDrawDotAt:point];
            }
        }
        
        // increment
        index++;
        
    }
    
   // [self reconstructOriginalUIBezierPathFromBezierPointsAndDraw:points];
    
}

#pragma mark obtaining points on lines

-(NSMutableArray*)calculateAllPointsOnLinep1:(CGPoint)p1 p2:(CGPoint)p2{
    
    const int numSamples = 1000;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:numSamples];
    
    for (int i = 0; i < numSamples; i++) {
       
        float t = (1.0f/numSamples) * i;
        float xDiff = p2.x - p1.x;
        float yDiff = p2.y - p1.y;
        float x = p1.x + (xDiff*t);
        float y = p1.y + (yDiff*t);
        
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    return array;
  
}


-(NSMutableArray*)calculateAllPointsOnQuadBezier:(BezierPoint*)point previousPoint:(BezierPoint*)destPoint{
    
    const int numSamples = 1000;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:numSamples];

    for (int i = 0; i < numSamples; i++) {
        
        float t = (1.0f/numSamples) * i;
        float x = (1 - t) * (1 - t) * point.loc.x + 2 * (1 - t) * t * point.cp1.x + t * t * destPoint.loc.x;
        float y = (1 - t) * (1 - t) * point.loc.y + 2 * (1 - t) * t * point.cp1.y + t * t * destPoint.loc.y;
        
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
        return array;
}



#pragma mark Debug

-(void)reconstructOriginalUIBezierPathFromBezierPointsAndDraw:(NSMutableArray*)points{
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    for (BezierPoint *point in points) {
        
        if (point.curveType == kMoveToPoint) {
            [path moveToPoint:point.loc];
        }
        else if (point.curveType == kLineToPoint){
            [path addLineToPoint:point.loc];
        }
        
        else if (point.curveType == kCurveToPoint){
            [path addCurveToPoint:point.loc controlPoint1:point.cp1 controlPoint2:point.cp2];
        }
        else if (point.curveType == kQuadCurveToPoint){
            [path addQuadCurveToPoint:point.loc controlPoint:point.cp1];
        }
        
    }
    
    [path stroke];
    
}

-(void)debugDrawDotAt:(CGPoint)loc{
    
    [[UIColor redColor]set];
    
    const float radius = 2;
    CGRect rect = CGRectMake(loc.x-radius, loc.y-radius, radius*2, radius*2);
    [[UIBezierPath bezierPathWithOvalInRect:rect]fill];

}








@end
