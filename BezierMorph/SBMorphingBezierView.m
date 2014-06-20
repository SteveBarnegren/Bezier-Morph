//
//  BezierMorphView.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 Steven Barnegren. All rights reserved.
//

#import "SBMorphingBezierView.h"

#define kNumSegmentsPerPoint 100

#define kDefaultLengthSamplingDivisions 10

#define M_PI_X_2 (float)M_PI * 2.0f

#define Points_Dist(p1, p2) fabs(sqrtf(((p1.x - p2.x)*(p1.x - p2.x))+((p1.y - p2.y)*(p1.y - p2.y))))

typedef enum : NSUInteger {
    kMoveToPoint,
    kLineToPoint,
    kQuadCurveToPoint,
    kCurveToPoint,
    kCloseSubpath,
} e_CurveType;

#pragma mark ---- Private interfaces ----

// Bezier Point
@interface SBBezierPoint : NSObject
@property e_CurveType curveType;
@property CGPoint loc;
@property CGPoint cp1;
@property CGPoint cp2;
@end

// Bezier Extension
@interface UIBezierPath (SBMorph)
-(NSMutableArray*)getAllPoints;
@end

// Point connection
@interface SBPointConnection : NSObject
@property CGPoint p1;
@property CGPoint p2;
@end

#pragma mark ---- UIBezierPath Extension ----
@implementation UIBezierPath (SBMorph)

-(NSMutableArray*)getAllPoints{

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
                SBBezierPoint *point = [[SBBezierPoint alloc]init];
                point.loc = points[0];
                point.curveType = kMoveToPoint;
                [bezierPoints addObject:point];
            }
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            {
                SBBezierPoint *point = [[SBBezierPoint alloc]init];
                point.loc = points[0];
                point.curveType = kLineToPoint;
                [bezierPoints addObject:point];
            }
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            {
                SBBezierPoint *point = [[SBBezierPoint alloc]init];
                point.loc = points[1];
                point.cp1 = points[0];
                point.curveType = kQuadCurveToPoint;
                [bezierPoints addObject:point];
            }
            break;

        case kCGPathElementAddCurveToPoint: // contains 3 points
            {
                SBBezierPoint *point = [[SBBezierPoint alloc]init];
                point.cp1 = points[0];
                point.cp2 = points[1];
                point.loc = points[2]; // loc
                point.curveType = kCurveToPoint;
                [bezierPoints addObject:point];
            }
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            {
                SBBezierPoint *point = [[SBBezierPoint alloc]init];
                point.curveType = kCloseSubpath;
                [bezierPoints addObject:point];
            }
            break;
    }
}


@end


#pragma mark ---- Bezier Point ----

@implementation SBBezierPoint

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

#pragma mark ---- Point Connection ----

@implementation SBPointConnection
@end

#pragma mark ---- Bezier Morph View ----

@implementation SBMorphingBezierView{
    
    NSMutableArray *_connectionsArray;
    UIBezierPath *_currentPath;
    
    NSTimer *_morphTimer;
    double _startTime;
    float _morphDuration;
    float _morphPct;
    
    BOOL _usingReversedConnections; //for if we actually need to morph from path2 to path1
    
    float _period; // for use in ease functions (this can be changed for some interesting effects)
   SBTimingFunctions _timingFunction;
    
    // drawing
    BOOL _useBlockDrawing;
    DrawBlock _drawBlock;
    CompletionBlock _completionBlock;
    
    // multiple paths
    BOOL _isDrawingMultiplePaths;
    NSMutableArray *_multiplePathsConnectionsArray;
    NSMutableArray *_multiplePathsUsingReversedConnectionsArray;
    DrawBlockMP _drawBlockMP;



}

-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        // init ivars
        _connectionsArray = nil;
        _multiplePathsConnectionsArray = nil;
        
        _morphTimer = nil;
        _morphDuration = 0;
        _morphPct = 0;
        _usingReversedConnections = YES;
        _accuracy = 1;
        _lengthSamplingDivisions = kDefaultLengthSamplingDivisions;
        
        _timingFunction = SBTimingFunctionSineInOut;
        
        _period = 0.3f * 1.5f;
        
        _useBlockDrawing = NO;
        
        // drawing properties
        _strokeWidth = 1.0f;
        _strokeColour = [UIColor blackColor];
        _fillColour = [UIColor whiteColor];
        
        
        // set performance settings
        _matchShapeRotations = YES;
        _adjustForCentreOffset = YES;
        
        _drawBlock = NULL;
        _completionBlock = NULL;
        
        // multiple paths
        _drawBlockMP = NULL;
        _isDrawingMultiplePaths = NO;
        

    }
    return self;
}

