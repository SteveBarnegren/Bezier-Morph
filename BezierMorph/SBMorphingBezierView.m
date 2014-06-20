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

@implementation SBMorphingBezierView{
    
    NSMutableArray *_connectionsArray;
    UIBezierPath *_currentPath;
    
    NSTimer *_morphTimer;
    double _startTime;
    float _morphDuration;
    float _morphPct;
    
    BOOL _usingReversedConnections; //if we actually need to morph from path2 to path1
    
    float _period; // precalculated for use in ease functions
    SBMorphingBezierTimingFunction _timingFunction;
    
    // drawing
    BOOL _useBlockDrawing;
    DrawBlock _drawBlock;


}

-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        // init ivars
        _connectionsArray = nil;
        

        _morphTimer = nil;
        _morphDuration = 0;
        _morphPct = 0;
        _usingReversedConnections = YES;
        _accuracy = 1;
        _lengthSamplingDivisions = kDefaultLengthSamplingDivisions;
        
        _timingFunction = SBMorphingBezierTimingFunctionSineOut;
        
        _period = 0.3f * 1.5f; // 0.3?
        
        _useBlockDrawing = NO;
        
        // drawing properties
        _strokeWidth = 1.0f;
        _strokeColour = [UIColor blackColor];
        _fillColour = [UIColor whiteColor];

    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    // don't draw if there's no path
    if (_connectionsArray == nil) {
        return;
    }
    
    // apply the timing function
    float t = [self applyTimingFuction:_timingFunction toTime:_morphPct];

    // construct the path
    UIBezierPath *path = [[UIBezierPath alloc]init];
    BOOL isFirstPoint = YES;
    
    for (PointConnection *connection in _connectionsArray) {
    
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
    //path.miterLimit = 0;
    //path.lineJoinStyle = kCGLineJoinBevel;
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
        //NSLog(@"new start index = %i", newStartIndex);
        
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
     

   // NSLog(@"path1 points: %i", path1Count);
   // NSLog(@"path2 points: %i", path2Count);
    
    float ratio = (float)path2.count/(float)path1.count;
    
    //NSLog(@"ratio = %f", ratio);
    
    int index = 0;
    
    for (NSValue *value in path1) {
        // get the corresponding point in the other path at the correct ratio
        int correspondingIndex = index*ratio;
        NSValue *correspondingPoint = [path2 objectAtIndex:correspondingIndex];
       // NSLog(@"CONNECTION (%f, %f) %i  <-->  %i (%f, %f)",value.CGPointValue.x, value.CGPointValue.y, index, (int)(index*ratio), correspondingPoint.CGPointValue.x, correspondingPoint.CGPointValue.y );
        
        PointConnection *connection = [[PointConnection alloc]init];
        connection.p1 = value.CGPointValue;
        connection.p2 = correspondingPoint.CGPointValue;
        [connectionsArray addObject:connection];
        
        index++;
        
    }

    return connectionsArray;
  
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

-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration timingFunc:(SBMorphingBezierTimingFunction)tf{
    
    [self stopMorphing];
    
    [self morphFromPath:path1 toPath:path2 duration:duration];
    _timingFunction = tf;

}

-(void)morphFromPath:(UIBezierPath*)path1 toPath:(UIBezierPath*)path2 duration:(float)duration{
    
    [self stopMorphing];
    
    _morphDuration = duration;
    _morphPct = 0;
    
    //UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(40, 40, 200, 200)];
    NSMutableArray *path1Points = [self segmentPointsForBezierPath:path1];
    //UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(40, 40, 200, 200) cornerRadius:5];
    NSMutableArray *path2Points = [self segmentPointsForBezierPath:path2];
    
    _connectionsArray = [self createConnectionsBetweenPathArraysPath1:path1Points path2:path2Points];
    
    //NSLog(@"%i connections", _connectionsArray.count);
    
    _morphTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(morphTick) userInfo:nil repeats:YES];
    _startTime = CACurrentMediaTime();
    
    _useBlockDrawing = NO;

}

-(void)morphFromPath:(UIBezierPath *)path1 toPath:(UIBezierPath *)path2 duration:(float)duration timingFunc:(SBMorphingBezierTimingFunction)tf drawBlock:(DrawBlock)drawBlock{
    
    [self stopMorphing];
    
    [self morphFromPath:path1 toPath:path2 duration:duration timingFunc:tf];
    _drawBlock = drawBlock;
    _useBlockDrawing = YES;
    
}

