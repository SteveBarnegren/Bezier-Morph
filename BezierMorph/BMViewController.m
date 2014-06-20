
    
//
//  BMViewController.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BMViewController.h"
#import "SBMorphingBezierView.h"

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
              [self arrowPathWithCentre:middle scale:50],
              [self plusSignPathWithCentre:middle scale:40],
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
    
    [self morphToNextPath];
    //[self drawTwoRandomPaths];
    
    
    
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
    
    [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1];

    
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
    
    // block based (with shadow)
    
     UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
     
     int newPathNum;
     do {
     newPathNum = arc4random() % _paths.count;
     } while (newPathNum == _pathNum);
     
     UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];
    
    static BOOL onColour1 = YES;
    onColour1 = !onColour1;
     
     [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1 timingFunc:SBTimingFunctionExponentialInOut drawBlock:^(UIBezierPath *path, float t) {
         
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
    
    
}

-(UIBezierPath*)plusSignPathWithCentre:(CGPoint)centre scale:(float)scale{
    
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








@end
