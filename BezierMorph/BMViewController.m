
    
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

    [self doPathsSequentialBasic];
   // [self doAnimalPathsFromPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)]];
    //[self doButterflyPathsFromPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)]];
    

}

-(void)doPathsSequentialBasic{
    
    static int pathNum = 1;
    
    // basic sequential
    MorphAnimationInfo *morphInfo = self.paths[pathNum];
    
    self.bezierMorphView.rotationOffset = morphInfo.rotationOffset;
    self.bezierMorphView.matchShapeRotations = morphInfo.automatchRotation;
    
    UIBezierPath *prevPath = ((MorphAnimationInfo*)self.paths[pathNum-1]).path;
    
    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:4 timingFunc:SBTimingFunctionElasticOut drawBlock:^(UIBezierPath *path, float t) {
        
        [[UIColor blackColor]set];
        [path stroke];
    
    } completionBlock:^{
        
        if (pathNum == self.paths.count) {
            
            pathNum = 1;
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self doButterflyPathsFromPath:morphInfo.path];
                [self doAnimalPathsFromPath:morphInfo.path];
            //});
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

    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:4 timingFunc:SBTimingFunctionExponentialInOut drawBlock:^(UIBezierPath *path, float t) {
        
        float effectAmount = effectStartAmount + ((effectEndAmount - effectStartAmount)*t);
        
        [[UIColor blackColor]set];
        [path stroke];
       // path.usesEvenOddFillRule = NO;
       // [path fill];
        
        
    } completionBlock:^{
        
        if (pathNum == self.animalPaths.count) {
            pathNum = 0;
            
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
    
    MorphAnimationInfo *prevMorphInfo = nil;
    
    if (endPath) {
        prevPath = endPath;
        effectStartAmount = 0;
        effectEndAmount = 1;
    }
    else{
        prevMorphInfo = (MorphAnimationInfo*)self.butterflyPaths[pathNum-1];
        prevPath = prevMorphInfo.path;
        effectStartAmount = 1;
        effectEndAmount = 1;
    }
    
    float p1OutsideR = 1;
    float p1OutsideG = 1;
    float p1OutsideB = 1;
    float p1MiddleR = 1;
    float p1MiddleG = 1;
    float p1MiddleB = 1;
    float p1InsideR = 1;
    float p1InsideG = 1;
    float p1InsideB = 1;
    
    if (prevMorphInfo) {
        p1OutsideR = [((NSDictionary*)prevMorphInfo.data)[@"Outside_R"]floatValue];
        p1OutsideG = [((NSDictionary*)prevMorphInfo.data)[@"Outside_G"]floatValue];
        p1OutsideB = [((NSDictionary*)prevMorphInfo.data)[@"Outside_B"]floatValue];
        
        p1MiddleR = [((NSDictionary*)prevMorphInfo.data)[@"Middle_R"]floatValue];
        p1MiddleG = [((NSDictionary*)prevMorphInfo.data)[@"Middle_G"]floatValue];
        p1MiddleB = [((NSDictionary*)prevMorphInfo.data)[@"Middle_B"]floatValue];
        
        p1InsideR = [((NSDictionary*)prevMorphInfo.data)[@"Inside_R"]floatValue];
        p1InsideG = [((NSDictionary*)prevMorphInfo.data)[@"Inside_G"]floatValue];
        p1InsideB = [((NSDictionary*)prevMorphInfo.data)[@"Inside_B"]floatValue];
    }
    
    float p2OutsideR = [((NSDictionary*)morphInfo.data)[@"Outside_R"]floatValue];
    float p2OutsideG = [((NSDictionary*)morphInfo.data)[@"Outside_G"]floatValue];
    float p2OutsideB = [((NSDictionary*)morphInfo.data)[@"Outside_B"]floatValue];
    
    float p2MiddleR = [((NSDictionary*)morphInfo.data)[@"Middle_R"]floatValue];
    float p2MiddleG = [((NSDictionary*)morphInfo.data)[@"Middle_G"]floatValue];
    float p2MiddleB = [((NSDictionary*)morphInfo.data)[@"Middle_B"]floatValue];

    float p2InsideR = [((NSDictionary*)morphInfo.data)[@"Inside_R"]floatValue];
    float p2InsideG = [((NSDictionary*)morphInfo.data)[@"Inside_G"]floatValue];
    float p2InsideB = [((NSDictionary*)morphInfo.data)[@"Inside_B"]floatValue];
    
    [_bezierMorphView morphFromPath:prevPath toPath:morphInfo.path duration:2 timingFunc:SBTimingFunctionLinear drawBlock:^(UIBezierPath *path, float t) {
        
        float effectAmount = effectStartAmount + ((effectEndAmount - effectStartAmount)*t);
        
        NSLog(@"effect amount = %f", effectAmount);
        
        // draw the original path
        [[UIColor colorWithRed:p1OutsideR + ((p2OutsideR - p1OutsideR)*t)
                         green:p1OutsideG + ((p2OutsideG - p1OutsideG)*t)
                          blue:p1OutsideB + ((p2OutsideB - p1OutsideB)*t)
                         alpha:effectAmount]set]; // red
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
                    colour = [UIColor colorWithRed:p1MiddleR + ((p2MiddleR - p1MiddleR)*t)
                                             green:p1MiddleG + ((p2MiddleG - p1MiddleG)*t)
                                              blue:p1MiddleB + ((p2MiddleB - p1MiddleB)*t)
                                             alpha:effectAmount]; // red

                    break;
                case 1:
                    colour = [UIColor colorWithRed:p1InsideR + ((p2InsideR - p1InsideR)*t)
                                             green:p1InsideG + ((p2InsideG - p1InsideG)*t)
                                              blue:p1InsideB + ((p2InsideB - p1InsideB)*t)
                                             alpha:effectAmount];

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
        
        if (pathNum == self.butterflyPaths.count) {
            pathNum = 0;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doPathsSequentialBasic];
            });
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doButterflyPathsFromPath:nil];
            });
        }

        
    }];
    
    
    pathNum++;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Paths