-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration timingFunc:(SBTimingFunctions)tf{
    
    [self stopMorphing];
    
    [self morphFromPath:path1 toPath:path2 duration:duration];
    _timingFunction = tf;
    
}

-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration{
    
    [self stopMorphing];
    
    _morphDuration = duration;
    _morphPct = 0;
    
    NSMutableArray *path1Points = [self segmentPointsForBezierPath:path1];
    NSMutableArray *path2Points = [self segmentPointsForBezierPath:path2];
    
    _connectionsArray = [self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points];
    
    _morphTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(morphTick) userInfo:nil repeats:YES];
    _startTime = CACurrentMediaTime();
    
    _useBlockDrawing = NO;
    _completionBlock = NULL;
    _timingFunction = SBTimingFunctionLinear;
    _isDrawingMultiplePaths = NO;
    
}

-(void)morphFromPath:(UIBezierPath *)path1 toPath:(UIBezierPath *)path2 duration:(float)duration timingFunc:(SBTimingFunctions)tf drawBlock:(DrawBlock)drawBlock completionBlock:(CompletionBlock)completionBlock{
    
    [self stopMorphing];
    
    [self morphFromPath:path1 toPath:path2 duration:duration timingFunc:tf];
    _drawBlock = drawBlock;
    _completionBlock = completionBlock;
    _useBlockDrawing = YES;
    
}

-(void)morphFromPaths:(NSArray*)startPaths toPaths:(NSArray*)endPaths duration:(float)duration timingFunc:(SBTimingFunctions)tf drawBlock:(DrawBlockMP)drawBlock completionBlock:(CompletionBlock)completionBlock{
    
    [self stopMorphing];
    
    
    _multiplePathsConnectionsArray = [[NSMutableArray alloc]initWithCapacity:startPaths.count];
    _multiplePathsUsingReversedConnectionsArray = [[NSMutableArray alloc]initWithCapacity:startPaths.count];
    
   // NSAssert(startPaths.count > 0 && endPaths.count > 0, @"SBMorphingBezierView - start and end path arrays count must both be greater than 0");
    int index = 0;
    for (UIBezierPath *fromPath in startPaths) {
        
        NSMutableArray *path1Points = [self segmentPointsForBezierPath:fromPath];
        NSMutableArray *path2Points = [self segmentPointsForBezierPath:[endPaths objectAtIndex:index]];
        
        [_multiplePathsConnectionsArray addObject:[self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points]];
        // _usingReversedConnections was set in create connections, we can just copy the value and put it into the array here
        [_multiplePathsUsingReversedConnectionsArray addObject:[NSNumber numberWithBool:_usingReversedConnections]];

        index++;
    }
    
    _drawBlockMP = drawBlock;
    _completionBlock = completionBlock;

    _morphDuration = duration;
    _morphPct = 0;
    _morphTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(morphTick) userInfo:nil repeats:YES];
    _startTime = CACurrentMediaTime();
    _timingFunction = tf;
    
    _isDrawingMultiplePaths = YES;

    
}


-(void)stopMorphing{
    
    [_morphTimer invalidate];
    _morphTimer = nil;
    _completionBlock = NULL;
    _connectionsArray = nil;
    _multiplePathsConnectionsArray = nil;
    _multiplePathsUsingReversedConnectionsArray = nil;
    
}

-(void)morphTick{
    
    double elapsedTime = CACurrentMediaTime() - _startTime;
    _morphPct = elapsedTime/_morphDuration;
    
    if (_morphPct >=1) {
        [_morphTimer invalidate];
        _morphTimer = nil;
        _morphPct = 1;
        if (_completionBlock) {_completionBlock();}
    }
    
    [self setNeedsDisplay];
}

#pragma mark Drawing

-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    if (_isDrawingMultiplePaths) {
        [self drawRectForMultiplePaths];
    }
    else{
        [self drawRectForSinglePath];
    }
    
}

