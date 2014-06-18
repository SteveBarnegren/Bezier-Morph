//
//  BezierMorphView.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import "BezierMorphView.h"

#define kNumSegmentsPerPoint 100


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

#pragma mark Point Connection

@implementation PointConnection
@end

#pragma mark Bezier Morph View

@implementation BezierMorphView{
    
    NSMutableArray *_connectionsArray;
    UIBezierPath *_currentPath;
    
    NSTimer *_morphTimer;
    double _startTime;
    float _morphDuration;
    float _morphPct;
}

-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _connectionsArray = nil;
        _morphTimer = nil;
        _morphDuration = 0;
        _morphPct = 0;
    }
    return self;
}






-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    if (_connectionsArray == nil) {
        return;
    }
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    
    BOOL isFirstPoint = YES;
    
    for (PointConnection *connection in _connectionsArray) {
        
        CGPoint p1 = connection.p1;
        CGPoint p2 = connection.p2;
        
        float xDiff = p2.x - p1.x;
        float yDiff = p2.y - p1.y;
        
        CGPoint p = CGPointMake(p1.x + (xDiff * _morphPct), p1.y + (yDiff * _morphPct));
        
        if (isFirstPoint) {
            [path moveToPoint:p];
            isFirstPoint = NO;

        }
        else{
            [path addLineToPoint:p];
        }
    }
    path.miterLimit = 0;
    //path.lineJoinStyle = kCGLineJoinBevel;
    [path closePath];
    
    // fill grey
    UIColor *fillColour = [UIColor colorWithRed:0 green: 0 blue:0 alpha:0.1];
    [fillColour set];
    [path fill];
    
    // stroke black
    [[UIColor blackColor]set];
    [path stroke];

}

-(NSMutableArray*)createConnectionsBetweenPathArraysPath1:(NSMutableArray*)path1 path2:(NSMutableArray*)path2{
    
    NSMutableArray *connectionsArray = [[NSMutableArray alloc]init];
    
    int path1Count = path1.count;
    int path2Count = path2.count;
    
    // roatate the second path so that the points match up as much as possible
    
    {
        int closestIndex = 0;
        double closestDist = 10000;
        
        CGPoint p1StartLoc = ((NSValue*)[path1 firstObject]).CGPointValue;
        
        int index = 0;
        for (NSValue *value in path2) {
            CGPoint point = value.CGPointValue;
            double distance = calculatePointsDistance(p1StartLoc, point);
            if (distance < closestDist) {
                closestDist = distance;
                closestIndex = index;
            }
            
            index++;
            
        }
        
        // rearrange the array
        int newStartIndex = closestIndex;
        NSLog(@"new start index = %i", newStartIndex);
        
        // create a new array
        NSMutableArray *newArray = [[NSMutableArray alloc]init];
        int i = newStartIndex;
        do {
            [newArray addObject:[path2 objectAtIndex:i]];
            // increment to the next Index
            i++;
            if (i >= path2.count) {
                i = 0;
            }
            
        } while (i != newStartIndex);
        path2 = newArray;
    }
     

    NSLog(@"path1 points: %i", path1Count);
    NSLog(@"path2 points: %i", path2Count);
    
    float ratio = (float)path2.count/(float)path1.count;
    
    NSLog(@"ratio = %f", ratio);
    
    int index = 0;
    
    for (NSValue *value in path1) {
        // get the corresponding point in the other path at the correct ratio
        int correspondingIndex = index*ratio;
        NSValue *correspondingPoint = [path2 objectAtIndex:correspondingIndex];
        NSLog(@"CONNECTION (%f, %f) %i  <-->  %i (%f, %f)",value.CGPointValue.x, value.CGPointValue.y, index, (int)(index*ratio), correspondingPoint.CGPointValue.x, correspondingPoint.CGPointValue.y );
        
        PointConnection *connection = [[PointConnection alloc]init];
        connection.p1 = value.CGPointValue;
        connection.p2 = correspondingPoint.CGPointValue;
        [connectionsArray addObject:connection];
        
        index++;
        
    }

    return connectionsArray;
  
}


