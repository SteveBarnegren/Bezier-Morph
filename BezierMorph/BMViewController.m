
    
//
//  BMViewController.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BMViewController.h"
#import "SBMorphingBezierView.h"
#import "UIBezierPath+BezierCreator.h"

@import CoreText;

@interface BMViewController ()

@property(nonatomic, strong) SBMorphingBezierView *bezierMorphView;
@property(nonatomic, strong) NSArray* paths;
@property int pathNum;
@end

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // do the performance test
    //[self performSelector:@selector(doPerformanceTest) withObject:nil afterDelay:5];
   // return;
    

    _pathNum = 0;
    
    NSLog(@"view did load");
    
    _bezierMorphView = [[SBMorphingBezierView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_bezierMorphView];

    CGPoint middle = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    CGPoint topLeft = CGPointMake(middle.x - 100, middle.y - 100);
    CGPoint topRight = CGPointMake(middle.x + 100, middle.y + 100);
    
    _paths = [NSArray arrayWithObjects:
              [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200) cornerRadius:15],
             [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)],
              [self plusSignPathWithCentre:middle scale:40],
              [self arrowPathWithCentre:middle scale:50],
              [self jigsawPath],
              [self birdPath],

              [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)],
              [self tPathWithCentre:middle scale:40],
              [UIBezierPath bezierPathWithRect:CGRectMake(middle.x - 10, middle.y- 100, 20, 200)],
              [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 10, middle.y - 10, 20, 20)],
              [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 125, middle.y - 20, 250, 40)],
              [UIBezierPath bezierPathWithOvalInRect:CGRectMake(topLeft.x, topLeft.y, 7, 7)],
              [self plusSignPathWithCentre:topLeft scale:5],
              [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 20) cornerRadius:10],
              [self letterCPathWithCentre:middle],
             nil];
    
    /*
    _paths = [NSArray arrayWithObjects:
              [UIBezierPath bezierPathWithRect:CGRectMake(middle.x - 10, middle.y- 100, 20, 200)],
              [self tPathWithCentre:middle scale:-40],
              nil];
    */
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(morphToNextPath) userInfo:nil repeats:NO];
    
    //[self morphToNextPath];
    //[self drawTwoRandomPaths];
    //[self drawMultipleStrokedBeziers];
    [self doPathsSequentialBasic];

}

-(void)doPathsSequentialBasic{
    
    
    
    // basic sequential
    
    static int pathNum = 0;
    
    
     UIBezierPath *path1 =[_paths objectAtIndex:pathNum];
     int nextIndex = pathNum+1;
     if (nextIndex >= _paths.count) {
     nextIndex = 0;
     }
     UIBezierPath *path2 =[_paths objectAtIndex:nextIndex];
     
     [_bezierMorphView morphFromPath:path1 toPath:path2 duration:2 timingFunc:SBTimingFunctionLinear drawBlock:^(UIBezierPath *path, float t) {
         
         [path stroke];
         
     } completionBlock:^{
         
         [self performSelector:@selector(doPathsSequentialBasic) withObject:nil afterDelay:3];
     }];
     
     
     pathNum++;
     if (pathNum >= _paths.count) {
     pathNum = 0;
     }
     

   
}





-(void)morphToNextPath{
    
    // basic sequential
    
    /*
    UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
    int nextIndex = _pathNum+1;
    if (nextIndex >= _paths.count) {
        nextIndex = 0;
    }
    UIBezierPath *path2 =[_paths objectAtIndex:nextIndex];
    
    [_bezierMorphView morphFromPath:path1 toPath:path2 duration:5];

    
    _pathNum++;
    if (_pathNum >= _paths.count) {
        _pathNum = 0;
    }
     
     */
    
    /*
    // basic random
    
    UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
    
    int newPathNum;
    do {
        newPathNum = arc4random() % _paths.count;
    } while (newPathNum == _pathNum);
    
    UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];

    [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1];
    
    _pathNum = newPathNum;
*/
    /*
    // block based (with shadow)
    
    //_bezierMorphView.accuracy = 0.3;
    
     UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
     
     int newPathNum;
     do {
     newPathNum = arc4random() % _paths.count;
     } while (newPathNum == _pathNum);
     
     UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];
    
    static BOOL onColour1 = YES;
    onColour1 = !onColour1;
     
     [_bezierMorphView morphFromPath:path1 toPath:path2 duration:10 timingFunc:SBTimingFunctionExponentialInOut drawBlock:^(UIBezierPath *path, float t) {
         
         UIColor *colour1 = [UIColor colorWithRed:1*t green:0 blue:1-(1*t) alpha:1];
         UIColor *colour2 = [UIColor colorWithRed:1-(1*t) green:0 blue:1*t alpha:1];
       
         [(onColour1?colour1:colour2)set];
         
         [path fill];

         [(onColour1?colour2:colour1)set];
         
         // draw shadows
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextAddPath(context, path.CGPath);
         CGContextSetLineWidth(context, 2.0);
         CGContextSetBlendMode(context, kCGBlendModeNormal);
         CGContextSetShadowWithColor(context, CGSizeMake(1.0, 1.0), 2.0, [UIColor blackColor].CGColor);
         CGContextStrokePath(context);
         
       
     } completionBlock:^{
         NSLog(@"complete");
         [self morphToNextPath];
     }];
    
     _pathNum = newPathNum;
  */
}