-(void)drawRectForSinglePath{
    
    if (_connectionsArray == nil) {
        return;
    }
    
    // apply the timing function
    float t = [self applyTimingFuction:_timingFunction toTime:_morphPct];
    
    // construct the path
    UIBezierPath *path = [[UIBezierPath alloc]init];
    BOOL isFirstPoint = YES;
    
    for (SBPointConnection *connection in _connectionsArray) {
        
        CGPoint p1 = _usingReversedConnections?connection.p2:connection.p1;
        CGPoint p2 = _usingReversedConnections?connection.p1:connection.p2;
        
        float xDiff = p2.x - p1.x;
        float yDiff = p2.y - p1.y;
        
        CGPoint p = CGPointMake(p1.x + (xDiff * t), p1.y + (yDiff * t));
        
        if (isFirstPoint) {
            [path moveToPoint:p];
            isFirstPoint = NO;
            
        }
        else{
            [path addLineToPoint:p];
        }
    }
    
    [path closePath];
    
    
    if (!_useBlockDrawing) {
        
        // fill
        [_fillColour set];
        [path fill];
        
        // stroke
        [_strokeColour set];
        path.lineWidth = _strokeWidth;
        [path stroke];
    }
    else{
        
        _drawBlock(path, t);
        
    }

}

-(void)drawRectForMultiplePaths{
    
    if (_multiplePathsConnectionsArray == nil) {
        return;
    }
    
    // apply the timing function
    float t = [self applyTimingFuction:_timingFunction toTime:_morphPct];
    
    
    NSMutableArray *pathsArray = [[NSMutableArray alloc]init];
    
    int pathIndex = 0;
    for (NSArray *connectionsArray in _multiplePathsConnectionsArray) {
        
        BOOL usingReversedConnections = [[_multiplePathsUsingReversedConnectionsArray objectAtIndex:pathIndex]boolValue];

        // construct the paths
        UIBezierPath *path = [[UIBezierPath alloc]init];

        BOOL isFirstPoint = YES;

        for (SBPointConnection *connection in connectionsArray) {
            
            CGPoint p1 = usingReversedConnections?connection.p2:connection.p1;
            CGPoint p2 = usingReversedConnections?connection.p1:connection.p2;
            
            float xDiff = p2.x - p1.x;
            float yDiff = p2.y - p1.y;
            
            CGPoint p = CGPointMake(p1.x + (xDiff * t), p1.y + (yDiff * t));
            
            if (isFirstPoint) {
                [path moveToPoint:p];
                isFirstPoint = NO;
                
            }
            else{
                [path addLineToPoint:p];
            }
        }
        
        [path closePath];
        [pathsArray addObject:path];
        
        pathIndex++;
    }
    
    _drawBlockMP(pathsArray, t);
    
}

#pragma mark Building connections

