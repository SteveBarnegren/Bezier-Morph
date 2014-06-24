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

#pragma mark ---- Private interfaces (supporting classes) ----

// Bezier Point
@interface SBBezierPoint : NSObject
@property e_CurveType curveType;
@property CGPoint loc;
@property CGPoint cp1;
@property CGPoint cp2;
@property float length;
@property float perimeterPct;
@property SBBezierPoint *mirrorPoint;
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
    
    CGPoint previousElementLoc;
    
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
                point.cp1 = point.loc;
                point.cp2 = point.loc;
                
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
            
            
            previousElementLoc = CGPointMake(points[0].x, points[0].y);
            
            
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
        _mirrorPoint = nil;
    }
    return self;
}
-(id)initWithLoc:(CGPoint)loc cp1:(CGPoint)cp1 cp2:(CGPoint)cp2{
    if (self = [super init]) {
        _loc = loc;
        _cp1 = cp1;
        _cp2 = cp2;
        _mirrorPoint = nil;
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
    
    NSMutableArray *path1Points = [path1 getAllPoints];
    NSMutableArray *path2Points = [path2 getAllPoints];
    
    _connectionsArray = [self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points];
    //NSLog(@"path 1 numPoints = %i", path1Points.count);
   // NSLog(@"path 2 numPoints = %i", path2Points.count);
    [self debugPrintPoints:path1Points];
    
    
    
    _morphTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(morphTick) userInfo:nil repeats:YES];
    _startTime = CACurrentMediaTime();
    
    _useBlockDrawing = NO;
    _completionBlock = NULL;
    _timingFunction = SBTimingFunctionLinear;
    _isDrawingMultiplePaths = NO;
    
}