-(void)drawTwoRandomPaths{
    
    _bezierMorphView.accuracy = 1;
    _bezierMorphView.matchShapeRotations = YES;
    _bezierMorphView.adjustForCentreOffset = YES;
    
    static int numPaths = 1;
    static int counter = 0;
    
    counter++;
    
    if (counter == 2) {
        numPaths+=5;
        counter = 0;
        NSLog(@"%i paths", numPaths);
    }
    
    
    
    
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableArray *array2 = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < numPaths; i++) {
        
        [array addObject:[_paths objectAtIndex:arc4random()%_paths.count]];
        [array2 addObject:[_paths objectAtIndex:arc4random()%_paths.count]];
        
    }
    
    [_bezierMorphView morphFromPaths:array toPaths:array2 duration:3 timingFunc:SBTimingFunctionElasticOut drawBlock:^(NSArray *paths, float t) {
        
        for (UIBezierPath *path in paths) {
            
            // fill
            [[UIColor orangeColor]set];
            [path fill];
            
            [[UIColor blackColor]set];
            [path stroke];
        }
        
  
    } completionBlock:^{
        
       
        [self drawTwoRandomPaths];
        
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Path Constructors

-(UIBezierPath*)arrowPathWithCentre:(CGPoint)centre scale:(float)scale{
    /*
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    [path moveToPoint:CGPointMake(centre.x, centre.y - (2*scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x + (2*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x + (2*scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y + (2*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(2 * scale), centre.y)];
    [path closePath];
    
    return path;
    */
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    [path moveToPoint:CGPointMake(centre.x -(2 * scale), centre.y)];
    [path addLineToPoint:CGPointMake(centre.x, centre.y + (2*scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x + (2*scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x + (2*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x, centre.y - (2*scale))];

    
    
    
    
    [path closePath];
    
    return path;
    

    
    
}

-(UIBezierPath*)plusSignPathWithCentre:(CGPoint)centre scale:(float)scale{
    /*
    UIBezierPath *path = [[UIBezierPath alloc]init];
     [path moveToPoint:CGPointMake(centre.x -(3*scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(3*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y + (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y + (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y + (scale))];
    [path closePath];
    return path;
    */
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(centre.x -(scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y + (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y + (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y + (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(3*scale), centre.y - (scale))];
    [path addLineToPoint:CGPointMake(centre.x -(3*scale), centre.y + (scale))];
    [path closePath];
    return path;

    
    
}

-(UIBezierPath*)tPathWithCentre:(CGPoint)centre scale:(float)scale{
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(centre.x -(3*scale), centre.y + (2*scale))];
    [path addLineToPoint:CGPointMake(centre.x -(3*scale), centre.y)];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y)];
    [path addLineToPoint:CGPointMake(centre.x -(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y - (3*scale))];
    [path addLineToPoint:CGPointMake(centre.x +(scale), centre.y)];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y)];
    [path addLineToPoint:CGPointMake(centre.x +(3*scale), centre.y + (2*scale))];
    [path closePath];
    return path;
}

-(UIBezierPath*)letterCPathWithCentre:(CGPoint)centre{
    
    CGGlyph glyph = 'W';
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)@"Helvetica", 85, NULL);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGPathRef path = CTFontCreatePathForGlyph(font, glyph, &transform);
    UIBezierPath *bezier = [UIBezierPath bezierPathWithCGPath:path];
    CGPathRelease(path);
    CFRelease(font);
    
    return bezier;
    
}

-(void)drawMultipleStrokedBeziers{
    
    UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
    
    int newPathNum;
    do {
        newPathNum = arc4random() % _paths.count;
    } while (newPathNum == _pathNum);
    
    UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];
    
    static BOOL onColour1 = YES;
    onColour1 = !onColour1;
    
    _bezierMorphView.accuracy = 1;
    _bezierMorphView.antialiasDrawing = YES;
    
    [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1 timingFunc:SBTimingFunctionExponentialInOut drawBlock:^(UIBezierPath *path, float t) {
        
        
        const int numCopies = 0;
        
        [[UIColor blackColor]set];
        [path stroke];
        for (int i = 0; i < numCopies; i++) {
            UIBezierPath *pathCopy = [UIBezierPath bezierPathWithScaledBezierPath:path aroundPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2) scale: 1 + (0.1 * i)];
            [pathCopy stroke];
            
            
            
        }
     
        
    } completionBlock:^{
        NSLog(@"complete");
        [self drawMultipleStrokedBeziers];
    }];
    
    _pathNum = newPathNum;
  
}