-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration{
    
    _morphDuration = duration;
    _morphPct = 0;
    
    //UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(40, 40, 200, 200)];
    NSMutableArray *path1Points = [self segmentPointsForBezierPath:path1];
    //UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(40, 40, 200, 200) cornerRadius:5];
    NSMutableArray *path2Points = [self segmentPointsForBezierPath:path2];
    
    _connectionsArray = [self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points];
    
    NSLog(@"%i connections", _connectionsArray.count);
    
    _morphTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(morphTick) userInfo:nil repeats:YES];
    _startTime = CACurrentMediaTime();

}

-(void)morphTick{
    //NSLog(@"current time = %f", _startTime);
    
    double elapsedTime = CACurrentMediaTime() - _startTime;
    _morphPct = elapsedTime/_morphDuration;
    
    if (_morphPct >=1) {
        [_morphTimer invalidate];
        _morphTimer = nil;
        _morphPct = 1;
    }

    [self setNeedsDisplay];
}



#pragma mark obtaining points on lines

-(NSMutableArray*)segmentPointsForBezierPath:(UIBezierPath*)path{
   
    NSMutableArray *points = [path getAllPoints];
    
    // draw the path with just lines between close points
    int index = 0;
    
    NSMutableArray *segmentPoints = [[NSMutableArray alloc]init];
    
    for (BezierPoint *point in points) {
        
        if (point.curveType == kMoveToPoint) {
            // do nothing
        }
        else if (point.curveType == kLineToPoint){
            BezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnLinep1:prevPoint.loc p2:point.loc]; // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        else if (point.curveType == kCurveToPoint){
            BezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSArray *segPointsArray = calculatePointsOnCubicBezier(prevPoint.loc, point.loc, point.cp1, point.cp2, kNumSegmentsPerPoint);
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
            
        }
        else if (point.curveType == kQuadCurveToPoint){
            
            BezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnQuadBezier:point previousPoint:prevPoint];
            // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
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
                [segmentPoints addObject:value];
                }
        }
        
        // increment
        index++;
        
    }
    
    NSLog(@"num segments points = %i", segmentPoints.count);
    
    return segmentPoints;
    
}




-(NSMutableArray*)calculateAllPointsOnLinep1:(CGPoint)p1 p2:(CGPoint)p2{
    
    const int numSamples = kNumSegmentsPerPoint;
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
    
    const int numSamples = kNumSegmentsPerPoint;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:numSamples];

    for (int i = 0; i < numSamples; i++) {
        
        float t = (1.0f/numSamples) * i;
        float x = (1 - t) * (1 - t) * point.loc.x + 2 * (1 - t) * t * point.cp1.x + t * t * destPoint.loc.x;
        float y = (1 - t) * (1 - t) * point.loc.y + 2 * (1 - t) * t * point.cp1.y + t * t * destPoint.loc.y;
        
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
        return array;
}

NSArray* calculatePointsOnCubicBezier(CGPoint origin, CGPoint destination, CGPoint control1, CGPoint control2, int segments){
    
    CGPoint vertices[segments + 1];
    
    float t = 0;
    for(NSUInteger i = 0; i < segments; i++)
    {
        vertices[i].x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
        vertices[i].y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
        t += 1.0f / segments;
    }
    vertices[segments] = CGPointMake(destination.x, destination.y);
    
    // put it all in an array
    NSMutableArray *points = [[NSMutableArray alloc]init];
    for (int i = 0; i < segments; i++) {
        [points addObject:[NSValue valueWithCGPoint:vertices[i]]];
    }
    return points;
    
}

float calculatePointsDistance(CGPoint p1, CGPoint p2){
    
    float xDist = p1.x - p2.x;
    float yDist = p1.y - p2.y;
    
    float dist = sqrtf((xDist*xDist)+(yDist*yDist));
    dist = fabs(dist);
    
    return dist;
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