-(NSMutableArray*)createConnectionsBetweenPathArraysPath1:(NSMutableArray*)path1 path2:(NSMutableArray*)path2{
    
    NSMutableArray *connectionsArray = [[NSMutableArray alloc]init];
    
    // always morph from the path with the most points to the one with the least points
    // swap them round here if need be
    if (path1.count < path2.count) {
        NSMutableArray *tempPath = path1;
        path1 = path2;
        path2 = tempPath;
        _usingReversedConnections = YES;
    }
    else{
        _usingReversedConnections = NO;
    }
    
    // get the 'centre' of the shape for use in rotation, we'll offset the centre of path 1 when working this out.
    
    float offsetX = 0;
    float offsetY = 0;

    if (_matchShapeRotations && _adjustForCentreOffset) {
       
        float p1CentreX = 0;
        float p1CentreY = 0;
     
            {
                float cumX = 0;
                float cumY = 0;
                for (NSValue *value in path1) {
                    CGPoint point = [value CGPointValue];
                    cumX += point.x;
                    cumY += point.y;
                }
                p1CentreX = cumX / (float)path1.count;
                p1CentreY = cumY / (float)path1.count;
            }
            
        float p2CentreX;
        float p2CentreY;
            {
                float cumX = 0;
                float cumY = 0;
                for (NSValue *value in path2) {
                    CGPoint point = [value CGPointValue];
                    cumX += point.x;
                    cumY += point.y;
                }
                p2CentreX = cumX / (float)path2.count;
                p2CentreY = cumY / (float)path2.count;
            }

        offsetX = p2CentreX - p1CentreX;
        offsetY = p2CentreY - p1CentreY;
            
            
        }

    // rotate the second path so that the points match up as much as possible
    if (_matchShapeRotations) {
        int closestIndex = 0;
        float closestDist = 10000;

        CGPoint p1StartLoc = ((NSValue*)[path1 firstObject]).CGPointValue;
        p1StartLoc.x += offsetX;
        p1StartLoc.y += offsetY;
        
        int index = 0;
        for (NSValue *value in path2) {
            CGPoint point = value.CGPointValue;
            float distance = sqrtf(((p1StartLoc.x - point.x)*(p1StartLoc.x - point.x))+((p1StartLoc.y - point.y)*(p1StartLoc.y - point.y)));
            distance *= distance;
            
            if (distance < closestDist) {
                closestDist = distance;
                closestIndex = index;
            }
            
            index++;
            
        }
        
        // rearrange the array
        int newStartIndex = closestIndex;
        
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
    
    float ratio = (float)path2.count/(float)path1.count;

    int index = 0;
    
    for (NSValue *value in path1) {
        // get the corresponding point in the other path at the correct ratio
        int correspondingIndex = index*ratio;
        NSValue *correspondingPoint = [path2 objectAtIndex:correspondingIndex];
        
        SBPointConnection *connection = [[SBPointConnection alloc]init];
        connection.p1 = value.CGPointValue;
        connection.p2 = correspondingPoint.CGPointValue;
        [connectionsArray addObject:connection];
        
        index++;
        
    }

    return connectionsArray;
  
}


#pragma mark obtaining points on lines

-(NSMutableArray*)segmentPointsForBezierPath:(UIBezierPath*)path{
   
    NSMutableArray *points = [path getAllPoints];
    
    // draw the path with just lines between close points
    int index = 0;
    
    NSMutableArray *segmentPoints = [[NSMutableArray alloc]init];
    
    for (SBBezierPoint *point in points) {
        
        if (point.curveType == kMoveToPoint) {
            // do nothing
        }
        else if (point.curveType == kLineToPoint){
            SBBezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnLinep1:prevPoint.loc p2:point.loc]; // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        else if (point.curveType == kCurveToPoint){
            SBBezierPoint *prevPoint = [points objectAtIndex:index-1];
            //NSArray *segPointsArray = calculatePointsOnCubicBezier(prevPoint.loc, point.loc, point.cp1, point.cp2);
            NSArray *segPointsArray = [self calculatePointsOnCubicBezierWithOrigin:prevPoint.loc c1:point.cp1 c2:point.cp2 destination:point.loc];

            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
            
        }
        else if (point.curveType == kQuadCurveToPoint){
            
            SBBezierPoint *prevPoint = [points objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnQuadBezier:point previousPoint:prevPoint];
            // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        else if (point.curveType == kCloseSubpath){
            //close subpath is a line with no location, just connect the previous point to the first point
            CGPoint previousLoc = ((SBBezierPoint*)[points objectAtIndex:index-1]).loc;
            CGPoint firstLoc = ((SBBezierPoint*)[points firstObject]).loc;
            NSMutableArray *segPointsArray =  [self calculateAllPointsOnLinep1:previousLoc p2:firstLoc];
            // just draw the dots so that we know they're correct
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        
        // increment
        index++;
        
    }
    
    return segmentPoints;
    
}

-(NSMutableArray*)calculateAllPointsOnLinep1:(CGPoint)p1 p2:(CGPoint)p2{

    int numSamples = sqrt(((p2.x-p1.x) * (p2.x-p1.x)) + ((p2.y-p1.y) * (p2.y-p1.y))) * _accuracy;
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:numSamples];
    
    for (int i = 0; i < numSamples; i++) {
        
        float t = (1.0f/numSamples) * i;

        
        [array addObject:[NSValue valueWithCGPoint:
                          CGPointMake(p1.x + ((p2.x - p1.x)*t),
                                      p1.y + ((p2.y - p1.y)*t)
                                      )]];
    }
    
    return array;

}