-(UIBezierPath*)birdPath{
    
      //// Frames
    CGRect frame = CGRectMake(0, 0, 1001, 1001);
    
    //// Bird Drawing
    UIBezierPath* birdPath = [UIBezierPath bezierPath];
    [birdPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 195.42, CGRectGetMinY(frame) + 748.85)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 328.15, CGRectGetMinY(frame) + 666.97) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 245.86, CGRectGetMinY(frame) + 734.45) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 234.02, CGRectGetMinY(frame) + 727.21)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 170.17, CGRectGetMinY(frame) + 436.34) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 327.65, CGRectGetMinY(frame) + 667.47) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 138, CGRectGetMinY(frame) + 572.83)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 98.42, CGRectGetMinY(frame) + 399.77) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 147.64, CGRectGetMinY(frame) + 435.21) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 99.41, CGRectGetMinY(frame) + 423.16)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 135.88, CGRectGetMinY(frame) + 389.35) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 98.12, CGRectGetMinY(frame) + 392.86) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 128.05, CGRectGetMinY(frame) + 388.66)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 98.47, CGRectGetMinY(frame) + 356.32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 117.3, CGRectGetMinY(frame) + 383.21) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 98.47, CGRectGetMinY(frame) + 372.32)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 145.57, CGRectGetMinY(frame) + 347.69) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 98.47, CGRectGetMinY(frame) + 338.85) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 125.77, CGRectGetMinY(frame) + 347.85)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 91.88, CGRectGetMinY(frame) + 299.84) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 132.77, CGRectGetMinY(frame) + 346.23) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 86.22, CGRectGetMinY(frame) + 314.9)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 144.59, CGRectGetMinY(frame) + 305.49) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 97.93, CGRectGetMinY(frame) + 283.71) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 127.55, CGRectGetMinY(frame) + 306.04)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 92.82, CGRectGetMinY(frame) + 270.66) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 129.4, CGRectGetMinY(frame) + 301.99) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 104.12, CGRectGetMinY(frame) + 283.84)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 90.98, CGRectGetMinY(frame) + 240.49) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 85.5, CGRectGetMinY(frame) + 262.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 78, CGRectGetMinY(frame) + 240.81)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 123.57, CGRectGetMinY(frame) + 247.18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 100.68, CGRectGetMinY(frame) + 240.26) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 114.62, CGRectGetMinY(frame) + 244.09)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 85.28, CGRectGetMinY(frame) + 203.83) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 104.88, CGRectGetMinY(frame) + 241.55) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 83.27, CGRectGetMinY(frame) + 226)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 124.58, CGRectGetMinY(frame) + 218.1) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 87.17, CGRectGetMinY(frame) + 183.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 116.57, CGRectGetMinY(frame) + 215.01)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 93.01, CGRectGetMinY(frame) + 144.7) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 112.16, CGRectGetMinY(frame) + 205.23) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 77.76, CGRectGetMinY(frame) + 167.12)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 133.97, CGRectGetMinY(frame) + 175.53) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 98.06, CGRectGetMinY(frame) + 137.26) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 126.96, CGRectGetMinY(frame) + 171.51)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 106.91, CGRectGetMinY(frame) + 101.14) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 128.71, CGRectGetMinY(frame) + 169.92) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 85.36, CGRectGetMinY(frame) + 102.75)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 145.76, CGRectGetMinY(frame) + 152.78) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 113.54, CGRectGetMinY(frame) + 100.64) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 138.14, CGRectGetMinY(frame) + 142.69)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 167.06, CGRectGetMinY(frame) + 181.11) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 151.92, CGRectGetMinY(frame) + 160.93) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 159.68, CGRectGetMinY(frame) + 174.86)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 138.69, CGRectGetMinY(frame) + 95.32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 160.15, CGRectGetMinY(frame) + 171.61) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 120.98, CGRectGetMinY(frame) + 103.47)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 205.87, CGRectGetMinY(frame) + 207.3) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 146.84, CGRectGetMinY(frame) + 91.57) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 199.03, CGRectGetMinY(frame) + 192.49)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 198.4, CGRectGetMinY(frame) + 112.32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 197.82, CGRectGetMinY(frame) + 188.47) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 170.17, CGRectGetMinY(frame) + 105.93)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 208.74, CGRectGetMinY(frame) + 156.18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 204.26, CGRectGetMinY(frame) + 113.64) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 206.73, CGRectGetMinY(frame) + 148.86)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 271.19, CGRectGetMinY(frame) + 271.52) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 220.18, CGRectGetMinY(frame) + 197.71) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 240.44, CGRectGetMinY(frame) + 240.77)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 451.35, CGRectGetMinY(frame) + 412.05) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 307.22, CGRectGetMinY(frame) + 307.55) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 382.89, CGRectGetMinY(frame) + 354.4)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 549.08, CGRectGetMinY(frame) + 522.13) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 482.21, CGRectGetMinY(frame) + 438.04) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 518.88, CGRectGetMinY(frame) + 485.3)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 575.03, CGRectGetMinY(frame) + 466.61) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 556.49, CGRectGetMinY(frame) + 503.48) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 566.11, CGRectGetMinY(frame) + 484.64)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 627.92, CGRectGetMinY(frame) + 378.19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 586.18, CGRectGetMinY(frame) + 444.08) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 607.25, CGRectGetMinY(frame) + 385.65)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 649.24, CGRectGetMinY(frame) + 396.35) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 643.86, CGRectGetMinY(frame) + 372.43) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 643.48, CGRectGetMinY(frame) + 391.53)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 659.46, CGRectGetMinY(frame) + 304.76) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 651.19, CGRectGetMinY(frame) + 387) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 626.67, CGRectGetMinY(frame) + 327.6)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 692.83, CGRectGetMinY(frame) + 337.27) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 667.92, CGRectGetMinY(frame) + 298.86) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 688.88, CGRectGetMinY(frame) + 325.9)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 696.82, CGRectGetMinY(frame) + 250.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 686.96, CGRectGetMinY(frame) + 310.85) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 676.48, CGRectGetMinY(frame) + 260.46)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 732.62, CGRectGetMinY(frame) + 282.99) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 711.01, CGRectGetMinY(frame) + 243.1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 722.45, CGRectGetMinY(frame) + 263)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 720.21, CGRectGetMinY(frame) + 237.59) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 727.5, CGRectGetMinY(frame) + 268.1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 722.18, CGRectGetMinY(frame) + 253.28)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 725.7, CGRectGetMinY(frame) + 194.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 718.61, CGRectGetMinY(frame) + 224.84) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 714.11, CGRectGetMinY(frame) + 203.92)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 769.94, CGRectGetMinY(frame) + 244.86) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 751.78, CGRectGetMinY(frame) + 173.28) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 750.92, CGRectGetMinY(frame) + 214.9)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 761.39, CGRectGetMinY(frame) + 187.89) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 765.38, CGRectGetMinY(frame) + 221.7) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 761.53, CGRectGetMinY(frame) + 208.38)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 776.69, CGRectGetMinY(frame) + 144.34) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 761.3, CGRectGetMinY(frame) + 174.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 763.62, CGRectGetMinY(frame) + 152.6)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 810.77, CGRectGetMinY(frame) + 222.11) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 808.3, CGRectGetMinY(frame) + 124.36) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 803.1, CGRectGetMinY(frame) + 200.86)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 818.19, CGRectGetMinY(frame) + 141.32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 817.28, CGRectGetMinY(frame) + 194.49) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 810.75, CGRectGetMinY(frame) + 164.26)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 850.54, CGRectGetMinY(frame) + 98.67) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 822.91, CGRectGetMinY(frame) + 126.76) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 829.09, CGRectGetMinY(frame) + 97.29)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 861.32, CGRectGetMinY(frame) + 116.03) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 859.55, CGRectGetMinY(frame) + 99.25) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 862.32, CGRectGetMinY(frame) + 107.14)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 859.25, CGRectGetMinY(frame) + 159.57) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 859.23, CGRectGetMinY(frame) + 134.56) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 859.1, CGRectGetMinY(frame) + 145.85)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 865.41, CGRectGetMinY(frame) + 232.51) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 859.38, CGRectGetMinY(frame) + 170.79) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 866, CGRectGetMinY(frame) + 212.29)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 880.81, CGRectGetMinY(frame) + 149.52) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 868.41, CGRectGetMinY(frame) + 209.78) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 877.26, CGRectGetMinY(frame) + 161.08)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 915.23, CGRectGetMinY(frame) + 123.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 884.84, CGRectGetMinY(frame) + 136.4) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 906.13, CGRectGetMinY(frame) + 108.31)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 921.79, CGRectGetMinY(frame) + 165.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 920.2, CGRectGetMinY(frame) + 131.56) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 921.11, CGRectGetMinY(frame) + 155.92)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 925.19, CGRectGetMinY(frame) + 195.84) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 922.55, CGRectGetMinY(frame) + 175.25) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 924.29, CGRectGetMinY(frame) + 185.57)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 900.99, CGRectGetMinY(frame) + 318.11) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 928.9, CGRectGetMinY(frame) + 238.4) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 921.2, CGRectGetMinY(frame) + 280.38)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 741.41, CGRectGetMinY(frame) + 502.14) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 867.24, CGRectGetMinY(frame) + 381.17) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 781.24, CGRectGetMinY(frame) + 453.28)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 700.49, CGRectGetMinY(frame) + 574.86) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 710.38, CGRectGetMinY(frame) + 540.21) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 698.67, CGRectGetMinY(frame) + 548.05)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 757.62, CGRectGetMinY(frame) + 563.38) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 725.42, CGRectGetMinY(frame) + 573.58) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 747.81, CGRectGetMinY(frame) + 570.4)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 836.89, CGRectGetMinY(frame) + 552.56) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 782.84, CGRectGetMinY(frame) + 545.36) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 804.46, CGRectGetMinY(frame) + 541.76)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 865.72, CGRectGetMinY(frame) + 621.03) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 869.32, CGRectGetMinY(frame) + 563.38) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 870.36, CGRectGetMinY(frame) + 611.43)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 869.41, CGRectGetMinY(frame) + 666.97) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 874.12, CGRectGetMinY(frame) + 646.25) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 869.41, CGRectGetMinY(frame) + 666.97)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 845.88, CGRectGetMinY(frame) + 645.31) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 869.41, CGRectGetMinY(frame) + 666.97) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 857.18, CGRectGetMinY(frame) + 653.78)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 820.47, CGRectGetMinY(frame) + 638.72) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 835.49, CGRectGetMinY(frame) + 637.52) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 820.47, CGRectGetMinY(frame) + 638.72)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 772.03, CGRectGetMinY(frame) + 671.47) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 820.47, CGRectGetMinY(frame) + 638.72) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 800.85, CGRectGetMinY(frame) + 649.86)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 696.37, CGRectGetMinY(frame) + 714.72) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 743.2, CGRectGetMinY(frame) + 693.09) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 725.19, CGRectGetMinY(frame) + 689.49)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 519.8, CGRectGetMinY(frame) + 783.18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 667.54, CGRectGetMinY(frame) + 739.94) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 570.25, CGRectGetMinY(frame) + 783.18)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 332.44, CGRectGetMinY(frame) + 793.98) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 469.36, CGRectGetMinY(frame) + 783.18) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 393.7, CGRectGetMinY(frame) + 779.58)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 129.53, CGRectGetMinY(frame) + 833.59) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 271.19, CGRectGetMinY(frame) + 808.4) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 187.06, CGRectGetMinY(frame) + 833.59)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 56.11, CGRectGetMinY(frame) + 794.98) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 72, CGRectGetMinY(frame) + 833.59) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 67.4, CGRectGetMinY(frame) + 816.64)];
    [birdPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 195.42, CGRectGetMinY(frame) + 748.85) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 40.3, CGRectGetMinY(frame) + 764.68) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 144.98, CGRectGetMinY(frame) + 763.28)];
    [birdPath closePath];
    
    return birdPath;
    
    
}

