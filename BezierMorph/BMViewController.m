
    
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

#import "UIBezierPath+AnimalPaths.h"
#import "UIBezierPath+MiscPaths.h"
#import "UIBezierPath+ButterflyPaths.h"
#import "UIBezierPath+BasicShapePaths.h"

@import CoreText; // get rid of the core text crap

#pragma mark - morphAnimation

@implementation MorphAnimationInfo
-(instancetype)initWithPath:(UIBezierPath*)path matchRotation:(BOOL)matchRotation rotationOffset:(float)rotationOffset{
    if (self = [super init]) {
        self.path = path;
        self.automatchRotation = matchRotation;
        self.rotationOffset = rotationOffset;
    }
    return self;
}
@end

#pragma mark - BMViewController

@interface BMViewController ()

@property(nonatomic, strong) SBMorphingBezierView *bezierMorphView;
@property(nonatomic, strong) NSArray* paths;


@property(nonatomic, strong) NSArray *animalPaths;
@property(nonatomic, strong) NSArray *butterflyPaths;

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
    
    self.bezierMorphView = [[SBMorphingBezierView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_bezierMorphView];

    CGPoint middle = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    CGPoint topLeft = CGPointMake(middle.x - 100, middle.y - 100);
    CGPoint topRight = CGPointMake(middle.x + 100, middle.y + 100);
    /*
    _paths = [NSArray arrayWithObjects:
             // [UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200) cornerRadius:15],
             //[UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)],
              [self plusSignPathWithCentre:middle scale:40],
              [self arrowPathWithCentre:middle scale:50],
              //[self jigsawPath],
              //[self rhinoPath],

              [UIBezierPath jigsawPathInFrame:[self frameWithWidthPct:0.5 heightPct:0.4 xOffset:0.05 yOffset:0]],
              [UIBezierPath rhinoPathWithFrame:[self frameWithWidthPct:0.8 heightPct:0.4 xOffset:0 yOffset:0]],
              [UIBezierPath elephantPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0 yOffset:0]],
             // [self birdPath],

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
     */
    
    self.paths = @[
                   // Plus sign
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath plusSignPathWithCentre:middle scale:40]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   // T
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath tPathWithCentre:middle scale:40]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // arrow
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath arrowPathWithCentre:middle scale:50]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   // jigsaw
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath jigsawPathInFrame:[self frameWithWidthPct:0.5 heightPct:0.4 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.6],
                   /*
                   // chick
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickPathInFrame:[self frameWithWidthPct:0.8 heightPct:0.7 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.6],
                   
                   // chickin
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickenPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.6],
                   
                   // rhino
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath rhinoPathWithFrame:[self frameWithWidthPct:0.8 heightPct:0.4 xOffset:0 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.7],
                   // elephant
                   [[MorphAnimationInfo alloc]initWithPath:
                    [UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath elephantPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0 yOffset:0]]]
                                             matchRotation:NO
                                            rotationOffset:0.4],
                   */
                   
                   ];
    
    
       //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(morphToNextPath) userInfo:nil repeats:NO];
    
    //[self morphToNextPath];
    //[self drawTwoRandomPaths];
    //[self drawMultipleStrokedBeziers];
    [self doPathsSequentialBasic];

}

-(void)doPathsSequentialBasic{
    
    static int pathNum = 1;
    
    // basic sequential
    MorphAnimationInfo *morphInfo = self.paths[pathNum];
    
    self.bezierMorphView.rotationOffset = morphInfo.rotationOffset;
    self.bezierMorphView.matchShapeRotations = morphInfo.automatchRotation;
    
    UIBezierPath *prevPath = ((MorphAnimationInfo*)self.paths[pathNum-1]).path;
    
    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:4 timingFunc:SBTimingFunctionExponentialInOut drawBlock:^(UIBezierPath *path, float t) {
        
        [[UIColor blackColor]set];
        [path stroke];
    
    } completionBlock:^{
        
        if (pathNum == self.paths.count-1) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self doButterflyPathsFromPath:morphInfo.path];
                [self doAnimalPathsFromPath:morphInfo.path];
            });
        }
        else{
            [self performSelector:@selector(doPathsSequentialBasic) withObject:nil afterDelay:0.05];
        }
        
    }];

    pathNum++;
    
}