-(NSMutableArray*)calculateAllPointsOnQuadBezier:(SBBezierPoint*)point previousPoint:(SBBezierPoint*)destPoint{
    
    double length = 0;
    
    CGPoint prevPoint;
    BOOL firstPoint = YES;
    
    for (int i = 0; i < _lengthSamplingDivisions; i++) {
        
        float t = (1.0f/_lengthSamplingDivisions) * i;
        float x = (1 - t) * (1 - t) * point.loc.x + 2 * (1 - t) * t * point.cp1.x + t * t * destPoint.loc.x;
        float y = (1 - t) * (1 - t) * point.loc.y + 2 * (1 - t) * t * point.cp1.y + t * t * destPoint.loc.y;
    
        if (!firstPoint) {
            length += sqrt(((x-prevPoint.x) * (x-prevPoint.x)) + ((y-prevPoint.y) * (y-prevPoint.y)));
        }
        
        prevPoint = CGPointMake(x, y);
        firstPoint = NO;
    }

    int numSamples = (int)length;
    numSamples = (float)numSamples * _accuracy;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:numSamples];

    for (int i = 0; i < numSamples; i++) {
        
        float t = (1.0f/numSamples) * i;
        float x = (1 - t) * (1 - t) * point.loc.x + 2 * (1 - t) * t * point.cp1.x + t * t * destPoint.loc.x;
        float y = (1 - t) * (1 - t) * point.loc.y + 2 * (1 - t) * t * point.cp1.y + t * t * destPoint.loc.y;
        
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
        return array;
}

-(NSArray*)calculatePointsOnCubicBezierWithOrigin:(CGPoint)origin c1:(CGPoint)control1 c2:(CGPoint)control2 destination:(CGPoint)destination{
    
    float t;
    
    double length = 0;
    
    CGPoint prevPoint;
    BOOL firstPoint = YES;
    
    t = 0;
    for (int i = 0; i < _lengthSamplingDivisions; i++) {

        float x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
        float y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
        t += 1.0f / _lengthSamplingDivisions;

        if (!firstPoint) {
            length += sqrt(((x-prevPoint.x) * (x-prevPoint.x)) + ((y-prevPoint.y) * (y-prevPoint.y)));
        }
        
        
        prevPoint = CGPointMake(x, y);
        firstPoint = NO;
        
        
    }
     
     int segments = (int)length;

    NSMutableArray *points = [[NSMutableArray alloc]initWithCapacity:segments];
    
    t = 0; // reuse t from above
    for(NSUInteger i = 0; i < segments; i++)
    {
        float x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
        float y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
        t += 1.0f / segments;
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        
        
    }
    
    return points;
    
}

// This gets called a lot. Is a function to avoid messaging overhead
float calculatePointsDistance(CGPoint p1, CGPoint p2){
    
    return fabs(sqrtf(((p1.x - p2.x)*(p1.x - p2.x))+((p1.y - p2.y)*(p1.y - p2.y))));

}


#pragma mark Ease Time Manipulation

-(float)applyTimingFuction:(SBTimingFunctions)easeFuction toTime:(float)t{
    
    switch (_timingFunction) {
            // Linear
        case SBTimingFunctionLinear:
            t = _morphPct;
            break;
            // Sine
        case SBTimingFunctionSineIn:
            t = [self easeSineIn:_morphPct];
            break;
        case SBTimingFunctionSineOut:
            t = [self easeSineOut:_morphPct];
            break;
        case SBTimingFunctionSineInOut:
            t = [self easeSineInOut:_morphPct];
            break;
            // Exponential
        case SBTimingFunctionExponentialIn:
            t = [self easeExponentialIn:_morphPct];
            break;
        case SBTimingFunctionExponentialOut:
            t = [self easeExponentialOut:_morphPct];
            break;
        case SBTimingFunctionExponentialInOut:
            t = [self easeExponentialInOut:_morphPct];
            break;
            // back
        case SBTimingFunctionBackIn:
            t = [self easeBackIn:_morphPct];
            break;
        case SBTimingFunctionBackOut:
            t = [self easeBackOut:_morphPct];
            break;
        case SBTimingFunctionBackInOut:
            t = [self easeBackInOut:_morphPct];
            break;
            // Bounce
        case SBTimingFunctionBounceIn:
            t = [self easeBounceIn:_morphPct];
            break;
        case SBTimingFunctionBounceOut:
            t = [self easeBounceOut:_morphPct];
            break;
        case SBTimingFunctionBounceInOut:
            t = [self easeBounceInOut:_morphPct];
            break;
            // Elastic
        case SBTimingFunctionElasticIn:
            t = [self easeElasticIn:_morphPct];
            break;
        case SBTimingFunctionElasticOut:
            t = [self easeElasticOut:_morphPct];
            break;
        case SBTimingFunctionElasticInOut:
            t = [self easeElasticInOut:_morphPct];
            break;
        default:
            // should never get called, but default to linear just in case
            t = _morphPct;
            break;
    }

    return t;
}

