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

@end

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"view did load");
    
    /*
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)];
    NSMutableArray *points = [bezierPath getAllPoints];
    
    NSLog(@"%i points", points.count);
    
    for (NSValue *value in points) {
        
        CGPoint point = [value CGPointValue];
        NSLog(@"point = (%f, %f)", point.x, point.y);
        
        [self debugDrawDotAt:point];
        
        
        
  
    }
    */
    
    BezierMorphView *bezierMorphView = [[BezierMorphView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:bezierMorphView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Debug
-(void)debugDrawDotAt:(CGPoint)loc{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(loc.x, loc.y, 5, 5)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    
}








@end