-(NSMutableArray*)removeClosePathsFromPointsArray:(NSMutableArray*)array{
    
    SBBezierPoint *lastPoint = [array lastObject];
    if (lastPoint.curveType == kCloseSubpath) {
        NSLog(@"removing close opath point");
        SBBezierPoint *firstPoint = [array firstObject];
        SBBezierPoint* oneTolastPoint = [array objectAtIndex:array.count-1];
        lastPoint.loc = firstPoint.loc;
        lastPoint.cp2 = firstPoint.loc;
        lastPoint.cp1 = oneTolastPoint.loc;
        lastPoint.curveType = kLineToPoint;
     
    }
    
    
    return array;
    
    
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
        
        //NSMutableArray *path1Points = [self segmentPointsForBezierPath:fromPath];
       // NSMutableArray *path2Points = [self segmentPointsForBezierPath:[endPaths objectAtIndex:index]];
        
       // [_multiplePathsConnectionsArray addObject:[self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points]];
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

#define InterpolatePoints(p1, p2) CGPointMake(p1.x + ((p2.x - p1.x) * t), p1.y + ((p2.y - p1.y) * t))

-(void)drawRectForSinglePath{
    
    if (_connectionsArray == nil) {
        return;
    }
    
    // apply the timing function
    float t = [self applyTimingFuction:_timingFunction toTime:_morphPct];
    
    // construct the path
    UIBezierPath *path = [[UIBezierPath alloc]init];
    BOOL isFirstPoint = YES;
    
    for (SBBezierPoint *point in _connectionsArray) {
        
        switch (point.curveType) {
            case kMoveToPoint:
                [path moveToPoint:InterpolatePoints(point.loc, point.mirrorPoint.loc)];
                break;
            case kLineToPoint:
                [path addCurveToPoint:InterpolatePoints(point.loc, point.mirrorPoint.loc) controlPoint1:InterpolatePoints(point.cp1, point.mirrorPoint.cp1) controlPoint2:InterpolatePoints(point.cp2, point.mirrorPoint.cp2)];
                break;
            case kCurveToPoint:
                [path addCurveToPoint:InterpolatePoints(point.loc, point.mirrorPoint.loc) controlPoint1:InterpolatePoints(point.cp1, point.mirrorPoint.cp1) controlPoint2:InterpolatePoints(point.cp2, point.mirrorPoint.cp2)];
                break;
            case kCloseSubpath:
            {
                //NSLog(@"draw close subpath");
                SBBezierPoint *firstPoint = [_connectionsArray firstObject];
                [path addCurveToPoint:InterpolatePoints(firstPoint.loc, firstPoint.mirrorPoint.loc) controlPoint1:InterpolatePoints(firstPoint.cp1, firstPoint.mirrorPoint.cp1) controlPoint2:InterpolatePoints(firstPoint.cp2, firstPoint.mirrorPoint.cp2)];
            }
                break;
            default:
                break;
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
    
    
    for (SBBezierPoint *point in _connectionsArray) {
        [[UIColor greenColor]set];
        [self debugDrawDotAt:point.loc radius:2];
    }
    for (SBBezierPoint *point in _connectionsArray) {
        [[UIColor magentaColor]set];
        [self debugDrawDotAt:point.mirrorPoint.loc radius:2];
    }

    // debug draw points dots (interpolated)
    for (SBBezierPoint *point in _connectionsArray) {
        [[UIColor redColor]set];
        [self debugDrawDotAt:InterpolatePoints(point.loc, point.mirrorPoint.loc) radius:2];
    }
    
    // debug draw the first dot
    [[UIColor yellowColor]set];
    [self debugDrawDotAt:((SBBezierPoint*)[_connectionsArray firstObject]).loc radius:4];
    [[UIColor blueColor]set];
    [self debugDrawDotAt:((SBBezierPoint*)[_connectionsArray firstObject]).mirrorPoint.loc radius:2];
    
    
    

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

    // change the close paths to be lint to path
    [self removeClosePathsFromPointsArray:path1];
    [self removeClosePathsFromPointsArray:path2];
    // match rotations
    path2 = [self matchRotationOfPath:path1 withPath:path2];
    
    
    
    // the passed in arrays are arrays of SBBezierPoints
    float path1Length = [self approximateLengthOfPath:path1];
    NSLog(@"path 1 length = %f", path1Length);
    float path2Length = [self approximateLengthOfPath:path2];
    NSLog(@"path 2 length = %f", path2Length);

    float currPerimeterPct = 0;
    // set path1 perimeter pcts
    NSLog(@"---Path 1 percents---");

    for (SBBezierPoint *point in path1) {
        float pctOfPath = point.length/path1Length;
        currPerimeterPct+=pctOfPath;
        point.perimeterPct = currPerimeterPct;
        NSLog(@"point perimeterPct: %f", point.perimeterPct);
    }
    // set path2 perimeter pcts
    NSLog(@"---Path 2 percents---");
    currPerimeterPct = 0; // re-use
    for (SBBezierPoint *point in path2) {

        float pctOfPath = point.length/path2Length;
        currPerimeterPct+=pctOfPath;
        point.perimeterPct = currPerimeterPct;
        NSLog(@"point perimeterPct: %f", point.perimeterPct);

    }
    NSLog(@"ADD MIRROR POINTS---------------------------------------------------");
    // add points on path2 to match the same pcts as path1
    [self addMirrorPointsFromPath:path1 toPath:path2];
    [self addMirrorPointsFromPath:path2 toPath:path1];
    
    NSLog(@"---MIRROR POINTS ADDED---");
    NSLog(@"path 1 numPoints = %i", path1.count);
    NSLog(@"path 2 numPoints = %i", path2.count);
    
    /*
    // just to test what's going on with the extra points, remove any mirror points that are null
    
    NSMutableArray *pointsToRemove = [[NSMutableArray alloc]init];
    for (SBBezierPoint *point in path1) {
        if (point.mirrorPoint == nil) {
            [pointsToRemove addObject:point];
        }
    }
    for (SBBezierPoint *point in pointsToRemove) {
        [path1 removeObject:point];
    }
    
    NSLog(@"num points after removal: %i", path1.count);
   */
    
    
    

    // return the first path
    return path1;
    
}

-(NSMutableArray*)matchRotationOfPath:(NSMutableArray*)path1 withPath:(NSMutableArray*)path2{
    
    NSMutableArray *path1SegmentPoints = [self segmentPointsForPath:path1];
    NSMutableArray *path2SegmentPoints = [self segmentPointsForPath:path2];
    
    CGPoint p1StartLoc = ((SBBezierPoint*)[path1 firstObject]).loc;
    NSLog(@"p1StartLoc = (%f, %f)", p1StartLoc.x, p1StartLoc.y);
    
    float closestPointDist = 10000;
    float closestPointT = 0.0;
    SBBezierPoint *closestPointPrevPoint = nil;
    SBBezierPoint *closestPointNextPoint = nil;
    CGPoint closestPoint = CGPointZero; // we don't actually need to have this, just for debugging
    
    const int rotationDivisions = 1000; // rotation accuracy, should be as a property
    
    SBBezierPoint *path2PrevPoint = nil;
    
    for (SBBezierPoint *point in path2) {
        
        if (point.curveType == kMoveToPoint) {
            // do nothing
        }
        else if(point.curveType == kLineToPoint){
            
            
            for (int i = 0; i < rotationDivisions; i++) {
                
                float t = (float)i/rotationDivisions;
                
                SBBezierPoint *splitPoint = [[SBBezierPoint alloc]init];
                float xDiff = point.loc.x - path2PrevPoint.loc.x;
                float yDiff = point.loc.y - path2PrevPoint.loc.y;
                splitPoint.loc = CGPointMake(point.loc.x + (xDiff * t), point.loc.y + (yDiff * t));
                //NSLog(@"splitPoint = (%f, %f)", splitPoint.loc.x, splitPoint.loc.y);
                float dist = calculatePointsDistance(p1StartLoc, splitPoint.loc);
                //NSLog(@"rot line dist = %f", dist);

                if (dist < closestPointDist) {
                    closestPoint = splitPoint.loc; // debug
                    closestPointDist = dist;
                    //closestPointPct = path2PrevPoint.perimeterPct + ((point.perimeterPct - path2PrevPoint.perimeterPct)*t);
                    closestPointT = t;
                    closestPointPrevPoint = path2PrevPoint;
                    closestPointNextPoint = point;
                }
            }
   
        }
        else if(point.curveType == kCurveToPoint){
            for (int i = 0; i < rotationDivisions; i++) {
                
                float t = (float)i/rotationDivisions;


                SBBezierPoint* splitPoint = [self addPointOnCubicBezierFrom:path2PrevPoint to:point at:t];
                float dist = calculatePointsDistance(p1StartLoc, splitPoint.loc) < closestPointDist;
                if (dist < closestPointDist) {
                    closestPoint = splitPoint.loc; // debug
                    //NSLog(@"rot curve dist = %f", dist);
                    closestPointDist = dist;
                    //closestPointPct = path2PrevPoint.perimeterPct + ((point.perimeterPct - path2PrevPoint.perimeterPct)*t);
                    closestPointT = t;
                    closestPointPrevPoint = path2PrevPoint;
                    closestPointNextPoint = point;
                }
            }
        }
  
        path2PrevPoint = point;
    }
    
    
    
    
    
    SBBezierPoint *newPoint = [self newPointBetweenPointsP1:closestPointPrevPoint p2:closestPointNextPoint at:closestPointT];
    newPoint.curveType = kMoveToPoint;
    int insertIndex = [path2 indexOfObject:closestPointNextPoint];
    [path2 insertObject:newPoint atIndex:insertIndex];
    
    // rearrange the path 2 array to start with the new point
    // rearrange the array
    int newStartIndex = insertIndex;
    
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

    NSLog(@"closest point dist = %f", closestPointDist);
    NSLog(@"---PATH ROTATION MATCHED---");
    NSLog(@"p1 start = (%f, %f)", p1StartLoc.x, p1StartLoc.y);
    NSLog(@"closestPoint = (%f, %f)", closestPoint.x, closestPoint.y);
    SBBezierPoint *firstObj = [path2 firstObject];
    NSLog(@"array start point = (%f, %f)",firstObj.loc.x, firstObj.loc.y);

    return path2;
    
   
}

-(void)addMirrorPointsFromPath:(NSMutableArray*)path1 toPath:(NSMutableArray*)path2{
    
    NSLog(@"- about to mirror paths -!!!!!");
    NSLog(@"path 1 points = %i", path1.count);
    NSLog(@"path 2 points = %i", path2.count);

    //do the first and last points
    SBBezierPoint *path1FirstObj = [path1 firstObject];
    SBBezierPoint *path2FirstObj = [path2 firstObject];
    path1FirstObj.mirrorPoint = path2FirstObj;
    path2FirstObj.mirrorPoint = path1FirstObj;

    SBBezierPoint *path1LastObj = [path1 lastObject];
    SBBezierPoint *path2LastObj = [path2 lastObject];
   // path1LastObj.mirrorPoint = path2LastObj;
   // path2LastObj.mirrorPoint = path1LastObj;

    
    for (SBBezierPoint *path1Point in path1) {
        if (path1Point.mirrorPoint != nil) {NSLog(@"1");continue;}
        // find the two points that are either side in the second path
        //NSLog(@"----p1 perimeterpct = %f", path1Point.perimeterPct);
        int p2Index = 0;
        for (SBBezierPoint *path2Point in path2) {
        //if (path2Point.mirrorPoint != nil) {NSLog(@"2");}
            NSLog(@"p2 perimeterpct = %f", path2Point.perimeterPct);
            
            if (p2Index == 0) {
                p2Index++;
                continue;
                NSLog(@"3");
            }
             

            //NSLog(@"p2 looking for mirror point");
            if (path2Point.perimeterPct >= path1Point.perimeterPct) {
                NSLog(@"4");
                SBBezierPoint *path2PrevPoint = [path2 objectAtIndex:p2Index-1];
                float pctDiff = path2Point.perimeterPct - path2PrevPoint.perimeterPct;
                float insertPctDiff = path2PrevPoint.perimeterPct - path1Point.perimeterPct;
                //float t = fabsf(insertPctDiff/pctDiff);
                float t = insertPctDiff/-pctDiff;

                SBBezierPoint *pointToInsert = [self newPointBetweenPointsP1:path2PrevPoint p2:path2Point at:t];
                pointToInsert.mirrorPoint = path1Point;
                path1Point.mirrorPoint = pointToInsert;
                [path2 insertObject:pointToInsert atIndex:p2Index];
                NSLog(@"mirror found");
                break;
            }
            NSLog(@"5");
 
            p2Index++;
        }
        
        

    }
    
    NSLog(@"- mirrored paths -");
    NSLog(@"path 1 points = %i", path1.count);
    NSLog(@"path 2 points = %i", path2.count);

}

// will ammend the passsed in points, and will return the new points to be inserted into the array
-(SBBezierPoint*)newPointBetweenPointsP1:(SBBezierPoint*)p1 p2:(SBBezierPoint*)p2 at:(float)t{
    
    SBBezierPoint *newPoint = [[SBBezierPoint alloc]init];
    
    switch (p2.curveType) {
        case kLineToPoint:
        {
            NSLog(@"INSERT LINE___________");
            NSLog(@"t = %f", t);
            NSLog(@"p1 = (%f, %f)", p1.loc.x, p1.loc.y);
            NSLog(@"p2 = (%f, %f)", p2.loc.x, p2.loc.y);

            float xDiff = p2.loc.x - p1.loc.x;
            float yDiff = p2.loc.y - p1.loc.y;
            newPoint.loc = CGPointMake(p1.loc.x + (xDiff * t), p1.loc.y + (yDiff * t));

            NSLog(@"new = (%f, %f)", newPoint.loc.x, newPoint.loc.y);

            // calculate the new precentage
            newPoint.length = calculatePointsDistance(p1.loc, newPoint.loc);
            float pctChange = p2.perimeterPct - p1.perimeterPct;
            newPoint.perimeterPct = pctChange * (newPoint.length / p2.length);
            p2.length = p2.length - newPoint.length;
            newPoint.curveType = kLineToPoint;
            
            // setup the new control points
            newPoint.cp1 = p1.loc;
            newPoint.cp2 = newPoint.loc;
            p2.cp1 = newPoint.loc;
            p2.cp2 = p2.loc;
            
            newPoint.curveType = kLineToPoint;
            
            
            
        }
            break;
        case kCurveToPoint:
        {
            NSLog(@"INSERT CURVE (shouldn't happen)");

            newPoint = [self addPointOnCubicBezierFrom:p1 to:p2 at:t];
        }
        default:
            NSLog(@"ERROR: Couldn't add point to path");
            break;

    }
    
    
    return newPoint;
}

-(SBBezierPoint*)addPointOnCubicBezierFrom:(SBBezierPoint*)point1 to:(SBBezierPoint*)point2 at:(float)t{
    
    SBBezierPoint *insertedPoint = [[SBBezierPoint alloc]init];
    
    NSLog(@"split curve 2");
    
    CGPoint p1 = point1.loc;
    CGPoint p2 = point2.cp1;
    CGPoint p3 = point2.cp2;
    CGPoint p4 = point2.loc;
    
    float t1 = t;
    float t0 = 0;
    float u0 = 1-t0;
    float u1 = 1-t1;
    
    
    CGPoint newP1 = CGPointMake((u0*u0*u0*p1.x + (t0*u0*u0 + u0*t0*u0 + u0*u0*t0)*p2.x + (t0*t0*u0 + u0*t0*t0 + t0*u0*t0)*p3.x + t0*t0*t0*p4.x), (u0*u0*u0*p1.y + (t0*u0*u0 + u0*t0*u0 + u0*u0*t0)*p2.y + (t0*t0*u0 + u0*t0*t0 + t0*u0*t0)*p3.y + t0*t0*t0*p4.y));
    
    CGPoint newP2 = CGPointMake((u0*u0*u1*p1.x + (t0*u0*u1 + u0*t0*u1 + u0*u0*t1)*p2.x + (t0*t0*u1 + u0*t0*t1 + t0*u0*t1)*p3.x + t0*t0*t1*p4.x), (u0*u0*u1*p1.y + (t0*u0*u1 + u0*t0*u1 + u0*u0*t1)*p2.y + (t0*t0*u1 + u0*t0*t1 + t0*u0*t1)*p3.y + t0*t0*t1*p4.y));
    
    CGPoint newP3 = CGPointMake((u0*u1*u1*p1.x + (t0*u1*u1 + u0*t1*u1 + u0*u1*t1)*p2.x + (t0*t1*u1 + u0*t1*t1 + t0*u1*t1)*p3.x + t0*t1*t1*p4.x), (u0*u1*u1*p1.y + (t0*u1*u1 + u0*t1*u1 + u0*u1*t1)*p2.y + (t0*t1*u1 + u0*t1*t1 + t0*u1*t1)*p3.y + t0*t1*t1*p4.y));
    
    CGPoint newP4 = CGPointMake((u1*u1*u1*p1.x + (t1*u1*u1 + u1*t1*u1 + u1*u1*t1)*p2.x + (t1*t1*u1 + u1*t1*t1 + t1*u1*t1)*p3.x + t1*t1*t1*p4.x), (u1*u1*u1*p1.y + (t1*u1*u1 + u1*t1*u1 + u1*u1*t1)*p2.y + (t1*t1*u1 + u1*t1*t1 + t1*u1*t1)*p3.y + t1*t1*t1*p4.y));
    
    
    
    // draw the curve (this should be just the first half
    insertedPoint.cp1 = p2;
    insertedPoint.cp2 = p3;
    insertedPoint.loc = p4;

    
    // for the second half segment, we can just switch round the curve (start from the end)
    p1 = point2.loc;
    p2 = point2.cp2;
    p3 = point2.cp1;
    p4 = point1.loc;
    
    t = 1-t;
    t1 = t;
    t0 = 0;
    u0 = 1-t0;
    u1 = 1-t1;
    
    
    newP1 = CGPointMake((u0*u0*u0*p1.x + (t0*u0*u0 + u0*t0*u0 + u0*u0*t0)*p2.x + (t0*t0*u0 + u0*t0*t0 + t0*u0*t0)*p3.x + t0*t0*t0*p4.x), (u0*u0*u0*p1.y + (t0*u0*u0 + u0*t0*u0 + u0*u0*t0)*p2.y + (t0*t0*u0 + u0*t0*t0 + t0*u0*t0)*p3.y + t0*t0*t0*p4.y));
    
    newP2 = CGPointMake((u0*u0*u1*p1.x + (t0*u0*u1 + u0*t0*u1 + u0*u0*t1)*p2.x + (t0*t0*u1 + u0*t0*t1 + t0*u0*t1)*p3.x + t0*t0*t1*p4.x), (u0*u0*u1*p1.y + (t0*u0*u1 + u0*t0*u1 + u0*u0*t1)*p2.y + (t0*t0*u1 + u0*t0*t1 + t0*u0*t1)*p3.y + t0*t0*t1*p4.y));
    
    newP3 = CGPointMake((u0*u1*u1*p1.x + (t0*u1*u1 + u0*t1*u1 + u0*u1*t1)*p2.x + (t0*t1*u1 + u0*t1*t1 + t0*u1*t1)*p3.x + t0*t1*t1*p4.x), (u0*u1*u1*p1.y + (t0*u1*u1 + u0*t1*u1 + u0*u1*t1)*p2.y + (t0*t1*u1 + u0*t1*t1 + t0*u1*t1)*p3.y + t0*t1*t1*p4.y));
    
    newP4 = CGPointMake((u1*u1*u1*p1.x + (t1*u1*u1 + u1*t1*u1 + u1*u1*t1)*p2.x + (t1*t1*u1 + u1*t1*t1 + t1*u1*t1)*p3.x + t1*t1*t1*p4.x), (u1*u1*u1*p1.y + (t1*u1*u1 + u1*t1*u1 + u1*u1*t1)*p2.y + (t1*t1*u1 + u1*t1*t1 + t1*u1*t1)*p3.y + t1*t1*t1*p4.y));

    // as we switched the points round to calculate the second half, we must switch them back here
    point2.cp1 = p3;
    point2.cp2 = p2;
    
    return insertedPoint;
    
}




// will return the approximate (curves are not exact) length a path from an array of SBBezierPoints
-(float)approximateLengthOfPath:(NSMutableArray*)pathPoints{

    int index = 0;
    SBBezierPoint *previousPoint = nil;
    float pathLength = 0;
    for (SBBezierPoint *point in pathPoints) {
        
        NSLog(@"adding path length");
       
        if (index == 0) {
            previousPoint = point;
            point.perimeterPct = 0;
            point.length = 0;
            index++;
            continue;
        }
        
        float length;
        
        switch (point.curveType) {
            case kMoveToPoint:
            {
                length = 0;
            }
            case kLineToPoint:
            {
                length = calculatePointsDistance(previousPoint.loc, point.loc);
            }
                break;
            case kQuadCurveToPoint:
                // convert to a cubic curve
            {
                CGPoint newCP1;
                CGPoint newCP2;
                [self convertBezierFromQuatraticToCubicP0: previousPoint.loc p1:point.cp1 p3:point.loc newP1:&newCP1 newP2:&newCP2];
                point.cp1 = newCP1;
                point.cp2 = newCP2;
                point.curveType = kCurveToPoint;
                
                length = [self lengthOfCubicBezierP0:previousPoint.loc p1:point.cp1 p2:point.cp2 p3:point.loc];
                
            }
                break;
            case kCurveToPoint:
            {
                length = [self lengthOfCubicBezierP0:previousPoint.loc p1:point.cp1 p2:point.cp2 p3:point.loc];
            }
                break;
            case kCloseSubpath:
            {
                SBBezierPoint *firstPoint = [pathPoints firstObject];
                length = calculatePointsDistance(firstPoint.loc, point.loc);
            }
                break;
            default:
                break;
        }
   
        pathLength += length;
        NSLog(@"pathlength = %f", pathLength);
        point.length = length;
 
        // increment
       index++;
        previousPoint = point;
        
    }
    
    return pathLength;
}




// only pointer to the control points are passed in, the start and end points will allways be the same
-(void)convertBezierFromQuatraticToCubicP0:(CGPoint)p0 p1:(CGPoint)p1 p3:(CGPoint)p3 newP1:(CGPoint*)newP1 newP2:(CGPoint*)newP2{

    NSLog(@"convert bezier from quadratic to cubic");
    
#define kN 2.0f
    
    *newP1 = CGPointMake( (1.0f/(kN+1.0f))*p0.x + (1.0f-(1.0f/(kN+1.0f)))*p1.x , (1.0f/(kN+1.0f))*p0.y + (1.0f-(1.0f/(kN+1.0f)))*p1.y);
    *newP2 = CGPointMake( (2.0f/(kN+1.0f))*p1.x + (1.0f-(2.0f/(kN+1.0f)))*p3.x , (2.0f/(kN+1.0f))*p1.y + (1.0f-(2.0f/(kN+1.0f)))*p3.y);

}





/*
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
 */


#pragma mark obtaining points on lines

-(NSMutableArray*)segmentPointsForPath:(NSMutableArray*)path{
   
    //NSMutableArray *points = [path getAllPoints];
    
    // draw the path with just lines between close points
    int index = 0;
    
    NSMutableArray *segmentPoints = [[NSMutableArray alloc]init];
    
    for (SBBezierPoint *point in path) {
        
        if (point.curveType == kMoveToPoint) {
            // do nothing
        }
        else if (point.curveType == kLineToPoint){
            SBBezierPoint *prevPoint = [path objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnLinep1:prevPoint.loc p2:point.loc];
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        else if (point.curveType == kCurveToPoint){
            SBBezierPoint *prevPoint = [path objectAtIndex:index-1];
            NSArray *segPointsArray = [self calculatePointsOnCubicBezierWithOrigin:prevPoint.loc c1:point.cp1 c2:point.cp2 destination:point.loc];
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
            
        }
        else if (point.curveType == kQuadCurveToPoint){
            
            SBBezierPoint *prevPoint = [path objectAtIndex:index-1];
            NSMutableArray *segPointsArray = [self calculateAllPointsOnQuadBezier:point previousPoint:prevPoint];
            for (NSValue *value in segPointsArray) {
                [segmentPoints addObject:value];
                }
        }
        else if (point.curveType == kCloseSubpath){
            //close subpath is a line with no location, just connect the previous point to the first point
            CGPoint previousLoc = ((SBBezierPoint*)[path objectAtIndex:index-1]).loc;
            CGPoint firstLoc = ((SBBezierPoint*)[path firstObject]).loc;
            NSMutableArray *segPointsArray =  [self calculateAllPointsOnLinep1:previousLoc p2:firstLoc];
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

#pragma mark Getting Path Lengths



-(float)lengthOfCubicBezierP0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3{
    
    float t;
    
    double length = 0;
    
    CGPoint prevPoint;
    BOOL firstPoint = YES;
    
    t = 0;
    for (int i = 0; i < _lengthSamplingDivisions; i++) {
        
        float x = powf(1 - t, 3) * p0.x + 3.0f * powf(1 - t, 2) * t * p1.x + 3.0f * (1 - t) * t * t * p2.x + t * t * t * p3.x;
        float y = powf(1 - t, 3) * p0.y + 3.0f * powf(1 - t, 2) * t * p1.y + 3.0f * (1 - t) * t * t * p2.y + t * t * t * p3.y;
        t += 1.0f / _lengthSamplingDivisions;
        
        if (!firstPoint) {
            length += sqrt(((x-prevPoint.x) * (x-prevPoint.x)) + ((y-prevPoint.y) * (y-prevPoint.y)));
        }
        
        
        prevPoint = CGPointMake(x, y);
        firstPoint = NO;
        
        
    }
    return length;
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

-(void)debugDrawDotAt:(CGPoint)loc radius:(float)radius{
    
    //[[UIColor redColor]set];
    
    CGRect rect = CGRectMake(loc.x-radius, loc.y-radius, radius*2, radius*2);
    [[UIBezierPath bezierPathWithOvalInRect:rect]fill];

}

-(void)debugPrintPoints:(NSMutableArray*)pathPoints{

    for (SBBezierPoint *point in pathPoints) {
        NSLog(@"(%f, %f) <-----> (%f, %f)", point.loc.x, point.loc.y, point.mirrorPoint.loc.x, point.mirrorPoint.loc.y);
    }

}




@end