// Ease Sine

-(float)easeSineIn:(float)t{
    
    float newT = -1*cosf(t * (float)M_PI_2) +1;
    return newT;
}

-(float)easeSineOut:(float)t{
    
    return sinf(t * (float)M_PI_2);

}

-(float)easeSineInOut:(float)t{
    
    return sinf(t * (float)M_PI_2);

}

// Ease Exponential
-(float)easeExponentialIn:(float)t{
 
    return (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001f;

}

-(float)easeExponentialOut:(float)t{
    
    return (t==1) ? 1 : (-powf(2, -10 * t/1) + 1);
    
}

-(float)easeExponentialInOut:(float)t{
    
    t /= 0.5f;
	if (t < 1)
		t = 0.5f * powf(2, 10 * (t - 1));
	else
		t = 0.5f * (-powf(2, -10 * (t -1) ) + 2);
    
	return t;
    
}

// Ease Back

-(float)easeBackIn:(float)t{
    
    double overshoot = 1.70158f;
	return t * t * ((overshoot + 1) * t - overshoot);
}

-(float)easeBackOut:(float)t{

    double overshoot = 1.70158f;
    
	t = t - 1;
	return t * t * ((overshoot + 1) * t + overshoot) + 1;

}

-(float)easeBackInOut:(float)t{
    
    double overshoot = 1.70158f * 1.525f;
    
	t = t * 2;
	if (t < 1)
		return (t * t * ((overshoot + 1) * t - overshoot)) / 2;
	else {
		t = t - 2;
		return (t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1;
	}
    
}

// Ease Bounce

-(double) bounceTime:(double) t
{
	if (t < 1 / 2.75) {
		return 7.5625f * t * t;
	}
	else if (t < 2 / 2.75) {
		t -= 1.5f / 2.75f;
		return 7.5625f * t * t + 0.75f;
	}
	else if (t < 2.5 / 2.75) {
		t -= 2.25f / 2.75f;
		return 7.5625f * t * t + 0.9375f;
	}
    
	t -= 2.625f / 2.75f;
	return 7.5625f * t * t + 0.984375f;
}

-(float)easeBounceIn:(float)t{
    
    double newT = t;
	if( t !=0 && t!=1)
		newT = 1 - [self bounceTime:1-t];
    
	return newT;

}

-(float)easeBounceOut:(float)t{
    
    double newT = t;
	if( t !=0 && t!=1)
		newT = [self bounceTime:t];
    
	return newT;

}

-(float)easeBounceInOut:(float)t{
    
    double newT;
	if( t ==0 || t==1)
		newT = t;
	else if (t < 0.5) {
		t = t * 2;
		newT = (1 - [self bounceTime:1-t] ) * 0.5f;
	} else
		newT = [self bounceTime:t * 2 - 1] * 0.5f + 0.5f;
    
	return newT;

}


// Ease Elastic

-(float)easeElasticIn:(float)t{
    
    double newT = 0;
	if (t == 0 || t == 1)
		newT = t;
    
	else {
		float s = _period / 4;
		t = t - 1;
		newT = -powf(2, 10 * t) * sinf( (t-s) *M_PI_X_2 / _period);
	}
	return newT;

}

-(float)easeElasticOut:(float)t{
    
    float newT = 0;
	if (t == 0 || t == 1) {
		newT = t;
        
	} else {
		float s = _period / 4;
		newT = powf(2, -10 * t) * sinf( (t-s) *M_PI_X_2 / _period) + 1;

	}
    return newT;
}

-(float)easeElasticInOut:(float)t{
    
    double newT = 0;
    
	if( t == 0 || t == 1 )
		newT = t;
	else {
		t = t * 2;
		if(! _period )
			_period = 0.3f * 1.5f;
		double s = _period / 4;
        
		t = t -1;
		if( t < 0 )
			newT = -0.5f * powf(2, 10 * t) * sinf((t - s) * M_PI_X_2 / _period);
		else
			newT = powf(2, -10 * t) * sinf((t - s) * M_PI_X_2 / _period) * 0.5f + 1;
	}
	return newT;
    
}


#pragma mark ---- Debug Methods ----

-(void)reconstructOriginalUIBezierPathFromBezierPointsAndDraw:(NSMutableArray*)points{
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    for (SBBezierPoint *point in points) {
        
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
