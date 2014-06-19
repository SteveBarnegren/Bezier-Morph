
    
//
//  BMViewController.m
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BMViewController.h"
#import "BezierMorphView.h"

@interface BMViewController ()

@property(nonatomic, strong) BezierMorphView *bezierMorphView;
@property(nonatomic, strong) NSArray* paths;
@property int pathNum;
@end

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _pathNum = 0;
    
    NSLog(@"view did load");
    
    _bezierMorphView = [[BezierMorphView alloc]initWithFrame:self.view.frame];
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
             nil];
    
    /*
    _paths = [NSArray arrayWithObjects:
              [self plusSignPathWithCentre:CGPointMake(middle.x - 20, middle.y - 20) scale:40],
              [UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 50, middle.y - 50, 100, 100)],
              nil];
*/
    /*
    _paths = [NSArray arrayWithObjects:
              [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 20) cornerRadius:10],
              [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200) cornerRadius:15],
              nil];
*/
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(morphToNextPath) userInfo:nil repeats:YES];
    
    
    
    
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
    
    // basic random
    /*
    UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
    
    int newPathNum;
    do {
        newPathNum = arc4random() % _paths.count;
    } while (newPathNum == _pathNum);
    
    UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];

    [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1];
    
    _pathNum = newPathNum;
*/
    
    // block based
    
   
     UIBezierPath *path1 =[_paths objectAtIndex:_pathNum];
     
     int newPathNum;
     do {
     newPathNum = arc4random() % _paths.count;
     } while (newPathNum == _pathNum);
     
     UIBezierPath *path2 =[_paths objectAtIndex:newPathNum];
    
    static BOOL onColour1 = YES;
    onColour1 = !onColour1;
     
     [_bezierMorphView morphFromPath:path1 toPath:path2 duration:1 timingFunc:kMorphingBezierTimingFunctionElasticOut drawBlock:^(UIBezierPath *path, float t) {
         
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
         
       
     }];
    
     
     _pathNum = newPathNum;
   
    
    
    
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



#pragma mark Debug
-(void)debugDrawDotAt:(CGPoint)loc{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(loc.x, loc.y, 5, 5)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    
}








@end
