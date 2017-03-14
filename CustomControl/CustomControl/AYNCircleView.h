//
//  AYNCircleView.h
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

@import UIKit;

@protocol AYNCircleViewDelegate;

@interface AYNCircleView : UIView

@property (nonatomic, readonly) NSInteger value;

@property (assign, nonatomic) NSInteger numberOfLabels;

@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) UIFont *labelFont;
@property (strong, nonatomic) UIColor *labelTextColor;

@property (weak, nonatomic) id<AYNCircleViewDelegate> delegate;

@end

@protocol AYNCircleViewDelegate <NSObject>

@optional

- (void)circleViewWillRotate:(AYNCircleView *)circleView;
- (void)circleView:(AYNCircleView *)circleView didRotateWithValue:(NSUInteger)value;

@end