-(void)doAnimalPathsFromPath:(UIBezierPath*)endPath{
    
    static int pathNum = 0;
    
    // basic sequential
    MorphAnimationInfo *morphInfo = self.animalPaths[pathNum];
    
    self.bezierMorphView.rotationOffset = morphInfo.rotationOffset;
    self.bezierMorphView.matchShapeRotations = morphInfo.automatchRotation;
    
    UIBezierPath *prevPath;
    float effectStartAmount;
    float effectEndAmount;
    
    
    if (endPath) {
        prevPath = endPath;
        effectStartAmount = 0;
        effectEndAmount = 1;
    }
    else{
        prevPath = ((MorphAnimationInfo*)self.animalPaths[pathNum-1]).path;
        effectStartAmount = 1;
        effectEndAmount = 1;
    }

    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:4 timingFunc:SBTimingFunctionElasticOut drawBlock:^(UIBezierPath *path, float t) {
        
        float effectAmount = effectStartAmount + ((effectEndAmount - effectStartAmount)*t);
        
        [[UIColor blackColor]set];
        [path stroke];
        
        
    } completionBlock:^{
        
        if (pathNum == self.paths.count-1) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doButterflyPathsFromPath:morphInfo.path];
            });
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doAnimalPathsFromPath:nil];
            });
        }
        
    }];
    
    pathNum++;
    
}

-(void)doButterflyPathsFromPath:(UIBezierPath*)endPath{
    
    static int pathNum = 0;
    
    // basic sequential
    MorphAnimationInfo *morphInfo = self.butterflyPaths[pathNum];
    
    self.bezierMorphView.rotationOffset = morphInfo.rotationOffset;
    self.bezierMorphView.matchShapeRotations = morphInfo.automatchRotation;
    
    UIBezierPath *prevPath;
    float effectStartAmount;
    float effectEndAmount;
    
    
    if (endPath) {
        prevPath = endPath;
        effectStartAmount = 0;
        effectEndAmount = 1;
    }
    else{
        prevPath = ((MorphAnimationInfo*)self.butterflyPaths[pathNum-1]).path;
        effectStartAmount = 1;
        effectEndAmount = 1;
    }
    
    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:4 timingFunc:SBTimingFunctionLinear drawBlock:^(UIBezierPath *path, float t) {
        
        float effectAmount = effectStartAmount + ((effectEndAmount - effectStartAmount)*t);
        
        // draw the original path
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:effectAmount]set]; // red
        //[[UIColor redColor]set];
        [path fill];
        
        [[UIColor blackColor]set];
        [path stroke];
        
        // draw the scaled paths
        
        float scaleDownAmount = 0.05 * effectAmount;
        
        for (int i = 0; i < 2; i++) {
            
            UIColor *colour = nil;
            
            switch (i) {
                case 0:
                    colour = [UIColor colorWithRed:255/255.0f green:186/255.0f blue:21/255.0f alpha:effectAmount]; // orange
                    break;
                case 1:
                    colour = [UIColor colorWithRed:248/255.0f green:240/255.0f blue:12/255.0f alpha:effectAmount]; // yellow
                    break;
                default:
                    break;
            }
            
            UIBezierPath *scaledPath = [UIBezierPath bezierPathWithScaledBezierPath:path aroundPoint:self.view.center scale:1 - scaleDownAmount - (i*scaleDownAmount)];
            [colour set];
            [scaledPath fill];
            
            [[UIColor colorWithRed:0 green:0 blue:0 alpha:effectAmount]set]; //black
            [scaledPath stroke];
        }
        
    } completionBlock:^{
        
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doButterflyPathsFromPath:nil];
        //});
    }];
    
    
    pathNum++;
    
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

#pragma mark - Paths

-(NSArray *)butterflyPaths{
    
    if (_butterflyPaths) { return _butterflyPaths; }
    
    _butterflyPaths = @[
                
                    // Butterfly 1
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly1InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // Butterfly 2
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly2InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // Butterfly 3
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly3InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // Butterfly 4
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly4InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // Butterfly 5
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly5InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   // Butterfly 6
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly6InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   
                   ];

    
    return _butterflyPaths;
    
}

-(NSArray *)animalPaths{
    
    if (_animalPaths) { return _animalPaths; }
    
    _animalPaths = @[
                   // chick
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickPathInFrame:[self frameWithWidthPct:0.8 heightPct:0.7 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.6],
                   
                   // chicken
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickenPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.6],
                   
                   // rhino
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath rhinoPathWithFrame:[self frameWithWidthPct:0.8 heightPct:0.4 xOffset:0 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.7],
                   // elephant
                   [[MorphAnimationInfo alloc]initWithPath:
                    [UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath elephantPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0 yOffset:0]]]
                                             matchRotation:NO
                                            rotationOffset:0.4],
                   
                   
                   ];

    return _animalPaths;
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

-(CGRect)frameWithWidthPct:(float)widthPct heightPct:(float)heightPct xOffset:(float)xOffsetPct yOffset:(float)yOffsetPct{
    
    float width = self.view.frame.size.width*widthPct;
    float height = self.view.frame.size.height*heightPct;
    float xOffset = ((self.view.frame.size.width - width)/2) + (self.view.frame.size.width * xOffsetPct);
    float yOffset = ((self.view.frame.size.height - height)/2) + (self.view.frame.size.height * yOffsetPct);

    CGRect frame = CGRectMake(xOffset, yOffset, width, height);
    return frame;

}








@end
