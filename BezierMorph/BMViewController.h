//
//  BMViewController.h
//  BezierMorph
//
//  Created by Steven Barnegren on 17/06/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MorphAnimationInfo : NSObject
@property (nonatomic, strong) UIBezierPath *path;
@property BOOL automatchRotation;
@property float rotationOffset;
@property NSObject *data;
@end




@interface BMViewController : UIViewController

@end