-(void)stopMorphing{
    
    [_morphTimer invalidate];
    _morphTimer = nil;
    
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
            //NSArray *segPointsArray = calculatePointsOnCubicBezier(prevPoint.loc, point.loc, point.cp1, point.cp2);
            NSArray *segPointsArray = [self calculatePointsOnCubicBezierWithOrigin:prevPoint.loc c1:point.cp1 c2:point.cp2 destination:point.loc];

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
    
    //NSLog(@"num segments points = %i", segmentPoints.count);
    
    return segmentPoints;
    
}




-(NSMutableArray*)calculateAllPointsOnLinep1:(CGPoint)p1 p2:(CGPoint)p2{
    
    // num samples is the length
    int numSamples = sqrt(((p2.x-p1.x) * (p2.x-p1.x)) + ((p2.y-p1.y) * (p2.y-p1.y)));
    numSamples = (float)numSamples * _accuracy;
    
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
    
    // calculate length
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

//NSArray* calculatePointsOnCubicBezier(CGPoint origin, CGPoint destination, CGPoint control1, CGPoint control2){
    
-(NSArray*)calculatePointsOnCubicBezierWithOrigin:(CGPoint)origin c1:(CGPoint)control1 c2:(CGPoint)control2 destination:(CGPoint)destination{
    
    float t;
    int segments = 100;
    
    // calculate length
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
     
     segments = (int)length;
     //segments = (float)segments * _accuracy;

    
    //NSLog(@"NUM SEGMENTS = %i", segments);
    
    CGPoint vertices[segments + 1];
    
    t = 0; // reuse t from above
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
    /*
    float xDist = p1.x - p2.x;
    float yDist = p1.y - p2.y;
    
    float dist = sqrtf((xDist*xDist)+(yDist*yDist));
    dist = fabs(dist);
    
    return dist;
     */
    
    return fabs(sqrtf(((p1.x - p2.x)*(p1.x - p2.x))+((p1.y - p2.y)*(p1.y - p2.y))));

}


#pragma mark Ease Time Manipulation

-(float)applyTimingFuction:(SBMorphingBezierTimingFunction)easeFuction toTime:(float)t{
    
    switch (_timingFunction) {
            // Linear
        case SBMorphingBezierTimingFunctionLinear:
            t = _morphPct;
            break;
            // Sine
        case SBMorphingBezierTimingFunctionSineIn:
            t = [self easeSineIn:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionSineOut:
            t = [self easeSineOut:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionSineInOut:
            t = [self easeSineInOut:_morphPct];
            break;
            // Exponential
        case SBMorphingBezierTimingFunctionExponentialIn:
            t = [self easeExponentialIn:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionExponentialOut:
            t = [self easeExponentialOut:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionExponentialInOut:
            t = [self easeExponentialInOut:_morphPct];
            break;
            // back
        case SBMorphingBezierTimingFunctionBackIn:
            t = [self easeBackIn:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionBackOut:
            t = [self easeBackOut:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionBackInOut:
            t = [self easeBackInOut:_morphPct];
            break;
            // Bounce
        case SBMorphingBezierTimingFunctionBounceIn:
            t = [self easeBounceIn:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionBounceOut:
            t = [self easeBounceOut:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionBounceInOut:
            t = [self easeBounceInOut:_morphPct];
            break;
            // Elastic
        case SBMorphingBezierTimingFunctionElasticIn:
            t = [self easeElasticIn:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionElasticOut:
            t = [self easeElasticOut:_morphPct];
            break;
        case SBMorphingBezierTimingFunctionElasticInOut:
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
    
    NSLog(@"t = %f", t);
    float newT = -1*cosf(t * (float)M_PI_2) +1;
    NSLog(@"newT = %f", t);

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
	// prevents rounding errors
	if( t !=0 && t!=1)
		newT = 1 - [self bounceTime:1-t];
    
	return newT;

}

-(float)easeBounceOut:(float)t{
    
    double newT = t;
	// prevents rounding errors
	if( t !=0 && t!=1)
		newT = [self bounceTime:t];
    
	return newT;

}

-(float)easeBounceInOut:(float)t{
    
    double newT;
	// prevents possible rounding errors
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