-(UIBezierPath*)jigsawPath{
    
    //// Frames
   // CGRect frame = CGRectMake(110, 26, 811, 809);
    CGRect frame = [self convertFrameToDrawFrame:CGRectZero];
 
    //// jigsaw Drawing
    UIBezierPath* jigsawPath = [UIBezierPath bezierPath];
    [jigsawPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46231 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25304 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53297 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24983 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17898 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25505 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21764 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46874 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08565 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46301 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14935 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47379 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14098 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34784 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00228 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46294 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02229 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39973 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00169 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21667 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08398 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29357 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00293 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23416 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03173 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23526 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17477 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20516 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20549 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15278 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24713 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23695 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25150 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18679 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28744 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20452 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22537 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00350 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47611 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00628 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23369 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + -0.00336 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42236 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07053 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48804 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00743 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50699 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04555 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52144 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22097 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57121 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.10906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43656 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21558 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47015 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65222 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22664 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67724 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.11385 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69357 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00032 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65325 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.06730 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61357 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60396 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + -0.00399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24074 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99784 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.03184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97421 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00833 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91622 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27089 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99291 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28473 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94073 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35985 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78716 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23108 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89370 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22569 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77333 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42057 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90660 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46481 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79798 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44728 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88983 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44950 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98706 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92269 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39610 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97281 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52256 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00660 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71984 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95841 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71490 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77823 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81560 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70698 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73517 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65732 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.80666 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69504 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60861 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78424 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73830 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.80598 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50093 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41974 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45556 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72283 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50739 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78817 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55089 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.72924 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53808 * CGRectGetHeight(frame))];
    [jigsawPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70778 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43568 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24016 * CGRectGetHeight(frame))];
    [jigsawPath closePath];
  
    return jigsawPath;
    
    
}