-(NSArray*)paths{
    
    if (_paths) { return _paths;}
    
    CGPoint middle = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    _paths = @[
                   
                   // Rounded rect
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200) cornerRadius:15]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   // Circle
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(middle.x - 100, middle.y - 100, 200, 200)]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   
                   // Plus sign
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath plusSignPathWithCentre:middle scale:40]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   
                   // T
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath tPathWithCentre:middle scale:40]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   
                   // arrow
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath arrowPathWithCentre:middle scale:50]]
                                             matchRotation:YES
                                            rotationOffset:0],
                   
                   // jigsaw
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath jigsawPathInFrame:[self frameWithWidthPct:0.5 heightPct:0.4 xOffset:0.05 yOffset:0]]]
                                             matchRotation:NO
                                            rotationOffset:0.2],
                   
                   ];
    
    return _paths;
}

-(NSArray *)butterflyPaths{
    
    if (_butterflyPaths) { return _butterflyPaths; }
    
    NSMutableArray *mutablePaths = [[NSMutableArray alloc]init];
    
    // butterfly 1
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly1InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                  matchRotation:NO
                                 rotationOffset:0.61];
        anim.data = @{
                       @"Outside_R" : @(1),  @"Outside_G" : @(0),  @"Outside_B" : @(0),
                       @"Middle_R" : @(255/255.0f),  @"Middle_G" : @(186/255.0f),  @"Middle_B" : @(21/255.0f), // orange
                       @"Inside_R" : @(248/255.0f),  @"Inside_G" : @(240/255.0f),  @"Inside_B" : @(12/255.0f), // yellow
                     };
        [mutablePaths addObject:anim];
   
    }
    // butterfly 2
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly2InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                                              matchRotation:NO
                                                             rotationOffset:0.825];
        anim.data = @{
                      @"Outside_R" : @(0),  @"Outside_G" : @(1),  @"Outside_B" : @(0),
                      @"Middle_R" : @(1),  @"Middle_G" : @(0),  @"Middle_B" : @(0),
                      @"Inside_R" : @(0),  @"Inside_G" : @(0),  @"Inside_B" : @(1),
                      };
        [mutablePaths addObject:anim];
    }

    // butterfly 3
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly3InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                                              matchRotation:NO
                                                             rotationOffset:0.785];
        anim.data = @{
                      @"Outside_R" : @(1),  @"Outside_G" : @(1),  @"Outside_B" : @(0),
                      @"Middle_R" : @(1),  @"Middle_G" : @(0),  @"Middle_B" : @(1),
                      @"Inside_R" : @(0),  @"Inside_G" : @(1),  @"Inside_B" : @(0),
                      };
        [mutablePaths addObject:anim];
    }

    // butterfly 4
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly4InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                                              matchRotation:NO
                                                             rotationOffset:0.95];
        anim.data = @{
                      @"Outside_R" : @(0),  @"Outside_G" : @(0),  @"Outside_B" : @(0),
                      @"Middle_R" : @(0),  @"Middle_G" : @(0.5),  @"Middle_B" : @(1),
                      @"Inside_R" : @(1),  @"Inside_G" : @(0.5),  @"Inside_B" : @(0),
                      };
        [mutablePaths addObject:anim];
    }

    // butterfly 5
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly5InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                                              matchRotation:NO
                                                             rotationOffset:0.975];
        anim.data = @{
                      @"Outside_R" : @(0.9),  @"Outside_G" : @(0.9),  @"Outside_B" : @(0.9),
                      @"Middle_R" : @(0.1),  @"Middle_G" : @(0.7),  @"Middle_B" : @(0.2),
                      @"Inside_R" : @(0.8),  @"Inside_G" : @(0.735),  @"Inside_B" : @(0.386),
                      };
        [mutablePaths addObject:anim];
    }

    // butterfly 6
    {
        MorphAnimationInfo * anim = [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath butterFly6InFrame:[self frameWithWidthPct:0.9 heightPct:0.7 xOffset:0 yOffset:0]]
                                                              matchRotation:YES
                                                             rotationOffset:0];
        anim.data = @{
                      @"Outside_R" : @(0.3657),  @"Outside_G" : @(0.879453),  @"Outside_B" : @(0.26780),
                      @"Middle_R" : @(0.25690),  @"Middle_G" : @(0.678593),  @"Middle_B" : @(0.265793),
                      @"Inside_R" : @(0.926),  @"Inside_G" : @(0.278690),  @"Inside_B" : @(0.238),
                      };
        [mutablePaths addObject:anim];
    }

    _butterflyPaths = [NSArray arrayWithArray:mutablePaths];
    
    return _butterflyPaths;
    
}

-(NSArray *)animalPaths{
    
    if (_animalPaths) { return _animalPaths; }
    
    _animalPaths = @[
                     
                   
                     
                   // chick
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickPathInFrame:[self frameWithWidthPct:0.8 heightPct:0.7 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.8],
                   
                   // chicken
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath chickenPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0.05 yOffset:0]]
                                             matchRotation:NO
                                            rotationOffset:0.85],
                   
                   
                   // rhino
                   [[MorphAnimationInfo alloc]initWithPath:[UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath rhinoPathWithFrame:[self frameWithWidthPct:0.8 heightPct:0.4 xOffset:0 yOffset:0]]]
                                             matchRotation:NO
                                            rotationOffset:0.5],
                   
                   // elephant
                   [[MorphAnimationInfo alloc]initWithPath:
                    [UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath bezierPathWithReverseOfPath:[UIBezierPath elephantPathInFrame:[self frameWithWidthPct:0.9 heightPct:0.6 xOffset:0 yOffset:0]]]]
                                             matchRotation:NO
                                            rotationOffset:0.7],
                   
                   
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