#pragma mark Debug
-(void)debugDrawDotAt:(CGPoint)loc{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(loc.x, loc.y, 5, 5)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    
}

-(void)doPerformanceTest{
    
    int numTimes = 1000;
    
    CGPoint middle = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    int shapeIndex = 0;

    
    NSArray *array = [NSArray arrayWithObjects: [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200) cornerRadius:15],
                                                [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)],
                                                [UIBezierPath bezierPathWithRect:CGRectMake(middle.x - 10, middle.y- 100, 20, 200)], nil];
    
    
    
    SBMorphingBezierView *bezierView = [[SBMorphingBezierView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:bezierView];
    
    double startTime = CACurrentMediaTime();
    NSLog(@"Starting - %f", startTime);
    
    for (int i = 0; i < numTimes; i++) {
        
        int prevShapeIndex = shapeIndex - 1;
        
        if (prevShapeIndex < 0) {
            prevShapeIndex = array.count-1;
        }
        
        [bezierView stopMorphing];
        [bezierView morphFromPath:[array objectAtIndex:prevShapeIndex] toPath:[array objectAtIndex:shapeIndex] duration:10];
        
        shapeIndex++;
        if (shapeIndex >= array.count) {
            shapeIndex = 0;
        }
    }
    
    double finishTime = CACurrentMediaTime();
    NSLog(@"Finished - %f", finishTime);
    NSLog(@"Time taken - %f", finishTime - startTime);

    
}

-(CGRect)convertFrameToDrawFrame:(CGRect)frame{
    
    CGRect drawFrame = self.view.frame;
    
    // make draw frame square
    if (drawFrame.size.width < drawFrame.size.height) {
        drawFrame.size.height = drawFrame.size.width;
    }
    else{
        drawFrame.size.width = drawFrame.size.height;
    }
    
    
    // centre the frame
    
    
    
    
    
    
    return drawFrame;
    
    
    
    
    
    
}









@end
